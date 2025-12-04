#!/usr/bin/env node
/*
  Simple bulk converter: copies every .js file under src2/ to .ts
  - preserves original .js files
  - converts commonjs require/module.exports to basic ES import/export
  - adds minimal tslint/ts-ignore pragmas where necessary

  Run: node scripts/convert-src2-js-to-ts.js
*/
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const SRC2 = path.join(ROOT, 'src2');

function walk(dir) {
  const res = [];
  const list = fs.readdirSync(dir);
  for (const file of list) {
    const full = path.join(dir, file);
    const stat = fs.statSync(full);
    if (stat.isDirectory()) {
      res.push(...walk(full));
    } else if (stat.isFile() && full.endsWith('.js')) {
      res.push(full);
    }
  }
  return res;
}

function convertRequireToImport(code) {
  // handle const {a,b} = require('mod')
  code = code.replace(/const\s+\{([^}]+)\}\s*=\s*require\(['"](.+?)['"]\);?/g, (m, names, mod) => {
    return `import { ${names.trim()} } from '${mod}';`;
  });

  // handle const X = require('mod')
  code = code.replace(/const\s+([a-zA-Z0-9_$]+)\s*=\s*require\(['"](.+?)['"]\);?/g, (m, name, mod) => {
    return `import ${name} from '${mod}';`;
  });

  // handle var or let require
  code = code.replace(/var\s+([a-zA-Z0-9_$]+)\s*=\s*require\(['"](.+?)['"]\);?/g, (m, name, mod) => {
    return `import ${name} from '${mod}';`;
  });

  // convert module.exports = X -> export default X
  code = code.replace(/module\.exports\s*=\s*/g, 'export default ');

  // convert exports.foo = ... -> export const foo = ...
  code = code.replace(/exports\.([a-zA-Z0-9_$]+)\s*=\s*/g, (m, name) => `export const ${name} = `);

  return code;
}

function fixLocalPaths(code) {
  // Replace require/import paths ending with .js to path without ext
  return code.replace(/(['"])(\.\.?(?:[^'"\\]+)*?)\.js\1/g, (m, q, p) => `${q}${p}${q}`);
}

function addHeader(code, relPath) {
  const header = `/* Auto-generated TypeScript copy of ${relPath} */\n/* eslint-disable @typescript-eslint/no-var-requires, @typescript-eslint/explicit-module-boundary-types */\n// KEEP ORIGINAL .js file as backup. MANUAL REVIEW REQUIRED.\n`;
  return header + '\n' + code;
}

function convert(file) {
  const rel = path.relative(ROOT, file);
  const content = fs.readFileSync(file, 'utf8');

  let code = content;
  code = convertRequireToImport(code);
  code = fixLocalPaths(code);

  // Ensure module.exports conversions that produce 'export default' are valid lines
  // Add a trailing semicolon if missing
  code = code.replace(/export default ([\s\S]*?);?\n/g, (m) => m.endsWith('\n') ? m : m + '\n');

  code = addHeader(code, rel);

  return code;
}

function run() {
  const files = walk(SRC2);
  console.log(`Found ${files.length} .js files under src2`);
  for (const f of files) {
    try {
      const tsContent = convert(f);
      const tsPath = f.slice(0, -3) + '.ts';
      // If the .ts already exists, skip
      if (fs.existsSync(tsPath)) {
        console.log(`Skipping existing: ${path.relative(ROOT, tsPath)}`);
        continue;
      }
      fs.writeFileSync(tsPath, tsContent, 'utf8');
      console.log(`Created: ${path.relative(ROOT, tsPath)}`);
    } catch (err) {
      console.error(`Failed to convert ${f}:`, err);
    }
  }
}

run();

const { spawn } = require('child_process');


function extractWithPython(mail, bankname) {
  return new Promise((resolve, reject) => {
    const py = spawn('python', ['scrapemail.py']);
    let data = '';
    const payload = { mail, bankname };
    py.stdin.write(JSON.stringify(payload));
    py.stdin.end();

    py.stdout.on('data', (chunk) => {
      data += chunk.toString();
    });

    py.stderr.on('data', (err) => {
      console.error('Python error:', err.toString());
      reject(err.toString());
    });

    py.on('close', () => {
      try {
        resolve(JSON.parse(data));
      } catch (e) {
        reject(e);
      }
    });
  });
}

module.exports = {
  extractWithPython,
};

import { spawn } from 'child_process';
import os from 'os';
import path from 'path';

export function extractWithPython(
  mail: any,
  bankFilters: string[],
  pdfPasswords: Record<string, string[]> = {}
): Promise<any> {
  return new Promise((resolve, reject) => {
    const scriptPath = path.resolve('scrapemail.py');
    const pythonPath = process.env.PYTHON_BIN || (os.platform() === 'win32' ? 'python' : 'python3');
    const py = spawn(pythonPath, [scriptPath]);
    let data = '';
    let errorData = '';

    const payload = {
      subject: mail.subject || '',
      body: mail.body || '',
      attachments: mail.attachments || [],
      messageId: mail.messageId || '',
      from: mail.from || '',
      user_bank: bankFilters || [],
      pdf_passwords: pdfPasswords || {},
    };

    const timeout = setTimeout(() => {
      py.kill();
      reject(new Error('Python script timeout after 60 seconds'));
    }, 60000);

    py.stdout.on('data', (chunk) => {
      data += chunk.toString();
    });

    py.stderr.on('data', (chunk) => {
      errorData += chunk.toString();
    });

    py.on('error', (err) => {
      clearTimeout(timeout);
      reject(new Error(`Failed to start Python process: ${err.message}`));
    });

    py.on('close', (code) => {
      clearTimeout(timeout);

      if (code !== 0) {
        reject(new Error(`Python process failed with code ${code}\n${errorData}`));
        return;
      }

      if (!data.trim()) {
        reject(new Error(`No output from Python script\nstderr: ${errorData}`));
        return;
      }

      try {
        resolve(JSON.parse(data));
      } catch (err: any) {
        reject(new Error(`Failed to parse Python JSON output: ${err.message}`));
      }
    });

    try {
      py.stdin.write(JSON.stringify(payload));
      py.stdin.end();
    } catch (err: any) {
      clearTimeout(timeout);
      reject(new Error(`Failed to send payload to Python: ${err.message}`));
    }
  });
}

export default {
  extractWithPython,
};

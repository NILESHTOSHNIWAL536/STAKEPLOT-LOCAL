import { spawn } from 'child_process';
import path from 'path';

export function extractWithPython(
  mail: any,
  bankFilters: string[]
): Promise<any> {
  return new Promise((resolve, reject) => {
    // Use absolute path to python3 and scrapemail.py
    const pythonPath = '/usr/bin/python3';
    const scriptPath = path.resolve('/app/scrapemail.py');
    
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
    };

    if (!payload.subject && !payload.body) {
      console.warn('Warning: Email has no subject or body');
    }

    try {
      py.stdin.write(JSON.stringify(payload));
      py.stdin.end();
    } catch (err: any) {
      reject(new Error(`Failed to send data to Python: ${err.message}`));
      return;
    }

    py.stdout.on('data', (chunk) => {
      data += chunk.toString();
    });

    py.stderr.on('data', (err) => {
      errorData += err.toString();
      console.error('Python stderr:', errorData);
    });

    py.on('close', (code) => {
      if (code !== 0) {
        console.error('Python process exited with code:', code);
        console.error('Error output:', errorData);
      }

      try {
        if (!data) {
          reject(new Error('No output from Python script'));
          return;
        }
        const result = JSON.parse(data);
        resolve(result);
      } catch (e: any) {
        console.error('Failed to parse Python output:', data);
        console.error('Parse error:', e.message);
        reject(new Error(`Failed to parse Python output: ${e.message}`));
      }
    });

    py.on('error', (err) => {
      reject(new Error(`Failed to spawn Python process: ${err.message}`));
    });
  });
}

export default {
  extractWithPython,
};

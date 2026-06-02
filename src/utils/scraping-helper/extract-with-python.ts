import { spawn } from 'child_process';
import os from 'os';
import path from 'path';


export function extractWithPython(
  mail: any,
  bankFilters: string[],
  pdfPasswords: Record<string, string[]> = {}
): Promise<any> {
  return new Promise((resolve, reject) => {
    try {

      const scriptPath = path.resolve('scrapemail.py');
      const pythonPath = 'python';
     console.log(pdfPasswords);
     const py = spawn(pythonPath, [scriptPath]);

      let data = '';
      let errorData = '';

      // =========================================
      // PAYLOAD
      // =========================================
      const payload = {
        subject: mail.subject || '',
        body: mail.body || '',
        attachments: mail.attachments || [],
        messageId: mail.messageId || '',
        from: mail.from || '',
        user_bank: bankFilters || [],
        pdf_passwords: pdfPasswords || {},
      };


      // =========================================
      // TIMEOUT
      // =========================================
      const timeout = setTimeout(() => {
        py.kill();

        reject(
          new Error('Python script timeout after 60 seconds')
        );
      }, 60000);

      // =========================================
      // STDOUT
      // =========================================
      py.stdout.on('data', (chunk) => {
        const output = chunk.toString();
        data += output;
         console.log('Python stdout:', data.toString());
      });

      // =========================================
      // STDERR
      // =========================================
      py.stderr.on('data', (chunk) => {
        const err = chunk.toString();

        console.error('Python stderr:', err);

        errorData += err;
      });

      // =========================================
      // PROCESS ERROR
      // =========================================
      py.on('error', (err) => {
        clearTimeout(timeout);

        reject(
          new Error(
            `Failed to start Python process: ${err.message}`
          )
        );
      });

      // =========================================
      // PROCESS CLOSE
      // =========================================
      py.on('close', (code) => {
        clearTimeout(timeout);

        console.log('Python exited with code:', code);

        // If Python failed
        if (code !== 0) {
          reject(
            new Error(
              `Python process failed with code ${code}\n${errorData}`
            )
          );

          return;
        }

        // Empty output
        if (!data || !data.trim()) {
          reject(
            new Error(
              `No output from Python script\nstderr: ${errorData}`
            )
          );

          return;
        }

        try {
          const result = JSON.parse(data);

          resolve(result);
        } catch (e: any) {
          console.error('Raw Python output:', data);

          reject(
            new Error(
              `Failed to parse Python JSON output: ${e.message}`
            )
          );
        }
      });

      // =========================================
      // SEND INPUT
      // =========================================
      try {
        py.stdin.write(JSON.stringify(payload));
        py.stdin.end();
      } catch (err: any) {
        clearTimeout(timeout);

        reject(
          new Error(
            `Failed to send payload to Python: ${err.message}`
          )
        );
      }
    } catch (err: any) {
      reject(
        new Error(
          `Unexpected error in extractWithPython: ${err.message}`
        )
      );
    }
  });
}

// export default {
//   extractWithPython,
// };


export function extractWithPython2(
  mail: any,
  bankFilters: string[],
  pdfPasswords: Record<string, string[]> = {}
): Promise<any> {
  return new Promise((resolve, reject) => {
    const scriptPath = path.resolve('scrapemail.py');
    const pythonPath = 'python';
    
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
      pdf_passwords: pdfPasswords,
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

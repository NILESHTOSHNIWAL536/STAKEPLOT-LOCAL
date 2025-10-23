const { spawn } = require('child_process');

function extractWithPython(mail, bankFilters) {
  return new Promise((resolve, reject) => {
    const py = spawn('python', ['scrapemail.py']);
    let data = '';
    let errorData = '';

    // ========================================
    // FIX 1: Flatten and restructure the payload
    // ========================================
    const payload = {
      subject: mail.subject || '',
      body: mail.body || '',
      attachments: mail.attachments || [],
      messageId: mail.messageId || '',
      from: mail.from || '',
      user_bank: bankFilters || []  // FIX 2: Use user_bank instead of bankname
    };


    // ========================================
    // FIX 3: Add data validation before sending
    // ========================================
    if (!payload.subject && !payload.body) {
      console.warn('Warning: Email has no subject or body');
    }

    try {
      py.stdin.write(JSON.stringify(payload));
      py.stdin.end();
    } catch (err) {
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
      // ========================================
      // FIX 4: Better error handling
      // ========================================
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
      } catch (e) {
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

module.exports = {
  extractWithPython,
};
const fs = require("fs");
const crypto = require("crypto");

// Encrypt file using AES-256-GCM (provides both confidentiality + integrity)
function encryptFile(inputPath, outputPath, keyBuffer) {
  return new Promise((resolve, reject) => {
    const iv = crypto.randomBytes(12); // GCM uses 12-byte IVs
    const cipher = crypto.createCipheriv("aes-256-gcm", keyBuffer, iv);

    const input = fs.createReadStream(inputPath);
    const output = fs.createWriteStream(outputPath);

    output.write(iv); // Write IV first

    input.pipe(cipher).pipe(output);

    cipher.on("end", () => {
      const authTag = cipher.getAuthTag(); // Integrity tag
      output.write(authTag); // Append tag at the end
      output.end();
    });

    output.on("finish", () => resolve());
    output.on("error", reject);
    input.on("error", reject);
  });
}

function decryptFile(inputPath, outputPath, keyBuffer) {
  return new Promise((resolve, reject) => {
    // Read full file into buffer first (for simplicity)
    fs.readFile(inputPath, (err, data) => {
      if (err) return reject(err);

      const iv = data.subarray(0, 12);
      const authTag = data.subarray(data.length - 16); // last 16 bytes
      const encryptedData = data.subarray(12, data.length - 16);

      const decipher = crypto.createDecipheriv("aes-256-gcm", keyBuffer, iv);
      decipher.setAuthTag(authTag);

      const decrypted = Buffer.concat([
        decipher.update(encryptedData),
        decipher.final(),
      ]);

      fs.writeFile(outputPath, decrypted, (err) => {
        if (err) return reject(err);
        resolve();
      });
    });
  });
}

module.exports = { encryptFile, decryptFile };

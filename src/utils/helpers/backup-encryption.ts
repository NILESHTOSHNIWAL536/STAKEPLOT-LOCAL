import * as fs from "fs";
import * as crypto from "crypto";

export function encryptFile(
  inputPath: string,
  outputPath: string,
  keyBuffer: Buffer
): Promise<void> {
  return new Promise((resolve, reject) => {
    const iv = crypto.randomBytes(12); // GCM IV is always 12 bytes
    const cipher = crypto.createCipheriv("aes-256-gcm", keyBuffer, iv);

    const input = fs.createReadStream(inputPath);
    const output = fs.createWriteStream(outputPath);

    // Write IV first
    output.write(iv);

    input.pipe(cipher).pipe(output);

    cipher.on("end", () => {
      try {
        const authTag = cipher.getAuthTag(); // 16-byte authentication tag
        output.write(authTag);
        output.end();
      } catch (err) {
        reject(err);
      }
    });

    output.on("finish", () => resolve());
    output.on("error", reject);
    input.on("error", reject);
  });
}

export function decryptFile(
  inputPath: string,
  outputPath: string,
  keyBuffer: Buffer
): Promise<void> {
  return new Promise((resolve, reject) => {
    fs.readFile(inputPath, (err, data) => {
      if (err) return reject(err);

      const iv = data.subarray(0, 12);
      const authTag = data.subarray(data.length - 16); // last 16 bytes
      const encryptedData = data.subarray(12, data.length - 16);

      try {
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
      } catch (decryptErr) {
        reject(decryptErr);
      }
    });
  });
}

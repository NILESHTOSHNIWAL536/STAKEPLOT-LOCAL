const crypto = require('crypto');
const ivLength = 12;

// Encryption function
async function encrypt(text, plaintextKey) {
    if (!text) return { encryptedData: '', iv: '', authTag: '' };
    
    const keyBuffer = Buffer.from(plaintextKey);
    if (keyBuffer.length !== 32) {
        throw new Error('Invalid key length: must be 32 bytes for AES-256');
    }
    
    const iv = crypto.randomBytes(ivLength);
    const cipher = crypto.createCipheriv('aes-256-gcm', keyBuffer, iv);

    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');

    const authTag = cipher.getAuthTag();
    return {
        encryptedData: encrypted,
        iv: iv.toString('hex'),
        authTag: authTag.toString('hex')
    };
}

// Decryption function
function decrypt(encryptedData, ivHex, authTagHex, plaintextKey) {
    try {
        const keyBuffer = Buffer.from(plaintextKey);
        const iv = Buffer.from(ivHex, 'hex');
        const authTag = Buffer.from(authTagHex, 'hex');
        const decipher = crypto.createDecipheriv('aes-256-gcm', keyBuffer, iv);
        decipher.setAuthTag(authTag);
        let decrypted = decipher.update(encryptedData, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        return decrypted;
    } catch (err) {
        console.error(`Failed to decrypt key: ${encryptedData} ->`, err.message);
        return null;
    }
}


// function to encrypt an object
async function encryptObject(obj, plaintextKey) {
    const encryptedObj = {};
    const entries = obj instanceof Map ? obj.entries() : Object.entries(obj);

    for (const [key, value] of entries) {
        if (value !== null && value !== undefined) {
            encryptedObj[key] = await encrypt(value.toString(), plaintextKey);
        } else {
            encryptedObj[key] = { encryptedData: '', iv: '', authTag: '' };
        }
    }
    return encryptedObj;
}

// function to decrypt an object
async function decryptObject(obj, plaintextKey) {
    const decryptedObj = {};
    const entries = obj instanceof Map ? obj.entries() : Object.entries(obj);

    for (const [key, value] of entries) {
        if (value && value.encryptedData && value.iv && value.authTag) {
            decryptedObj[key] = decrypt(
                value.encryptedData,
                value.iv,
                value.authTag,
                plaintextKey
            );
        } else {
            decryptedObj[key] = value;
        }
    }
    return decryptedObj;
}

module.exports = {
    encrypt,
    decrypt,
    encryptObject,
    decryptObject
};
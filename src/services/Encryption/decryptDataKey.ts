const { KMSClient, DecryptCommand } = require('@aws-sdk/client-kms');
const logger = require('../../utils/common/logger');

const kmsClient = new KMSClient({ region: process.env.AWS_REGION });

async function decryptDataKey(ciphertextBlob: string) {
  try {
    if (!ciphertextBlob || typeof ciphertextBlob !== 'string') {
      throw new Error('Invalid or missing ciphertextBlob');
    }
    if (!/^[A-Za-z0-9+/=]+$/.test(ciphertextBlob)) {
      throw new Error('CiphertextBlob is not a valid base64 string');
    }
    const params = {
      CiphertextBlob: Buffer.from(ciphertextBlob, 'base64'),
      KeyId: process.env.KMS_KEY_ID,
    };
    const result = await kmsClient.send(new DecryptCommand(params));
    return result.Plaintext;
  } catch (error: any) {
    logger.error(`Error decrypting data key: ${error.message}`, {
      stack: error.stack,
      ciphertextBlob: ciphertextBlob.substring(0, 50), // Log partial for safety
    });
    throw error;
  }
}

export default decryptDataKey;

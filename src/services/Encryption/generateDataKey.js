const { KMSClient, GenerateDataKeyCommand } = require('@aws-sdk/client-kms');
const logger = require('../../utils/common/logger');


const kmsClient = new KMSClient(process.env.AWS_REGION);
const keyId = process.env.KMS_KEY_ID;

async function generateDataKey() {
  try {
    const params = { KeyId: keyId, KeySpec: 'AES_256' };
    const result = await kmsClient.send(new GenerateDataKeyCommand(params));

    const base64Ciphertext = Buffer.from(result.CiphertextBlob).toString('base64');
    
    // Validate base64 format
    if (!/^[A-Za-z0-9+/=]+$/.test(base64Ciphertext)) {
      throw new Error('Generated ciphertextBlob is not a valid base64 string');
    }
    
    return {
      plaintextKey: result.Plaintext,
      ciphertextBlob: base64Ciphertext
    };
  } catch (error) {
    logger.error(`Error generating data key: ${error}`);
    throw error;
  }
}

module.exports = { generateDataKey };
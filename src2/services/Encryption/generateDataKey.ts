import { KMSClient, GenerateDataKeyCommand, GenerateDataKeyCommandInput, DataKeySpec } from '@aws-sdk/client-kms';
import logger from '../../utils/common/logger';

const kmsClient = new KMSClient({ region: process.env.AWS_REGION });
const keyId = process.env.KMS_KEY_ID as string;

export async function generateDataKey(): Promise<{
  plaintextKey: Uint8Array | undefined;
  ciphertextBlob: string;
}> {
  try {
    const params: GenerateDataKeyCommandInput = {
      KeyId: keyId,
      KeySpec: 'AES_256' satisfies DataKeySpec,
    };

    const result = await kmsClient.send(new GenerateDataKeyCommand(params));

    const base64Ciphertext = Buffer.from(result.CiphertextBlob!).toString('base64');

    // Validate base64 format
    if (!/^[A-Za-z0-9+/=]+$/.test(base64Ciphertext)) {
      throw new Error('Generated ciphertextBlob is not a valid base64 string');
    }

    return {
      plaintextKey: result.Plaintext,
      ciphertextBlob: base64Ciphertext,
    };
  } catch (error: any) {
    logger.error(`Error generating data key: ${error}`);
    throw error;
  }
}

export default { generateDataKey };

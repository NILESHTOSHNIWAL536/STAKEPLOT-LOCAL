import { KMSClient, GenerateDataKeyCommand, GenerateDataKeyCommandInput, DataKeySpec } from '@aws-sdk/client-kms';
import logger from '../../utils/common/logger';

const kmsClient = new KMSClient({ region: process.env.AWS_REGION });

export async function generateDataKey(): Promise<{
  plaintextKey: Uint8Array | string;
  ciphertextBlob: string;
}> {
  try {
    const params: GenerateDataKeyCommandInput = {
      KeyId: process.env.KMS_KEY_ID as string,
      KeySpec: 'AES_256' satisfies DataKeySpec,
    };

    const result = await kmsClient.send(new GenerateDataKeyCommand(params));

    if (!result.Plaintext) {
      throw new Error("KMS did not return a plaintext data key");
    }

    if (!result.CiphertextBlob) {
      throw new Error("KMS did not return a ciphertext data key");
    }

    const base64Ciphertext = Buffer.from(result.CiphertextBlob).toString('base64');

    return {
      plaintextKey: result.Plaintext,
      ciphertextBlob: base64Ciphertext,
    };
  } catch (error: any) {
    logger.error(`Error generating data key: ${error}`);
    throw error;
  }
}
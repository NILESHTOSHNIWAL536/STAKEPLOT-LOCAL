import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: process.env.AWS_REGION || 'ap-south-1' });

let secretsLoaded = false;

/**
 * Fetches secrets from AWS Secrets Manager and injects them into process.env.
 * Must be called at the very start of startServer(), before any code that reads secrets.
 *
 * Set AWS_SECRET_NAME in your .base env file (e.g. "stakeplot/staging/mobile-backend").
 * If AWS_SECRET_NAME is not set, this is a no-op — useful for local dev with a .env file.
 */
export const loadSecrets = async (): Promise<void> => {
  if (secretsLoaded) return;

  const secretName = process.env.AWS_SECRET_NAME;

  if (!secretName) {
    console.log('[secrets] AWS_SECRET_NAME not set — skipping Secrets Manager (local dev mode)');
    return;
  }

  try {
    const response = await client.send(
      new GetSecretValueCommand({ SecretId: secretName })
    );

    if (!response.SecretString) {
      throw new Error(`Secret "${secretName}" returned no SecretString`);
    }

    const secrets = JSON.parse(response.SecretString) as Record<string, string>;

    for (const [key, value] of Object.entries(secrets)) {
      process.env[key] = value;
    }

    secretsLoaded = true;
    console.log(`[secrets] Loaded from AWS Secrets Manager: ${secretName}`);
  } catch (err) {
    console.error(`[secrets] FATAL — failed to load "${secretName}" from Secrets Manager:`, err);
    process.exit(1);
  }
};

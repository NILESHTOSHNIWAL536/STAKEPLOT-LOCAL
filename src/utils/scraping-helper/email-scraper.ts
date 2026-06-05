import { extractWithPython } from './extract-with-python';
import EmailServiceHelper from './scraping-helper';
import { checkIsFromBank } from '../check-valid-email_data';
import { StatementPasswordInput } from '../../services/email-password-request';
import { buildEmailScraperConfig } from './emailScraperConfig';
import { fetchAndPrepareEmails } from './gmailProcessor';
import { processFilteredEmails } from './mailExtractionProcessor';

export async function emailScraperHelper(
  gmailClient: any,
  creditCard: any[],
  mode: 'initial' | 'incremental' = 'initial',
  statementPasswords: StatementPasswordInput[] = []
): Promise<{
  results: any[];
  bankConfig: any[];
  requiresPassword?: boolean;
  passwordRequests?: any[];
  pendingStatements?: any[];
}> {
  try {
    const gmail = gmailClient;

    const config = buildEmailScraperConfig(creditCard, mode, statementPasswords);

    const mailsToProcess = await fetchAndPrepareEmails(
      gmail,
      config.afterDate,
      config.bankConfig,
      config.passwordList
    );

    if (!mailsToProcess.length) {
      return {
        results: [],
        bankConfig: config.bankConfig,
      };
    }

    const processed = await processFilteredEmails(mailsToProcess, config);

    return {
      results: processed.results || [],
      bankConfig: config.bankConfig,
      requiresPassword: processed.requiresPassword,
      passwordRequests: processed.passwordRequests || [],
      pendingStatements: processed.pendingStatements || [],
    };

  } catch (error) {
    console.error('Error in emailScraperHelper:', error);

    throw error;
  }
}

import crypto from 'crypto';
import { IScrapeResult } from '../models/scrape-result';


 type StatementPasswordInput = {
  bankId: string;
  password: string;
  email?: string;
  accountHint?: string;
};


function resolveMatchedBank(result: any, bankConfig: any[]) {
  const matched = String(result?.matched_bank || '').toLowerCase();
  return (
    bankConfig.find((bank) => {
      const name = String(bank.name || '').toLowerCase();
      const bankId = String(bank.bankId || '').toLowerCase();
      return (
        (matched && (name.includes(matched) || matched.includes(name))) ||
        (bankId && matched === bankId)
      );
    }) || bankConfig[0]
  );
}


function buildPasswordRequests(scrapedEmails: any, bankConfig: any[]) {
  const results = Array.isArray(scrapedEmails?.results) ? scrapedEmails.results : [];
  const requests = new Map<string, any>();

  for (const result of results) {
    if (!result?.sources_processed?.needs_password) continue;

    const matchedBank = resolveMatchedBank(result, bankConfig);
    const bankId = matchedBank?.bankId || '';
    const key = `${bankId}:${result.message_id || result.messageId || result.subject || ''}`;

    requests.set(key, {
      bankId,
      bankName: matchedBank?.name || result.matched_bank || 'Bank statement',
      messageId: result.message_id || result.messageId || '',
      filename: result.sources_processed?.password_file || '',
      reason: result.sources_processed?.password_error || 'password_required',
    });
  }

  return Array.from(requests.values());
}


function generateTransactionHash(record: IScrapeResult): string {
  return crypto
    .createHash('sha256')
    .update(
      [
        record.userId,
        record.matched_bank || '',
        record.transaction_id || '',
        record.amount || '',
        record.date || '',
        record.card_number || '',
        record.total_due || '',
      ].join('|')
    )
    .digest('hex');
}


export {StatementPasswordInput,buildPasswordRequests,resolveMatchedBank,generateTransactionHash};
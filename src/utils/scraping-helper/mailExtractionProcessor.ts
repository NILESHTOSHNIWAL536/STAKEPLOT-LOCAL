import { extractWithPython } from './extract-with-python';

export async function processFilteredEmails(
  mailsToProcess: any[],
  config: {
    bankConfig: any[];
    banksWithPassword: Set<string>;
    bankFilters: string[];
    pdfPasswordsByBank: Record<string, string[]>;
  }
) {

  const mailsToProcess2 = filterRelevantEmails(mailsToProcess, config.bankConfig);
  
  const protectedPasswordRequests = buildPasswordRequestsForProtectedAttachments(
    mailsToProcess2,
    config.bankConfig,
    config.banksWithPassword
  );

  const protectedRequestKeys = new Set(
    protectedPasswordRequests.map((request) => request.requestId)
  );

  const results: any[] = [];
  const pendingStatements: any[] = [];

  for (const mail of mailsToProcess2) {
    const mailProtectedRequests = protectedPasswordRequests.filter(
      (request) => request.messageId === (mail.messageId || '')
    );

    if (mailProtectedRequests.length > 0) {
      pendingStatements.push(
        ...mailProtectedRequests.map((request) => ({
          ...request,
          mail,
        }))
      );
      continue;
    }

    const extracted = await extractWithPython(mail, config.bankFilters, config.pdfPasswordsByBank);

    results.push(extracted);

    const parserRequests = buildPasswordRequestsFromParserResults(
      [extracted],
      config.bankConfig
    );

    if (parserRequests.length > 0) {
      pendingStatements.push(
        ...parserRequests
          .filter((request) => !protectedRequestKeys.has(request.requestId))
          .map((request) => ({
            ...request,
            mail,
          }))
      );
    }
  }

  const parserPasswordRequests = buildPasswordRequestsFromParserResults(results, config.bankConfig);
  const passwordRequests = mergeRequests([
    ...protectedPasswordRequests,
    ...parserPasswordRequests,
  ]);

  return {
    requiresPassword: passwordRequests.length > 0,
    results: results.filter((result) => !result?.sources_processed?.needs_password),
    passwordRequests,
    pendingStatements,
  };
}

function buildPasswordRequestsForProtectedAttachments(
  mails: any[],
  bankConfig: any[],
  banksWithPassword: Set<string>
) {
  const requests = new Map<string, any>();

  for (const mail of mails) {
    const protectedAttachments = (mail.attachments || []).filter(
      (attachment: any) => attachment.requiresPassword
    );

    if (!protectedAttachments.length) continue;

    const matchedBank = resolveMailBank(mail, bankConfig);
    if (matchedBank?.bankId && banksWithPassword.has(matchedBank.bankId)) {
      continue;
    }

    for (const attachment of protectedAttachments) {
      const bankId = matchedBank?.bankId || '';
      const filename = attachment.filename || attachment.name || '';
      const key = `${bankId}:${mail.messageId || ''}:${filename}`;

      requests.set(key, {
        requestId: key,
        bankId,
        bankName: matchedBank?.name || 'Bank statement',
        messageId: mail.messageId || '',
        filename,
        reason: attachment.passwordError || 'password_required',
      });
    }
  }

  return Array.from(requests.values());
}

function mergeRequests(requests: any[]) {
  const merged = new Map<string, any>();

  for (const request of requests) {
    const key =
      request.requestId ||
      `${request.bankId || ''}:${request.messageId || ''}:${request.filename || ''}`;
    if (!key || merged.has(key)) continue;
    merged.set(key, request);
  }

  return Array.from(merged.values());
}

export function buildPasswordRequestsFromParserResults(results: any[], bankConfig: any[]) {
  const requests = new Map<string, any>();

  for (const result of results) {
    if (!result?.sources_processed?.needs_password) continue;

    const matchedBank = resolveResultBank(result, bankConfig);
    const bankId = matchedBank?.bankId || '';
    const key = `${bankId}:${result.message_id || result.messageId || ''}:${result.sources_processed?.password_file || ''}`;

    requests.set(key, {
      requestId: key,
      bankId,
      bankName: matchedBank?.name || result.matched_bank || 'Bank statement',
      messageId: result.message_id || result.messageId || '',
      filename: result.sources_processed?.password_file || '',
      reason: result.sources_processed?.password_error || 'password_required',
      accountHint: result.card_number || result.account_number || '',
    });
  }

  return Array.from(requests.values());
}

function resolveMailBank(mail: any, bankConfig: any[]) {
  const attachmentNames = (mail.attachments || [])
    .map((attachment: any) => attachment.filename || attachment.name || '')
    .join('\n');
  const searchableText =
    `${mail.subject || ''}\n${mail.from || ''}\n${mail.body || ''}\n${attachmentNames}`.toLowerCase();

  return (
    bankConfig.find((bank) => {
      const bankName = String(bank.name || '').toLowerCase();
      const bankId = String(bank.bankId || '').toLowerCase();
      return (
        (bankName && searchableText.includes(bankName)) ||
        (bankId && searchableText.includes(bankId))
      );
    }) || (bankConfig.length === 1 ? bankConfig[0] : null)
  );
}

function resolveResultBank(result: any, bankConfig: any[]) {
  const matched = String(result?.matched_bank || '').toLowerCase();

  return (
    bankConfig.find((bank) => {
      const bankName = String(bank.name || '').toLowerCase();
      const bankId = String(bank.bankId || '').toLowerCase();
      const firstWord = bankName.split(/\s+/)[0];

      return (
        (matched && (bankName.includes(matched) || matched.includes(bankName))) ||
        (firstWord && matched === firstWord) ||
        (bankId && matched === bankId)
      );
    }) || (bankConfig.length === 1 ? bankConfig[0] : null)
  );
}

function filterRelevantEmails(mailsToProcess: any[], bankConfig: any[]): any[] {
  const mailsToProcess2: any[] = [];

  for (let i = 0; i < mailsToProcess.length; i++) {
    const mail = mailsToProcess[i];

    const body = mail.body || '';
    const subject = mail.subject || '';
    const from = mail.from || '';

    const hasPdfAttachment = (mail.attachments || []).some(
      (attachment: any) =>
        String(attachment.filename || '')
          .toLowerCase()
          .endsWith('.pdf') || String(attachment.mimeType || '').toLowerCase() === 'application/pdf'
    );

    if (body || hasPdfAttachment) {
      const attachmentNames = (mail.attachments || [])
        .map((attachment: any) => attachment.filename || attachment.name || '')
        .join('\n');

      const searchableText = `
${subject}
${from}
${body}
${attachmentNames}
`;

      const hasBank = bankConfig.some((bank) =>
        searchableText.toLowerCase().includes(bank.name.toLowerCase())
      );

      if (hasBank || hasPdfAttachment) {
        mailsToProcess2.push(mail);
      }
    }
  }

  return mailsToProcess2;
}

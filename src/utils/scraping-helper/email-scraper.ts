import { getNinetyDaysAgo, getNHoursAgo } from './get-time-date';
import { extractWithPython } from './extract-with-python';
import EmailServiceHelper from './scraping-helper';
import { checkIsFromBank } from '../check-valid-email_data';

type StatementPassword = {
  bankId: string;
  password: string;
  email?: string;
  accountHint?: string;
};

export default async function emailScraperHelper(
  gmailClient: any,
  creditCard: any[],
  mode: 'initial' | 'incremental' = 'initial',
  statementPasswords: StatementPassword[] = []
): Promise<{ results: any[]; bankConfig: any[]; requiresPassword?: boolean; passwordRequests?: any[] }> {
  
  try{
  const gmail = gmailClient;
  const afterDate = mode === 'initial' ? getNinetyDaysAgo(2) : getNHoursAgo(12);
  const bankConfig = creditCard;
  const bankFilters: string[] = [];
  const pdfPasswordsByBank: Record<string, string[]> = {};
  const banksWithPassword = new Set(
    statementPasswords
      .filter((item) => item.password)
      .map((item) => item.bankId)
  );

  const passwordList=statementPasswords.map((e)=>e.password);


  bankConfig.map((element) => {
    const bankName = element.name.toString().toLowerCase().trim();
    const passwords = statementPasswords
      .filter((item) => item.bankId === element.bankId)
      .map((item) => item.password)
      .filter(Boolean);
    bankFilters.push(bankName);
    addPasswordsForBank(pdfPasswordsByBank, element, passwords);
  });

  const mailsToProcess: any[] = [];
  let pageToken: string | null | undefined = null;

  do {
    const listRes = await EmailServiceHelper.listEmails(
      gmail,
      [],
      afterDate,
      pageToken || undefined
    );

    const messages = listRes?.data?.messages || [];
    pageToken = listRes?.data?.nextPageToken;

    const messageResults = await Promise.allSettled(
      messages.map(async (msg: any) => {
        try {
          const meta = await EmailServiceHelper.getEmailDetails(
            gmail,
            msg.id
          );
          const headers = meta?.data?.payload?.headers || [];
          const fromHeader =
            (headers.find((h: any) => h.name === 'From') || {}).value || '';
          const subjectHeader =
            (headers.find((h: any) => h.name === 'Subject') || {}).value || '';


          const bankCheck = checkIsFromBank(fromHeader, subjectHeader,bankConfig);
          if (!bankCheck.isFromBank) return null;



          const { body, attachments } = await EmailServiceHelper.extractEmailBody(
            gmail,
            msg,
            meta.data.payload,
            passwordList
          );

          const preparedAttachments = (
            await Promise.allSettled(
              (attachments || []).map(async (att: any) => {
                try {
                  let filename = att.filename || att.name || 'attachment';
                  let mimeType = att.mimeType || att.mime || 'application/octet-stream';
                  let dataBase64 = att.data || null;

                  const helperAny = EmailServiceHelper as any;

                  if (
                    !dataBase64 &&
                    att.attachmentId &&
                    typeof helperAny.getAttachment === 'function'
                  ) {
                    dataBase64 = await helperAny.getAttachment(
                      gmail,
                      msg.id,
                      att.attachmentId
                    );
                  }

                  if (!dataBase64) return null;

                  return { ...att, filename, mimeType, data: dataBase64 };
                } catch (err) {
                  return null;
                }
              })
            )
          )
            .map((res) => (res.status === 'fulfilled' ? res.value : null))
            .filter(Boolean) as any[];
          const uniqueAttachments = new Map<string, any>();
          [...(attachments || []), ...preparedAttachments].forEach((attachment: any) => {
            const key = [
              attachment.filename || attachment.name || '',
              attachment.mimeType || attachment.mime || '',
              attachment.data || '',
            ].join(':');
            if (!uniqueAttachments.has(key)) {
              uniqueAttachments.set(key, attachment);
            }
          });

          return {
            messageId: msg.id,
            subject: subjectHeader || '',
            from: fromHeader || '',
            body: body || '',
            attachments: Array.from(uniqueAttachments.values()),
          };
        } catch (err) {
          return null;
        }
      })
    );
    mailsToProcess.push(
      ...messageResults
        .map((r) => (r.status === 'fulfilled' ? r.value : null))
        .filter(Boolean)
    );
  } while (pageToken);
  
  if (!mailsToProcess.length) {
    return { results: [], bankConfig };
  }

  let results: any[] = [];

  const mailsToProcess2: any[] = [];

  for (let i = 0; i < mailsToProcess.length; i++) {
    const mail = mailsToProcess[i];
    const body = mail.body || '';
    const subject = mail.subject || '';
    const from = mail.from || '';
    const hasPdfAttachment = (mail.attachments || []).some((attachment: any) =>
      String(attachment.filename || '').toLowerCase().endsWith('.pdf') ||
      String(attachment.mimeType || '').toLowerCase() === 'application/pdf'
    );

    if (body || hasPdfAttachment) {
      const attachmentNames = (mail.attachments || [])
        .map((attachment: any) => attachment.filename || attachment.name || '')
        .join('\n');
      const searchableText = `${subject}\n${from}\n${body}\n${attachmentNames}`;
      const hasBank = bankConfig.some((bank) =>
        searchableText.toLowerCase().includes(bank.name.toLowerCase())
      );

      if (hasBank || hasPdfAttachment) {
        mailsToProcess2.push(mail);
      }
    }
  }

  const missingPasswordRequests = buildPasswordRequestsForProtectedAttachments(
    mailsToProcess2,
    bankConfig,
    banksWithPassword
  );

  if (missingPasswordRequests.length > 0) {
    return {
      results: [],
      bankConfig,
      requiresPassword: true,
      passwordRequests: missingPasswordRequests,
    };
  }
  
  for (const mail of mailsToProcess2) {
    const extracted = await extractWithPython(mail, bankFilters, pdfPasswordsByBank);
    results.push(extracted);
  }

  const parserPasswordRequests = buildPasswordRequestsFromParserResults(results, bankConfig);
  if (parserPasswordRequests.length > 0) {
    return {
      results: [],
      bankConfig,
      requiresPassword: true,
      passwordRequests: parserPasswordRequests,
    };
  }

  return { results, bankConfig };
}catch (error) {
  console.error('Error in emailScraperHelper:', error);
  throw error;
}

}

function addPasswordsForBank(
  passwordMap: Record<string, string[]>,
  bank: any,
  passwords: string[]
) {
  const aliases = new Set<string>();
  const bankName = String(bank.name || '').trim();
  const bankId = String(bank.bankId || '').trim();

  [bankName, bankName.toLowerCase(), bankId, bankId.toLowerCase()].forEach((alias) => {
    if (alias) aliases.add(alias);
  });

  const firstWord = bankName.split(/\s+/)[0];
  if (firstWord) {
    aliases.add(firstWord);
    aliases.add(firstWord.toLowerCase());
  }

  for (const alias of aliases) {
    passwordMap[alias] = mergeUnique(passwordMap[alias] || [], passwords);
  }
}

function mergeUnique(existing: string[], incoming: string[]) {
  return Array.from(new Set([...existing, ...incoming].filter(Boolean)));
}

function buildPasswordRequestsForProtectedAttachments(
  mails: any[],
  bankConfig: any[],
  banksWithPassword: Set<string>
) {
  const requests = new Map<string, any>();

  for (const mail of mails) {
    const protectedAttachments = (mail.attachments || []).filter((attachment: any) =>
      attachment.requiresPassword
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

function buildPasswordRequestsFromParserResults(results: any[], bankConfig: any[]) {
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
  const searchableText = `${mail.subject || ''}\n${mail.from || ''}\n${mail.body || ''}\n${attachmentNames}`.toLowerCase();

  return bankConfig.find((bank) => {
    const bankName = String(bank.name || '').toLowerCase();
    const bankId = String(bank.bankId || '').toLowerCase();
    return (
      (bankName && searchableText.includes(bankName)) ||
      (bankId && searchableText.includes(bankId))
    );
  }) || (bankConfig.length === 1 ? bankConfig[0] : null);
}

function resolveResultBank(result: any, bankConfig: any[]) {
  const matched = String(result?.matched_bank || '').toLowerCase();

  return bankConfig.find((bank) => {
    const bankName = String(bank.name || '').toLowerCase();
    const bankId = String(bank.bankId || '').toLowerCase();
    const firstWord = bankName.split(/\s+/)[0];

    return (
      (matched && (bankName.includes(matched) || matched.includes(bankName))) ||
      (firstWord && matched === firstWord) ||
      (bankId && matched === bankId)
    );
  }) || (bankConfig.length === 1 ? bankConfig[0] : null);
}

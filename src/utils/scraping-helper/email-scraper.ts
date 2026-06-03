import { getNinetyDaysAgo, getNHoursAgo } from './get-time-date';
import { extractWithPython } from './extract-with-python';
import EmailServiceHelper from './scraping-helper';

export default async function emailScraperHelper(
  gmailClient: any,
  creditCard: any[],
  mode: 'initial' | 'incremental' = 'initial',
  statementPasswords: Array<{ bankId: string; password: string }> = []
): Promise<{ results: any[]; bankConfig: any[]; requiresPassword?: boolean; passwordRequests?: any[] }> {
  
  try{
  const gmail = gmailClient;
  const afterDate = mode === 'initial' ? getNinetyDaysAgo(1) : getNHoursAgo(12);
  const bankConfig = creditCard;
  const bankFilters: string[] = [];
  const pdfPasswordsByBank: Record<string, string[]> = {"HDFCLtd-FIP": ['Nilesh9849']};
  const banksWithPassword = new Set(
    statementPasswords
      .filter((item) => item.password)
      .map((item) => item.bankId)
  );

  bankConfig.map((element) => {
    const bankName = element.name.toString().toLowerCase().trim();
    const passwords = statementPasswords
      .filter((item) => item.bankId === element.bankId)
      .map((item) => item.password)
      .filter(Boolean);

    bankFilters.push(bankName);
    pdfPasswordsByBank[bankName] = passwords;
    pdfPasswordsByBank[element.bankId] = passwords;
  });
 console.log(bankConfig);
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

          const { body, attachments } = await EmailServiceHelper.extractEmailBody(
            gmail,
            msg,
            meta.data.payload
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

  // const passwordRequests = buildPasswordRequestsForProtectedAttachments(
  //   mailsToProcess2,
  //   bankConfig,
  //   banksWithPassword
  // );

  // // if (passwordRequests.length > 0) {
  // //   return {
  // //     results: [],
  // //     bankConfig,
  // //     requiresPassword: true,
  // //     passwordRequests,
  // //   };
  // // }
  
  console.log(mailsToProcess2.length, 'emails to process with Python');
  for (const mail of mailsToProcess2) {
    console.log('Processing email with subject:', mail.body);
    const extracted = await extractWithPython(mail, bankFilters, {"HDFCLtd-FIP": ["MARU8465",'Nilesh9849',]});
    results.push(extracted);
  }

  return { results, bankConfig };
}catch (error) {
  console.error('Error in emailScraperHelper:', error);
  throw error;
}

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

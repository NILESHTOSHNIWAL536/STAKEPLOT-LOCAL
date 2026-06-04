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

    if (processed.requiresPassword) {
      return {
        results: [],
        bankConfig: config.bankConfig,
        requiresPassword: true,
        passwordRequests: processed.passwordRequests,
      };
    }

    return {
      results: processed.results || [],
      bankConfig: config.bankConfig,
    };

  } catch (error) {
    console.error('Error in emailScraperHelper:', error);

    throw error;
  }
}

// export async function emailScraperHelpe(
//   gmailClient: any,
//   creditCard: any[],
//   mode: 'initial' | 'incremental' = 'initial',
//   statementPasswords: StatementPasswordInput[] = []
// ): Promise<{
//   results: any[];
//   bankConfig: any[];
//   requiresPassword?: boolean;
//   passwordRequests?: any[];
// }> {
//   try {
//     const gmail = gmailClient;
//     const afterDate = mode === 'initial' ? getNinetyDaysAgo(2) : getNHoursAgo(12);
//     const bankConfig = creditCard;
//     const bankFilters: string[] = [];
//     const pdfPasswordsByBank: Record<string, string[]> = {};
//     const banksWithPassword = new Set(
//       statementPasswords.filter((item) => item.password).map((item) => item.bankId)
//     );

//     const passwordList = statementPasswords.map((e) => e.password);

//     bankConfig.map((element) => {
//       const bankName = element.name.toString().toLowerCase().trim();
//       const passwords = statementPasswords
//         .filter((item) => item.bankId === element.bankId)
//         .map((item) => item.password)
//         .filter(Boolean);
//       bankFilters.push(bankName);
//       addPasswordsForBank(pdfPasswordsByBank, element, passwords);
//     });

//     const mailsToProcess: any[] = [];
//     let pageToken: string | null | undefined = null;

//     do {
//       const listRes = await EmailServiceHelper.listEmails(
//         gmail,
//         [],
//         afterDate,
//         pageToken || undefined
//       );

//       const messages = listRes?.data?.messages || [];
//       pageToken = listRes?.data?.nextPageToken;

//       const messageResults = await Promise.allSettled(
//         messages.map(async (msg: any) => {
//           try {
//             const meta = await EmailServiceHelper.getEmailDetails(gmail, msg.id);
//             const headers = meta?.data?.payload?.headers || [];
//             const fromHeader = (headers.find((h: any) => h.name === 'From') || {}).value || '';
//             const subjectHeader =
//               (headers.find((h: any) => h.name === 'Subject') || {}).value || '';

//             const bankCheck = checkIsFromBank(fromHeader, subjectHeader, bankConfig);
//             if (!bankCheck.isFromBank) return null;

//             const { body, attachments } = await EmailServiceHelper.extractEmailBody(
//               gmail,
//               msg,
//               meta.data.payload,
//               passwordList
//             );

//             const preparedAttachments = (
//               await Promise.allSettled(
//                 (attachments || []).map(async (att: any) => {
//                   try {
//                     let filename = att.filename || att.name || 'attachment';
//                     let mimeType = att.mimeType || att.mime || 'application/octet-stream';
//                     let dataBase64 = att.data || null;

//                     const helperAny = EmailServiceHelper as any;

//                     if (
//                       !dataBase64 &&
//                       att.attachmentId &&
//                       typeof helperAny.getAttachment === 'function'
//                     ) {
//                       dataBase64 = await helperAny.getAttachment(gmail, msg.id, att.attachmentId);
//                     }

//                     if (!dataBase64) return null;

//                     return { ...att, filename, mimeType, data: dataBase64 };
//                   } catch (err) {
//                     return null;
//                   }
//                 })
//               )
//             )
//               .map((res) => (res.status === 'fulfilled' ? res.value : null))
//               .filter(Boolean) as any[];
//             const uniqueAttachments = new Map<string, any>();
//             [...(attachments || []), ...preparedAttachments].forEach((attachment: any) => {
//               const key = [
//                 attachment.filename || attachment.name || '',
//                 attachment.mimeType || attachment.mime || '',
//                 attachment.data || '',
//               ].join(':');
//               if (!uniqueAttachments.has(key)) {
//                 uniqueAttachments.set(key, attachment);
//               }
//             });

//             return {
//               messageId: msg.id,
//               subject: subjectHeader || '',
//               from: fromHeader || '',
//               body: body || '',
//               attachments: Array.from(uniqueAttachments.values()),
//             };
//           } catch (err) {
//             return null;
//           }
//         })
//       );
//       mailsToProcess.push(
//         ...messageResults.map((r) => (r.status === 'fulfilled' ? r.value : null)).filter(Boolean)
//       );
//     } while (pageToken);

//     if (!mailsToProcess.length) {
//       return { results: [], bankConfig };
//     }

//     let results: any[] = [];

//     const mailsToProcess2: any[] = [];

//     for (let i = 0; i < mailsToProcess.length; i++) {
//       const mail = mailsToProcess[i];
//       const body = mail.body || '';
//       const subject = mail.subject || '';
//       const from = mail.from || '';
//       const hasPdfAttachment = (mail.attachments || []).some(
//         (attachment: any) =>
//           String(attachment.filename || '')
//             .toLowerCase()
//             .endsWith('.pdf') ||
//           String(attachment.mimeType || '').toLowerCase() === 'application/pdf'
//       );

//       if (body || hasPdfAttachment) {
//         const attachmentNames = (mail.attachments || [])
//           .map((attachment: any) => attachment.filename || attachment.name || '')
//           .join('\n');
//         const searchableText = `${subject}\n${from}\n${body}\n${attachmentNames}`;
//         const hasBank = bankConfig.some((bank) =>
//           searchableText.toLowerCase().includes(bank.name.toLowerCase())
//         );

//         if (hasBank || hasPdfAttachment) {
//           mailsToProcess2.push(mail);
//         }
//       }
//     }

//     const missingPasswordRequests = buildPasswordRequestsForProtectedAttachments(
//       mailsToProcess2,
//       bankConfig,
//       banksWithPassword
//     );

//     if (missingPasswordRequests.length > 0) {
//       return {
//         results: [],
//         bankConfig,
//         requiresPassword: true,
//         passwordRequests: missingPasswordRequests,
//       };
//     }

//     for (const mail of mailsToProcess2) {
//       const extracted = await extractWithPython(mail, bankFilters, pdfPasswordsByBank);
//       results.push(extracted);
//     }

//     const parserPasswordRequests = buildPasswordRequestsFromParserResults(results, bankConfig);
//     if (parserPasswordRequests.length > 0) {
//       return {
//         results: [],
//         bankConfig,
//         requiresPassword: true,
//         passwordRequests: parserPasswordRequests,
//       };
//     }

//     return { results, bankConfig };
//   } catch (error) {
//     console.error('Error in emailScraperHelper:', error);
//     throw error;
//   }
// }



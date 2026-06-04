// import pdfParse from 'pdf-parse';

// type ExtractedAttachment = {
//   filename: string;
//   mimeType: string;
//   data: string;
//   requiresPassword?: boolean;
//   passwordError?: string;
// };

// export const listEmails = async (
//   gmail: any,
//   labelIds: string[],
//   afterDate: string | number,
//   pageToken: string | null = null
// ): Promise<any> => {
//   const tomorrow = new Date();
//   tomorrow.setDate(tomorrow.getDate() + 1);

//   const beforeDate = `${tomorrow.getFullYear()}/${tomorrow.getMonth() + 1}/${tomorrow.getDate()}`;
//   const categoryFilter = [
//     'in:inbox',
//     'is:important',
//     '-category:promotions',
//     '-category:social',
//     '-category:updates',
//     '-category:forums',
//   ].join(' ');

//   return gmail.users.messages.list({
//     userId: 'me',
//     maxResults: 100,
//     labelIds: ['INBOX'],
//     q: `${categoryFilter} after:${afterDate} before:${beforeDate}`,
//     pageToken: pageToken || undefined,
//   });
// };

// export const getEmailDetails = async (
//   gmail: any,
//   messageId: string
// ): Promise<any> => {
//   return await gmail.users.messages.get({
//     userId: 'me',
//     id: messageId,
//     format: 'full',
//   });
// };

// function decodeBase64(data: string): string {
//   return Buffer.from(normalizeGmailBase64(data), 'base64').toString('utf8');
// }

// function normalizeGmailBase64(data: string): string {
//   const normalized = String(data || '').replace(/-/g, '+').replace(/_/g, '/');
//   return normalized + '='.repeat((4 - (normalized.length % 4)) % 4);
// }

// function isPdfPasswordError(err: unknown): boolean {
//   const message = String((err as any)?.message || err || '').toLowerCase();
//   return (
//     message.includes('password') ||
//     message.includes('encrypted') ||
//     message.includes('decrypt') ||
//     message.includes('unsupported encryption')
//   );
// }

// function hasPdfEncryptionMarker(pdfBuffer: Buffer): boolean {
//   return pdfBuffer.includes(Buffer.from('/Encrypt'));
// }

// export const extractEmailBody = async (
//   gmail: any,
//   msg: any,
//   payload: any
// ): Promise<{ body: string; attachments: ExtractedAttachment[] }> => {
//   let body = '';
//   let attachments: ExtractedAttachment[] = [];

//   try {
//     const walkParts = async (parts: any[]): Promise<void> => {
//       for (const part of parts) {
//         if (
//           (part.mimeType === 'text/plain' ||
//             part.mimeType === 'text/html') &&
//           part.body?.attachmentId
//         ) {
//           const attachment = await gmail.users.messages.attachments.get({
//             userId: 'me',
//             messageId: msg.id,
//             id: part.body.attachmentId,
//           });

//           if (attachment?.data?.data) {
//             body += '\n' + decodeBase64(attachment.data.data);
//           }
//         } else if (part.mimeType === 'text/plain' && part.body?.data) {
//           body += '\n' + decodeBase64(part.body.data);
//         } else if (part.mimeType === 'text/html' && part.body?.data) {
//           body += '\n' + decodeBase64(part.body.data);
//         } else if (
//           part.filename &&
//           part.mimeType === 'application/pdf'
//         ) {
//           const attachId = part.body.attachmentId;
//           const attachment = await gmail.users.messages.attachments.get({
//             userId: 'me',
//             messageId: msg.id,
//             id: attachId,
//           });

//           const pdfBuffer = Buffer.from(normalizeGmailBase64(attachment.data.data), 'base64');
//           const extractedAttachment: ExtractedAttachment = {
//             filename: part.filename,
//             mimeType: part.mimeType,
//             data: attachment.data.data,
//           };

//           if (hasPdfEncryptionMarker(pdfBuffer)) {
//             extractedAttachment.requiresPassword = true;
//             extractedAttachment.passwordError = 'password_required';
//           } else {
//             try {
//               const pdfData = await pdfParse(pdfBuffer);
//               body += '\n' + (pdfData as any).text;
//             } catch (err) {
//               if (isPdfPasswordError(err)) {
//                 extractedAttachment.requiresPassword = true;
//                 extractedAttachment.passwordError = 'password_required';
//               } else {
//                 extractedAttachment.passwordError = 'pdf_parse_failed';
//               }
//             }
//           }

//           attachments.push(extractedAttachment);
//         } else if (
//           part.filename &&
//           part.mimeType &&
//           part.mimeType.startsWith('image/')
//         ) {
//           const attachId = part.body.attachmentId;
//           const attachment = await gmail.users.messages.attachments.get({
//             userId: 'me',
//             messageId: msg.id,
//             id: attachId,
//           });

//           attachments.push({
//             filename: part.filename,
//             mimeType: part.mimeType,
//             data: attachment.data.data,
//           });
//         }

//         if (part.parts) {
//           await walkParts(part.parts);
//         }
//       }
//     };

//     if (payload.parts) {
//       await walkParts(payload.parts);
//     } else {
//       body = decodeBase64(payload.body?.data || '');
//     }
//   } catch (e) {
//     // swallow to keep behavior similar
//   }

//   return { body, attachments };
// };

// export const extractHeaders = async (
//   payload: any
// ): Promise<{ subject: string; from: string }> => {
//   const subject =
//     payload.headers.find((h: any) => h.name === 'Subject')?.value || '';
//   const from =
//     payload.headers.find((h: any) => h.name === 'From')?.value || '';
//   return { subject, from };
// };

// const EmailServiceHelper = {
//   extractHeaders,
//   extractEmailBody,
//   getEmailDetails,
//   listEmails,
// };

// export default EmailServiceHelper;



import pdfParse from 'pdf-parse';
import * as pdfjs from "pdfjs-dist/legacy/build/pdf.js";

pdfjs.GlobalWorkerOptions.workerSrc =
  `//cdnjs.cloudflare.com/ajax/libs/pdf.js/${pdfjs.version}/pdf.worker.min.js`;

type ExtractedAttachment = {
  filename: string;
  mimeType: string;
  data: string;
  requiresPassword?: boolean;
  passwordError?: string;
};

export const listEmails = async (
  gmail: any,
  labelIds: string[],
  afterDate: string | number,
  pageToken: string | null = null
): Promise<any> => {
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);

  const beforeDate = `${tomorrow.getFullYear()}/${tomorrow.getMonth() + 1}/${tomorrow.getDate()}`;
  const categoryFilter = [
    'in:inbox',
    'is:important',
    '-category:promotions',
    '-category:social',
    '-category:updates',
    '-category:forums',
  ].join(' ');

  return gmail.users.messages.list({
    userId: 'me',
    maxResults: 100,
    labelIds: ['INBOX'],
    q: `${categoryFilter} after:${afterDate} before:${beforeDate}`,
    pageToken: pageToken || undefined,
  });
};

export const getEmailDetails = async (
  gmail: any,
  messageId: string
): Promise<any> => {
  return await gmail.users.messages.get({
    userId: 'me',
    id: messageId,
    format: 'full',
  });
};

function decodeBase64(data: string): string {
  return Buffer.from(normalizeGmailBase64(data), 'base64').toString('utf8');
}

function normalizeGmailBase64(data: string): string {
  const normalized = String(data || '').replace(/-/g, '+').replace(/_/g, '/');
  return normalized + '='.repeat((4 - (normalized.length % 4)) % 4);
}

function isPdfPasswordError(err: unknown): boolean {
  const message = String((err as any)?.message || err || '').toLowerCase();
  return (
    message.includes('password') ||
    message.includes('encrypted') ||
    message.includes('decrypt') ||
    message.includes('unsupported encryption')
  );
}

function hasPdfEncryptionMarker(pdfBuffer: Buffer): boolean {
  return pdfBuffer.includes(Buffer.from('/Encrypt'));
}

/**
 * Try to parse a PDF with a specific password.
 * Returns extracted text on success, null on failure.
 */

/**
 * pdfjs-dist v6 is ESM-only and has proper AES/RC4 decryption support,
 * unlike pdf-parse which does not handle password-protected PDFs at all.
 *
 * Set the worker source to a no-op so it runs in the main thread
 * (fine for server-side Node.js usage).
 */

async function tryParsePdfWithPassword(
  pdfBuffer: Buffer,
  password: string
): Promise<string | null> {
  try {
    const loadingTask = pdfjs.getDocument({
      data: new Uint8Array(pdfBuffer),
      password,
      // Suppress pdfjs console warnings in Node
      verbosity: 0,
    });

    const pdf = await loadingTask.promise;
    const pageTexts: string[] = [];

    for (let i = 1; i <= pdf.numPages; i++) {
      const page = await pdf.getPage(i);
      const content = await page.getTextContent();
      const pageText = content.items
        .map((item: any) => ('str' in item ? item.str : ''))
        .join(' ');
      pageTexts.push(pageText);
    }

    return pageTexts.join('\n');
  } catch (err: any) {
    // PasswordException means wrong password — keep trying others
    // Any other error is a real failure
    if (err?.name === 'PasswordException') {
      return null;
    }
    // Re-throw unexpected errors so caller can log pdf_parse_failed
    throw err;
  }
}

/**
 * Try all passwords against an encrypted PDF.
 * Returns the extracted text and matched password, or null if none work.
 */
async function tryExtractEncryptedPdf(
  pdfBuffer: Buffer,
  passwords: string[]
): Promise<{ text: string; password: string } | null> {
  for (const password of [...new Set(passwords)]) {
    console.log("password");
    console.log(password);
    const text = await tryParsePdfWithPassword(pdfBuffer, password);
    console.log(text);
    if (text !== null) {
      return { text, password };
    }
  }
  return null;
}

export const extractEmailBody = async (
  gmail: any,
  msg: any,
  payload: any,
  passwordList: string[] = []
): Promise<{ body: string; attachments: ExtractedAttachment[] }> => {
  let body = '';
  let attachments: ExtractedAttachment[] = [];

  try {
    const walkParts = async (parts: any[]): Promise<void> => {
      for (const part of parts) {
        if (
          (part.mimeType === 'text/plain' ||
            part.mimeType === 'text/html') &&
          part.body?.attachmentId
        ) {
          const attachment = await gmail.users.messages.attachments.get({
            userId: 'me',
            messageId: msg.id,
            id: part.body.attachmentId,
          });

          if (attachment?.data?.data) {
            body += '\n' + decodeBase64(attachment.data.data);
          }
        } else if (part.mimeType === 'text/plain' && part.body?.data) {
          body += '\n' + decodeBase64(part.body.data);
        } else if (part.mimeType === 'text/html' && part.body?.data) {
          body += '\n' + decodeBase64(part.body.data);
        } else if (
          part.filename &&
          part.mimeType === 'application/pdf'
        ) {
          const attachId = part.body.attachmentId;
          const attachment = await gmail.users.messages.attachments.get({
            userId: 'me',
            messageId: msg.id,
            id: attachId,
          });

          const pdfBuffer = Buffer.from(normalizeGmailBase64(attachment.data.data), 'base64');
          const extractedAttachment: ExtractedAttachment = {
            filename: part.filename,
            mimeType: part.mimeType,
            data: attachment.data.data,
          };

          if (hasPdfEncryptionMarker(pdfBuffer)) {
            // PDF is encrypted — try each password from the list
        
            if (passwordList.length > 0) {
              const result = await tryExtractEncryptedPdf(pdfBuffer, passwordList);
              console.log(result);
              if (result) {
                // A password worked — append the extracted text
                body += '\n' + result.text;
                extractedAttachment.requiresPassword = false;
              } else {
                // No password worked — mark for manual review
                extractedAttachment.requiresPassword = true;
                extractedAttachment.passwordError = 'password_required';
              }
            } else {
              // No passwords provided at all
              extractedAttachment.requiresPassword = true;
              extractedAttachment.passwordError = 'password_required';
            }
          } else {
            // PDF appears unencrypted — attempt direct parse
            try {
              const pdfData = await pdfParse(pdfBuffer);
              body += '\n' + (pdfData as any).text;
            } catch (err) {
              if (isPdfPasswordError(err)) {
                // Encryption marker was absent but PDF is still password-protected
                // (some PDFs don't have /Encrypt in a detectable position)
                if (passwordList.length > 0) {
                  const result = await tryExtractEncryptedPdf(pdfBuffer, passwordList);

                  if (result) {
                    body += '\n' + result.text;
                    extractedAttachment.requiresPassword = false;
                  } else {
                    extractedAttachment.requiresPassword = true;
                    extractedAttachment.passwordError = 'password_required';
                  }
                } else {
                  extractedAttachment.requiresPassword = true;
                  extractedAttachment.passwordError = 'password_required';
                }
              } else {
                extractedAttachment.passwordError = 'pdf_parse_failed';
              }
            }
          }

          attachments.push(extractedAttachment);
        } else if (
          part.filename &&
          part.mimeType &&
          part.mimeType.startsWith('image/')
        ) {
          const attachId = part.body.attachmentId;
          const attachment = await gmail.users.messages.attachments.get({
            userId: 'me',
            messageId: msg.id,
            id: attachId,
          });

          attachments.push({
            filename: part.filename,
            mimeType: part.mimeType,
            data: attachment.data.data,
          });
        }

        if (part.parts) {
          await walkParts(part.parts);
        }
      }
    };

    if (payload.parts) {
      await walkParts(payload.parts);
    } else {
      body = decodeBase64(payload.body?.data || '');
    }
  } catch (e) {
    // swallow to keep behavior similar
  }

  return { body, attachments };
};

export const extractHeaders = async (
  payload: any
): Promise<{ subject: string; from: string }> => {
  const subject =
    payload.headers.find((h: any) => h.name === 'Subject')?.value || '';
  const from =
    payload.headers.find((h: any) => h.name === 'From')?.value || '';
  return { subject, from };
};

const EmailServiceHelper = {
  extractHeaders,
  extractEmailBody,
  getEmailDetails,
  listEmails,
};

export default EmailServiceHelper;
// const pdfParse = require('pdf-parse');

// // List emails with pagination & 90-day filter
// const listEmails = async (gmail, labelIds, afterDate, pageToken = null) => {
//   const nowDate = new Date();
//   const beforeDate = `${nowDate.getFullYear()}/${nowDate.getMonth() + 1}/${nowDate.getDate()}`;
//   const now = Math.floor(Date.now() / 1000); // current time (epoch)
//   return gmail.users.messages.list({
//     userId: 'me',
//     maxResults: 100,
//     labelIds: ['INBOX'],
//     // labelIds: ["All emails"],
//     q: `after:${afterDate} before:${now}`,
//     pageToken,
//     // includeSpamTrash: true
//   });
// };

// // Fetch single email details
// const getEmailDetails = async (gmail, messageId) => {
//   return await gmail.users.messages.get({
//     userId: 'me',
//     id: messageId,
//     format: 'full',
//   });
// };

// // Decode Base64 Gmail body
// function decodeBase64(data) {
//   return Buffer.from(data, 'base64').toString('utf8');
// }

// // Extract body text (handles plain, html, pdf)
// const extractEmailBody = async (gmail, msg, payload) => {
//   let body = '';
//   let attachments = [];
//   try {
//     if (payload.parts) {
//       for (const part of payload.parts) {
//         if ((part.mimeType === 'text/plain' || part.mimeType === 'text/html') && part.body?.attachmentId) {
//           const attachment = await gmail.users.messages.attachments.get({
//             userId: 'me',
//             messageId: msg.id,
//             id: part.body.attachmentId,
//           });
//           if (attachment?.data?.data) {
//             body = decodeBase64(attachment.data.data);
//             break;
//           }
//           if (part.parts) {
//             body = await extractBody(gmail, msgId, part);
//             if (body) break;
//           }
//         } else if (part.mimeType === 'text/plain' && part.body?.data) {
//           body = decodeBase64(part.body.data);

//           break;
//         } else if (part.mimeType === 'text/html' && part.body?.data) {
//           body = decodeBase64(part.body.data);
//         }

//         // Recursive check for nested multipart/alternative
//         else if (part.filename && part.mimeType === 'application/pdf') {
//           const attachId = part.body.attachmentId;
//           const attachment = await gmail.users.messages.attachments.get({
//             userId: 'me',
//             messageId: msg.id,
//             id: attachId,
//           });
//           const pdfBuffer = Buffer.from(attachment.data.data, 'base64');
//           const pdfData = await pdfParse(pdfBuffer);
//           body += '\n' + pdfData.text;

//           // push image as base64 string
//           attachments.push({
//             filename: part.filename,
//             mimeType: part.mimeType,
//             data: attachment.data.data, // base64 string
//           });
//         } else if (part.filename && part.mimeType.startsWith('image/')) {
//           const attachId = part.body.attachmentId;

//           const attachment = await gmail.users.messages.attachments.get({
//             userId: 'me',
//             messageId: msg.id,
//             id: attachId,
//           });
//           // push image as base64 string
//           attachments.push({
//             filename: part.filename,
//             mimeType: part.mimeType,
//             data: attachment.data.data, // base64 string
//           });
//         }
//       }
//     } else {
//       body = decodeBase64(payload.body?.data || '');
//     }
//   } catch (e) {
//    }

//   return { body: body, attachments: attachments };
// };

// // 🟢 Extract headers (subject, from, etc.)
// const extractHeaders = async (payload) => {
//   const subject = payload.headers.find((h) => h.name === 'Subject')?.value || '';
//   const from = payload.headers.find((h) => h.name === 'From')?.value || '';
//   return { subject, from };
// };

// module.exports = {
//   extractHeaders,
//   extractEmailBody,
//   getEmailDetails,
//   listEmails,
// };


import pdfParse from 'pdf-parse';

export const listEmails = async (
  gmail: any,
  labelIds: string[],
  afterDate: string | number,
  pageToken: string | null = null
): Promise<any> => {
  const nowDate = new Date();
  const beforeDate = `${nowDate.getFullYear()}/${nowDate.getMonth() + 1}/${
    nowDate.getDate()
  }`;
  const now = Math.floor(Date.now() / 1000);

  return gmail.users.messages.list({
    userId: 'me',
    maxResults: 100,
    labelIds: ['INBOX'],
    q: `after:${afterDate} before:${now}`,
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
  return Buffer.from(data, 'base64').toString('utf8');
}

export const extractEmailBody = async (
  gmail: any,
  msg: any,
  payload: any
): Promise<{ body: string; attachments: any[] }> => {
  let body = '';
  let attachments: any[] = [];

  try {
    if (payload.parts) {
      for (const part of payload.parts) {
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
            body = decodeBase64(attachment.data.data);
            break;
          }

          if (part.parts) {
            const nested = await extractEmailBody(gmail, msg, part);
            if (nested.body) {
              body = nested.body;
              attachments = attachments.concat(nested.attachments);
              break;
            }
          }
        } else if (part.mimeType === 'text/plain' && part.body?.data) {
          body = decodeBase64(part.body.data);
          break;
        } else if (part.mimeType === 'text/html' && part.body?.data) {
          body = decodeBase64(part.body.data);
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

          const pdfBuffer = Buffer.from(attachment.data.data, 'base64');
          const pdfData = await pdfParse(pdfBuffer);
          body += '\n' + (pdfData as any).text;

          attachments.push({
            filename: part.filename,
            mimeType: part.mimeType,
            data: attachment.data.data,
          });
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
      }
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

import pdfParse from 'pdf-parse';

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
  const beforeDate = `${tomorrow.getFullYear()}/${tomorrow.getMonth() + 1}/${
    tomorrow.getDate()
  }`;

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

export const extractEmailBody = async (
  gmail: any,
  msg: any,
  payload: any
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
            extractedAttachment.requiresPassword = true;
            extractedAttachment.passwordError = 'password_required';
          } else {
            try {
              const pdfData = await pdfParse(pdfBuffer);
              body += '\n' + (pdfData as any).text;
            } catch (err) {
              if (isPdfPasswordError(err)) {
                extractedAttachment.requiresPassword = true;
                extractedAttachment.passwordError = 'password_required';
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

import { checkIsFromBank } from '../check-valid-email_data';
import EmailServiceHelper from './scraping-helper';

export async function fetchAndPrepareEmails(
  gmail: any,
  afterDate: string | number,
  bankConfig: any[],
  passwordList: string[]
) {
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
          const meta = await EmailServiceHelper.getEmailDetails(gmail, msg.id);

          const headers = meta?.data?.payload?.headers || [];

          const fromHeader = (headers.find((h: any) => h.name === 'From') || {}).value || '';

          const subjectHeader = (headers.find((h: any) => h.name === 'Subject') || {}).value || '';

          const bankCheck = checkIsFromBank(fromHeader, subjectHeader, bankConfig);

          if (!bankCheck.isFromBank) {
            return null;
          }

          const { body, attachments } = await EmailServiceHelper.extractEmailBody(
            gmail,
            msg,
            meta.data.payload,
            passwordList
          );

          const preparedAttachments = (await Promise.allSettled(
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
                    dataBase64 = await helperAny.getAttachment(gmail, msg.id, att.attachmentId);
                  }

                  if (!dataBase64) {
                    return null;
                  }

                  return {
                    ...att,
                    filename,
                    mimeType,
                    data: dataBase64,
                  };
                } catch {
                  return null;
                }
              })
            )
          )
            .map((res) => (res.status === 'fulfilled' ? res.value : null))
            .filter(Boolean);

          const uniqueAttachments = new Map<string, any>();

          [...(attachments || []), ...(preparedAttachments as any[])].forEach((attachment: any) => {
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
        } catch {
          return null;
        }
      })
    );

    mailsToProcess.push(
      ...messageResults.map((r) => (r.status === 'fulfilled' ? r.value : null)).filter(Boolean)
    );
  } while (pageToken);

  return mailsToProcess;
}

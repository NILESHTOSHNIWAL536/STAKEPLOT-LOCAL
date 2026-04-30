import { performance } from 'perf_hooks';
import fs from 'fs';
import { getNinetyDaysAgo, getNHoursAgo } from './get-time-date';
import { extractWithPython } from './extract-with-python';
import EmailServiceHelper from './scraping-helper';

export default async function emailScraperHelper(
  gmailClient: any,
  creditCard: any[],
  mode: 'initial' | 'incremental' = 'initial'
): Promise<{ results: any[]; bankConfig: any[] }> {
  const startTime = performance.now();
  const gmail = gmailClient;
  const afterDate = mode === 'initial' ? getNinetyDaysAgo(10) : getNHoursAgo(12);
  const bankConfig = creditCard;
  const bankFilters: string[] = [];

  bankConfig.map((element) => {
    bankFilters.push(element.name.toString().toLowerCase().trim());
  });

  const mailsToProcess: any[] = [];
  let pageToken: string | null | undefined = null;
  let pageCount = 0;

  do {
    pageCount++;
    const pageStart = performance.now();
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

          const fromLower = fromHeader.toLowerCase();
          const subjectLower = subjectHeader.toLowerCase();
          const matches = bankFilters.some(
            (f) => f && fromLower.includes(f.toLowerCase())
          );
          const matches2 = bankFilters.some(
            (f) => f && subjectLower.includes(f.toLowerCase())
          );
         // if (!matches && !matches2) return null;

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
        let mimeType =
          att.mimeType || att.mime || 'application/octet-stream';
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

        return { filename, mimeType, data: dataBase64 };
      } catch (err) {
        return null;
      }
    })
  )
)
  .map((res) => (res.status === 'fulfilled' ? res.value : null))
  .filter(Boolean) as any[];

          return {
            messageId: msg.id,
            subject: subjectHeader || '',
            from: fromHeader || '',
            body: body || '',
            attachments: [...preparedAttachments, ...(attachments || [])],
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
    const pageEnd = performance.now();
  } while (pageToken);

  if (!mailsToProcess.length) {
    const totalTime = (performance.now() - startTime).toFixed(2);
    return { results: [], bankConfig };
  }

  let results: any[] = [];

  let output = '';
  const mailsToProcess2: any[] = [];

  for (let i = 0; i < mailsToProcess.length; i++) {
    const body = mailsToProcess[i].body;

    if (body) {
      const hasBank = bankConfig.some((bank) =>
        body.toLowerCase().includes(bank.name.toLowerCase())
      );

      if (hasBank) {
        mailsToProcess2.push(mailsToProcess[i]);
        output += body + '\n';
      }
    }
  }

  // Write output to file if environment variable is set
  const outputDir = process.env.OUTPUT_DIR || '/app/output';
  try {
    fs.writeFileSync(`${outputDir}/output.txt`, output, 'utf-8');
  } catch (err) {
    console.error('Error writing output file:', err);
  }
  console.log("mailsToProcess2",mailsToProcess2.length);

  for (const [index, mail] of mailsToProcess2.entries()) {
    const extracted = await extractWithPython(mail, bankFilters);
    results.push(extracted);
  }
  return { results, bankConfig };
}

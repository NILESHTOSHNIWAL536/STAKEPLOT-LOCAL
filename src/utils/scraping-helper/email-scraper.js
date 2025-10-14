const { performance } = require('perf_hooks');
const EmailServiceHelper = require('./scraping-helper');

async function emailScraperHelper(gmailClient, creditCard, mode = 'initial') {
  const bankConfig = creditCard;
  const startTime = performance.now();
  const gmail = gmailClient;
  const afterDate = mode === 'initial' ? getNinetyDaysAgo(1) : getNHoursAgo(12);

  // fetch bank config

  let bankFilters = [];
  if (bankConfig.name) {
    bankFilters = [bankConfig.name];
  } else {
    bankFilters = ['HDFC', 'ICICI', 'Axis', 'Slice', 'SBI'];
  }
  bankFilters = bankFilters.map((f) => f.toString().toLowerCase().trim());
  // Collect mails (raw) that match From header
  const mailsToProcess = [];
  let pageToken = null;
  let pageCount = 0;

  do {
    pageCount++;
    const pageStart = performance.now();
    const listRes = await EmailServiceHelper.listEmails(gmail, [], afterDate, pageToken);

    const messages = listRes?.data?.messages || [];
    pageToken = listRes?.data?.nextPageToken;

    // 🔑 Fetch all messages in parallel
    const messageResults = await Promise.allSettled(
      messages.map(async (msg) => {
        try {
          const meta = await EmailServiceHelper.getEmailDetails(gmail, msg.id);
          const headers = meta?.data?.payload?.headers || [];
          const fromHeader = (headers.find((h) => h.name === 'From') || {}).value || '';
          const subjectHeader = (headers.find((h) => h.name === 'Subject') || {}).value || '';
          const fromLower = fromHeader.toLowerCase();
          console.log('From:', fromLower, ' | Subject:', subjectHeader);
          const subjectLower = subjectHeader.toLowerCase();
          const matches = bankFilters.some((f) => f && fromLower.includes(f.toLowerCase()));
          const matches2 = bankFilters.some((f) => f && subjectLower.includes(f.toLowerCase()));
          if (!matches && !matches2) return null;

          // Get body + attachments
          const { body, attachments } = await EmailServiceHelper.extractEmailBody(gmail, msg, meta.data.payload);

          // 🔑 Fetch attachments in parallel
          const preparedAttachments = (
            await Promise.allSettled(
              (attachments || []).map(async (att) => {
                try {
                  let filename = att.filename || att.name || 'attachment';
                  let mimeType = att.mimeType || att.mime || 'application/octet-stream';
                  let dataBase64 = att.data || null;

                  if (!dataBase64 && att.attachmentId && typeof EmailServiceHelper.getAttachment === 'function') {
                    dataBase64 = await EmailServiceHelper.getAttachment(gmail, msg.id, att.attachmentId);
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
            .filter(Boolean);

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

    // Collect successful results
    mailsToProcess.push(...messageResults.map((r) => (r.status === 'fulfilled' ? r.value : null)).filter(Boolean));
    const pageEnd = performance.now();
  } while (pageToken);

  if (!mailsToProcess.length) {
    const totalTime = (performance.now() - startTime).toFixed(2);
    return { results: [], bankConfig };
  }

  let results = [];
  for (const [index, mail] of mailsToProcess.entries()) {
    const extracted = await extractWithPython(mail, bankConfig.name);
    results.push(extracted);
  }
  return { results, bankConfig };
}

module.exports = emailScraperHelper;

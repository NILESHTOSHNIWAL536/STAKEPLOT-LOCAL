const { performance } = require('perf_hooks');
const {getNinetyDaysAgo,getNHoursAgo } = require('./get-time-date');
const {extractWithPython } = require('./extract-with-python');
const EmailServiceHelper = require('./scraping-helper');
const fs =require ("fs");



async function emailScraperHelper(gmailClient, creditCard, mode = 'initial') {

  const startTime = performance.now();
  const gmail = gmailClient;
  const afterDate = mode === 'initial' ? getNinetyDaysAgo(0) : getNHoursAgo(12);
  
  // fetch bank config
  console.log(creditCard);
  const bankConfig = creditCard;
  let bankFilters = [];

   bankConfig.map(element =>{
        bankFilters.push(element.name.toString().toLowerCase().trim());
   });

  console.log("bankFilters");
  console.log(bankFilters);

  const mailsToProcess = [];
  let pageToken = null;
  let pageCount = 0;

  do {
    pageCount++;
    const pageStart = performance.now();
    const listRes = await EmailServiceHelper.listEmails(gmail, [], afterDate, pageToken);

    const messages = listRes?.data?.messages || [];
    pageToken = listRes?.data?.nextPageToken;
    console.log(pageCount);
    // 🔑 Fetch all messages in parallel
    const messageResults = await Promise.allSettled(
      messages.map(async (msg) => {
        try {
          const meta = await EmailServiceHelper.getEmailDetails(gmail, msg.id);
          const headers = meta?.data?.payload?.headers || [];
          const fromHeader = (headers.find((h) => h.name === 'From') || {}).value || '';
          const subjectHeader = (headers.find((h) => h.name === 'Subject') || {}).value || '';
          const fromLower = fromHeader.toLowerCase();
          // console.log('From:', fromLower, ' | Subject:', subjectHeader);
          const subjectLower = subjectHeader.toLowerCase();
          const matches = bankFilters.some((f) => f && fromLower.includes(f.toLowerCase()));
          const matches2 = bankFilters.some((f) => f && subjectLower.includes(f.toLowerCase()));
          // if (!matches && !matches2) return null;

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
    return { results: [],bankConfig };
  }

  let results = [];
  console.log("mailsToProcess");
  console.log(mailsToProcess.length);
  console.log("bankConfig.name");
  console.log(bankConfig);
  
    let output = "";
    const mailsToProcess2 = [];
    // for (let i = 0; i < mailsToProcess.length; i++) {
    //   const body = mailsToProcess[i].body;
    //   // ✅ Check if body contains the bank name
    //   if (body && body.includes(bankConfig.name)) {
    //     mailsToProcess2.push(mailsToProcess[i]); // Add the full mail object
    //     output += body + "\n";
    //   }
    // }

    for (let i = 0; i < mailsToProcess.length; i++) {
  const body = mailsToProcess[i].body;

  if (body) {
    // ✅ Check if the mail body contains any bank name from the array
    const hasBank = bankConfig.some(
      (bank) => body.toLowerCase().includes(bank.name.toLowerCase())
    );

    if (hasBank) {
      mailsToProcess2.push(mailsToProcess[i]); // Add the full mail object
      output += body + "\n";
    }
  }
}

    console.log("mailsToProcess",mailsToProcess.length);
    console.log("mailsToProcess2",mailsToProcess2.length);

  fs.writeFileSync("output.txt", output, "utf-8");
  for (const [index, mail] of mailsToProcess2.entries())
  {
    const extracted = await extractWithPython(mail,bankFilters);
    results.push(extracted);
  }
  console.log(results.length);
  return { results, bankConfig };
}

module.exports = emailScraperHelper;

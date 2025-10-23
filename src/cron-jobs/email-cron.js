const cron = require('node-cron');
const CreditCardQueue=require("../services/bull-queue-service/credit-card-transaction-queue");

cron.schedule('0 0 */12 * * *', async () => {
// cron.schedule('* * * * * *', async () => {

  try {
    // Step 1: Find users having at least one linked credit card bank
    const users = await mainDB.model('User').find({
      CreditCardLinkedBanks: { $exists: true, $ne: [] },
    });


    // Step 2: Loop through users and find GoogleAuth record
    for (const user of users) {
      const googleAuth = await emailDB.model('googleAuth').findOne({ userId: user._id });
      if (!googleAuth) {
        continue;
      }
      // Step 3: Add job to queue
      await CreditCardQueue.add({
        userId: user._id,
        bankIds: user.CreditCardLinkedBanks,
      });
    }
  } catch (error) {
    console.error("❌ Cron job error:", error);
  }
});
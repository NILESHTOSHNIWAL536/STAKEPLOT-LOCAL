const cron = require('node-cron');
const CreditCardQueue=require("../services/bull-queue-service/credit-card-transaction-queue");

cron.schedule('0 0 */12 * * *', async () => {
  console.log("🔁 Cron job started: checking users with CreditCardLinkedBanks...");

  try {
    // Step 1: Find users having at least one linked credit card bank
    const users = await mainDB.model('User').find({
      CreditCardLinkedBanks: { $exists: true, $ne: [] },
    });

    console.log(`Found ${users.length} users with linked credit cards.`);

    // Step 2: Loop through users and find GoogleAuth record
    let c=0;
    for (const user of users) {
       console.log(c++);
      const googleAuth = await emailDB.model('googleAuth').findOne({ userId: user._id });
      if (!googleAuth) {
        console.log(`⚠️ No GoogleAuth found for user: ${user._id}`);
        continue;
      }
      // Step 3: Add job to queue
      await CreditCardQueue.add({
        userId: user._id,
        bankIds: user.CreditCardLinkedBanks,
      });

      console.log(`✅ Added job for user ${user._id} with banks:`, user.CreditCardLinkedBanks);
    }
  } catch (error) {
    console.error("❌ Cron job error:", error);
  }
});
const mongoose = require("mongoose");
const { Transaction } = require("../../models");

async function deduplicateAllTransactions(userId) {
  try {
    // Step 1: Aggregate to find duplicate _ids
    const duplicates = await Transaction.aggregate([
      {
        $match: {
          userId: new mongoose.Types.ObjectId(userId),
        },
      },
      {
        $group: {
          _id: {
            narration: { $trim: { input: "$narration" } },
            transactionTimestamp: "$transactionTimestamp",
            amount: "$amount",
            accountId: "$accountId",
          },
          ids: { $push: "$_id" },
          count: { $sum: 1 },
        },
      },
      {
        $match: { count: { $gt: 1 } },
      },
      {
        $project: {
          _id: 0,
          duplicateIds: { $slice: ["$ids", 1, { $subtract: ["$count", 1] }] },
        },
      },
    ]);

    const duplicateIds = duplicates.flatMap((d) => d.duplicateIds);
    console.log("Duplicate IDs:", duplicateIds);

    // Step 2: Delete duplicates
    if (duplicateIds.length > 0) {
      const result = await Transaction.deleteMany({
        _id: { $in: duplicateIds },
      });
      console.log(`✅ Deleted ${result.deletedCount} duplicate transactions.`);
    } else {
      console.log("✅ No duplicates found for user.");
    }
  } catch (error) {
    console.error("❌ Error deduplicating transactions:", error);
  }
}

module.exports = deduplicateAllTransactions;

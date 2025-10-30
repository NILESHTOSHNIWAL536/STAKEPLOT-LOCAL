const mongoose = require('mongoose');
const { GroupedTransaction } = require('../../models/index');
const { AutoTransactionRepository } = require("../../respositories");

  
  async function saveGroupedTransactions(userId) {
    const groups = await new AutoTransactionRepository().groupSimilarTransactions(userId);

    for (const group of groups) {
      const groupKey = `${group._id.narrationPattern}_${group._id.amount}`;

      await GroupedTransaction.findOneAndUpdate(
        { userId: new mongoose.Types.ObjectId(userId), groupKey },
        {
          $set: {
            userId: new mongoose.Types.ObjectId(userId),
            groupKey,
            transactions: group.transactions,
            narrationPattern: group._id.narrationPattern,
            totalAmount: group.totalAmount,
            count: group.count,
            suggestedCategory: group.suggestedCategory || 'Untagged'
          }
        },
        { upsert: true, new: true }
      );      
    }
  }

  module.exports = saveGroupedTransactions;
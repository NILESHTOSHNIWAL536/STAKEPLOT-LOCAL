const { Transaction } = require("../../models/index");
// const getCurrentWeekRange = require("../../utils/helpers/getCurrentWeekRange");

async function getCustomDatesTransactions(userId, start, end) {
  const transactions = await Transaction.find({
    userId,
    transactionTimestamp: {
      $gte: start,
      $lte: end,
    },
    isExcluded: false,
  });

  return transactions;
}

module.exports = getCustomDatesTransactions;

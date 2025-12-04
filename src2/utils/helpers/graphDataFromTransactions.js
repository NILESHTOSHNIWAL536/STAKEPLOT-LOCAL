async function getTransactions(
  model,
  userId,
  startDate,
  endDate,
  groupBy = "day",
  accountId = null
) {
  const dateFormat = groupBy === "month" ? "%Y-%m" : "%Y-%m-%d";

  const matchCondition = {
    userId,
    transactionTimestamp: {
      $gte: new Date(startDate),
      $lte: new Date(endDate),
    },
    isExcluded: false,
  };

  // Add accountId condition if provided
  if (accountId) {
    matchCondition.accountId = accountId;
  }

  const response = await model.aggregate([
    { $match: matchCondition },
    {
      $group: {
        _id: {
          date: {
            $dateToString: {
              format: dateFormat,
              date: "$transactionTimestamp",
            },
          },
        },
        debit: {
          $sum: { $cond: [{ $eq: ["$type", "DEBIT"] }, "$amount", 0] },
        },
        credit: {
          $sum: { $cond: [{ $eq: ["$type", "CREDIT"] }, "$amount", 0] },
        },
      },
    },
    { $sort: { "_id.date": 1 } },
  ]);

  return response;
}

module.exports = { getTransactions };

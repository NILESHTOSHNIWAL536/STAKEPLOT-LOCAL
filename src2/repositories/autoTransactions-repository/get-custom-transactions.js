const { Transaction } = require('../../models/index');
const CrudRepository = require('../crud-repository');

class GetCustomDatesTransactions extends CrudRepository {
  constructor() {
    super(Transaction);
  }

  async getCustomDatesTransactions(userId, start, end) {
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
}

module.exports = GetCustomDatesTransactions;

import CrudRepository from '../crud-repository';
import { Transaction } from '@/models';
import { IBankTransaction } from '@/types/bank';

class GetCustomDatesTransactions extends CrudRepository<typeof Transaction> {
  constructor() {
    super(Transaction);
  }

  async getCustomDatesTransactions(userId: string, start: Date | string, end: Date | string): Promise<IBankTransaction[]> {
    const transactions = await Transaction.find({
      userId,
      transactionTimestamp: {
        $gte: start,
        $lte: end,
      },
      isExcluded: false,
    });

    return transactions as IBankTransaction[];
  }
}

export default GetCustomDatesTransactions;

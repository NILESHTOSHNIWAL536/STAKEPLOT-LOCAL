import { Transaction } from '../models';
import CrudRepository from './crud-repository';
import mongoose, { Types, PipelineStage } from 'mongoose';
import AppError from '@/utils/errors/app-error';
import { StatusCodes } from 'http-status-codes';
import { IBankTransaction } from '@/types/bank';

class TransactionRepository extends CrudRepository<typeof Transaction> {
  constructor() {
    super(Transaction);
  }

  // ----------------------------------------------------
  // APPEND A NEW TRANSACTION ENTRY TO USER DOCUMENT
  // ----------------------------------------------------
  async updateTransactions(userId: string, transactionData: IBankTransaction): Promise<IBankTransaction> {
    const result: any = await Transaction.findOne({ userId });

    if (!result) {
      throw new AppError('No transactions found for this user', StatusCodes.NOT_FOUND);
    }

    result.Transactions.push(transactionData);
    await result.save();

    return result as unknown as IBankTransaction;
  }

  // ----------------------------------------------------
  // FETCH RECENT USER TRANSACTIONS (70)
  // ----------------------------------------------------
  async dayWiseTransactions(user: { _id: string }): Promise<IBankTransaction[]> {
    return (await Transaction.find({ userId: user._id }).sort({ createdAt: -1 }).limit(70)) as IBankTransaction[];
  }

  // ----------------------------------------------------
  // COUNT UNIQUE DAYS WITH EXPENSES RECORDED
  // ----------------------------------------------------
  async expensesRecordedDays(user: { _id: string }): Promise<number> {
    const pipeline = [
      { $match: { userId: user._id } },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
            day: { $dayOfMonth: '$createdAt' },
          },
        },
      },
      { $count: 'uniqueInsertDays' },
    ];

    const result = await Transaction.aggregate(pipeline);

    return result.length > 0 ? result[0].uniqueInsertDays : 0;
  }

  // ----------------------------------------------------
  // TOTAL MONTHLY EXPENSES (PREVIOUS MONTH)
  // ----------------------------------------------------
  async totalMonthlyExpenses(user: { _id: string }): Promise<number> {
    const now = new Date();
    const firstDayPrev = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const lastDayPrev = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59, 999);

    const pipeline = [
      {
        $match: {
          userId: user._id,
          createdAt: { $gte: firstDayPrev, $lte: lastDayPrev },
        },
      },
      {
        $group: {
          _id: null,
          totalAmount: { $sum: '$amount' },
        },
      },
    ];

    const result = await Transaction.aggregate(pipeline);

    return result.length > 0 ? result[0].totalAmount : 0;
  }

  // ----------------------------------------------------
  // COUNT DOCUMENTS (Debt Only)
  // ----------------------------------------------------
  async countDocuments(user: { _id: string }): Promise<number> {
    return Transaction.countDocuments({ userId: user._id, isDebt: true });
  }

  // ----------------------------------------------------
  // GET ALL TRANSACTIONS FROM A ROOM
  // ----------------------------------------------------
  async getRoomTransactions(roomId: string): Promise<IBankTransaction[]> {
    return (await Transaction.find({
      'room.id': roomId,
      room: { $exists: true },
    }).sort({ createdAt: -1 })) as IBankTransaction[];
  }

  // ----------------------------------------------------
  // GET ALL USER TRANSACTIONS
  // ----------------------------------------------------
  async getAllTransactions(userId: string): Promise<IBankTransaction[]> {
    try {
      return (await Transaction.find({ userId })) as IBankTransaction[];
    } catch (error: any) {
      throw new AppError(`Cannot fetch transactions: ${error}`, StatusCodes.INTERNAL_SERVER_ERROR);
    }
  }

  // ----------------------------------------------------
  // GROUP TRANSACTIONS BY CATEGORY
  // ----------------------------------------------------
  async groupTransactions(userId: string | Types.ObjectId) {
    const pipeline: PipelineStage[] = [
      {
        $match: { userId: new mongoose.Types.ObjectId(userId) },
      } as PipelineStage.Match,

      {
        $sort: { createdAt: -1 },
      } as PipelineStage.Sort,

      {
        $group: {
          _id: { category: '$category' },
          totalTransactions: { $sum: 1 },
          totalAmount: { $sum: '$amount' },
          latestTransactionDate: { $first: '$createdAt' },
        },
      } as PipelineStage.Group,

      {
        $sort: { latestTransactionDate: -1 },
      } as PipelineStage.Sort,
    ];

    return Transaction.aggregate(pipeline);
  }

  // ----------------------------------------------------
  // DELETE A SPECIFIC TRANSACTION ENTRY (FROM Sub-Array)
  // ----------------------------------------------------
  async deleteSpecificTransaction(userId: string, transactionId: string): Promise<{ message: string }> {
    const result = await Transaction.updateOne({ userId, 'Transactions._id': transactionId }, { $pull: { Transactions: { _id: transactionId } } });

    if (result.modifiedCount === 0) {
      throw new AppError('Transaction not found or does not belong to the user', StatusCodes.NOT_FOUND);
    }

    return { message: 'Transaction deleted successfully' };
  }

  // ----------------------------------------------------
  // UPDATE GROUP TRANSACTION
  // ----------------------------------------------------
  async updateGroupTransaction(userId: string, transactionId: string, body: { amount: number }) {
    try {
      const result = await Transaction.updateOne(
        { userId, _id: transactionId },
        {
          $set: {
            balanceOut: Math.abs(body.amount),
            isBalanceOut: true,
          },
        }
      );

      if (result.modifiedCount === 0) {
        return {
          success: false,
          message: 'Transaction not found or already updated.',
        };
      }

      return {
        success: true,
        message: 'Transaction updated successfully.',
      };
    } catch (e) {
      console.error('Error updating group transaction:', e);
      return {
        success: false,
        message: 'Something went wrong. Please try again later.',
      };
    }
  }
}

export default TransactionRepository;

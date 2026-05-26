import mongoose, { ClientSession } from 'mongoose';
import logger from '@/utils/common/logger';

const txOptions: mongoose.mongo.TransactionOptions = {
  readPreference: 'primary',
  readConcern: { level: 'snapshot' },
  writeConcern: { w: 'majority' },
};

/**
 * Runs `fn` inside a single MongoDB multi-document transaction.
 * All Mongoose operations inside `fn` must receive the `session` argument.
 * Operations OUTSIDE the fn (after this call returns) are not part of the transaction.
 *
 * Usage:
 *   const result = await runInTransaction(async (session) => {
 *     await Model.create([doc], { session });
 *     await Other.deleteMany({ ... }).session(session);
 *     return something;
 *   });
 *
 * Requires MongoDB to be running as a replica set (Atlas always qualifies).
 */
let transactionSupport: boolean | null = null;

async function supportsTransactions(): Promise<boolean> {
  if (transactionSupport !== null) return transactionSupport;

  const db = mongoose.connection.db;
  if (!db) {
    transactionSupport = false;
    return transactionSupport;
  }

  try {
    const hello = await db.admin().command({ hello: 1 });
    transactionSupport = Boolean(hello.setName || hello.msg === 'isdbgrid');
  } catch {
    try {
      const isMaster = await db.admin().command({ isMaster: 1 });
      transactionSupport = Boolean(isMaster.setName || isMaster.msg === 'isdbgrid');
    } catch {
      transactionSupport = false;
    }
  }

  if (!transactionSupport) {
    logger.warn('MongoDB transactions are unavailable on this connection; running operation without a transaction.');
  }

  return transactionSupport;
}

export async function runInTransaction<T>(fn: (session?: ClientSession) => Promise<T>): Promise<T> {
  if (!(await supportsTransactions())) {
    return fn();
  }

  const session = await mongoose.startSession();
  let result: T;
  try {
    await session.withTransaction(async () => {
      result = await fn(session);
    }, txOptions);
    return result!;
  } finally {
    await session.endSession();
  }
}

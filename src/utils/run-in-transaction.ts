import mongoose, { ClientSession } from 'mongoose';

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
export async function runInTransaction<T>(fn: (session: ClientSession) => Promise<T>): Promise<T> {
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

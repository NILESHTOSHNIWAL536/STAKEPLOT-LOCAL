import mongoose from 'mongoose';
import Collection, { ICollection } from '../models/collections/collection.model';
import CollectionMember from '../models/collections/collection-member.model';
import CollectionTransaction from '../models/collections/collection-transaction.model';
import Split, { ISplitItem } from '../models/collections/split.model';
import SplitPayment from '../models/collections/split-payment.model';
import BankTransaction from '../models/transactions-automation/transaction';
import AppError from '../utils/errors/app-error';
import { StatusCodes } from 'http-status-codes';
import UserService from './user-service';
import { enrichTransactionWithBankDetails } from '@/helpers/enrich-bank.helper';
import FipRepository from '@/repositories/autoTransactions-repository/bank';

const MAX_COLLECTIONS_PER_USER = 5;

const transactionOptions: mongoose.mongo.TransactionOptions = {
  readPreference: 'primary',
  readConcern: { level: 'snapshot' },
  writeConcern: { w: 'majority' },
};

const runInTransaction = async <T>(fn: (session: mongoose.ClientSession) => Promise<T>): Promise<T> => {
  const session = await mongoose.startSession();
  try {
    let result: T;
    await session.withTransaction(async () => {
      result = await fn(session);
    }, transactionOptions);
    // `result` is definitely assigned inside the transaction callback
    return result!;
  } finally {
    await session.endSession();
  }
};

// Helper function to calculate member spending metrics
const calculateMemberSpending = (userId: string, splits: any[]) => {
  let totalAmountPaid = 0;
  let totalAmountOwed = 0;
  let numberOfSplits = 0;
  const splitBreakdown = [];

  splits.forEach((split) => {
    const paidBy = split.paidBy.toString();
    const isUserPayer = paidBy === userId;
    const userInSplit = split.splits.find((s: any) => s.userId?.toString() === userId);

    if (isUserPayer || userInSplit) {
      numberOfSplits++;

      if (isUserPayer) {
        const totalSplitAmount = split.splits.reduce((sum: number, s: any) => sum + (s.amount || 0), 0);
        totalAmountPaid += totalSplitAmount;
      }

      if (userInSplit) {
        totalAmountOwed += userInSplit.amount || 0;
      }

      splitBreakdown.push({
        splitId: split._id,
        totalAmount: split.splits.reduce((sum: number, s: any) => sum + (s.amount || 0), 0),
        paidBy: split.paidBy,
        userAmount: userInSplit?.amount || 0,
        userPaid: isUserPayer,
        splitType: split.splitType,
        createdAt: split.createdAt,
      });
    }
  });

  return {
    totalAmountPaid,
    totalAmountOwed,
    numberOfSplits,
    netAmount: totalAmountPaid - totalAmountOwed,
    splitBreakdown,
  };
};

// Format splits with member-specific spending details
const formatSplitsWithMemberDetails = (splits: any[], userId: string, userMap: Map<string, any>) => {
  return splits.map((split) => {
    const totalSplitAmount = split.splits.reduce((sum: number, si: any) => sum + (si.amount || 0), 0);
    const userSplitItem = split.splits.find((si: any) => si.userId?.toString() === userId);

    return {
      _id: split._id,
      collectionId: split.collectionId,
      splitType: split.splitType,
      totalAmount: totalSplitAmount,
      userAmount: userSplitItem?.amount || 0,
      isPayer: split.paidBy.toString() === userId,
      paidBy: split.paidBy,
      paidByUser: userMap.get(split.paidBy.toString()) || { _id: split.paidBy },
      splits: split.splits.map((si: any) => ({
        userId: si.userId,
        amount: si.amount,
        user: userMap.get(si.userId.toString()) || { _id: si.userId },
      })),
      createdAt: split.createdAt,
      updatedAt: split.updatedAt,
    };
  });
};

export const createCollection = async (userId: string, data: any, friends: IFriendInput[] = []) => {
  const counts = await CollectionMember.aggregate([
    { $match: { userId } },
    {
      $lookup: {
        from: 'collections',
        localField: 'collectionId',
        foreignField: '_id',
        as: 'collectionData',
      },
    },
    { $unwind: '$collectionData' },
    { $match: { 'collectionData.status': 'ACTIVE' } },
    { $count: 'count' },
  ]);

  const memberCount = counts.length > 0 ? counts[0].count : 0;
  if (memberCount >= MAX_COLLECTIONS_PER_USER) {
    throw new AppError('User has reached the maximum allowed collections (2)', StatusCodes.BAD_REQUEST);
  }

  // Validate potential members' limits up front
  const friendIds = Array.from(new Set(friends.map((f) => f.friendId).filter(Boolean)));
  const friendObjectIds = friendIds.map((id) => new mongoose.Types.ObjectId(id));

  const friendCounts = await CollectionMember.aggregate([
    { $match: { userId: { $in: friendObjectIds } } },
    {
      $lookup: {
        from: 'collections',
        localField: 'collectionId',
        foreignField: '_id',
        as: 'collectionData',
      },
    },
    { $unwind: '$collectionData' },
    { $match: { 'collectionData.status': 'ACTIVE' } },
    { $group: { _id: '$userId', count: { $sum: 1 } } },
  ]);

  const countMap = new Map(friendCounts.map((c) => [c._id.toString(), c.count]));

  const invalidFriendIds = friendIds.filter((id) => (countMap.get(id) || 0) >= MAX_COLLECTIONS_PER_USER);

  if (invalidFriendIds.length > 0) {
    const usersData = await UserService.hydrateUsers(invalidFriendIds);

    const names = usersData
      .map((u) => u?.name)
      .filter(Boolean)
      .join(', ');

    throw new AppError(`${names} ${invalidFriendIds.length > 1 ? 'have' : 'has'} reached the maximum allowed collections (${MAX_COLLECTIONS_PER_USER})`, StatusCodes.BAD_REQUEST);
  }
  // Remove friends from data to avoid persisting arbitrary fields[]
  const { friends: _ignoredFriends, ...collectionData } = data || {};

  return runInTransaction(async (session) => {
    const collection = new Collection({
      ...collectionData,
      ownerId: userId,
    });
    await collection.save({ session });

    const member = new CollectionMember({
      collectionId: collection._id,
      userId,
      role: 'CONTRIBUTE',
    });
    await member.save({ session });

    // Hydrate ownerId before returning
    const userData = await UserService.hydrateUsers([userId]);
    const hydratedCollection = collection.toObject();
    (hydratedCollection as any).owner = userData[0] || { _id: userId };

    return hydratedCollection;
  });
};

export const getUserCollections = async (userId: string) => {
  const members = await CollectionMember.find({ userId }).populate('collectionId');
  // const collections = members.map((m) => m.collectionId as unknown as ICollection);
  const collections = members.map((m) => m.collectionId as unknown as ICollection).filter((c) => c && c.ownerId);

  // Hydrate ownerIds
  const ownerIds = collections.map((c) => c.ownerId.toString());
  const userData = await UserService.hydrateUsers(ownerIds);
  const userMap = new Map();
  userData.forEach((u) => userMap.set(u._id.toString(), u));

  // Fetch members for each collection
  const collectionsWithMembers = await Promise.all(
    collections.map(async (c) => {
      const collectionMembers = await CollectionMember.find({ collectionId: c._id }).lean();
      // Hydrate member user data
      const memberUserIds = collectionMembers.map((m) => m.userId.toString());
      const memberUserData = await UserService.hydrateUsers(memberUserIds);
      const memberUserMap = new Map();
      memberUserData.forEach((u) => memberUserMap.set(u._id.toString(), u));

      const hydratedMembers = collectionMembers.map((m) => ({
        ...m,
        user: memberUserMap.get(m.userId.toString()) || { _id: m.userId },
      }));

      const co = (c as any).toObject ? (c as any).toObject() : c;
      return {
        ...co,
        owner: userMap.get(c.ownerId.toString()) || { _id: c.ownerId },
        members: hydratedMembers.map((m) => m.user?.name),
      };
    })
  );

  return collectionsWithMembers;
};

export const getCollectionById = async (collectionId: string, userId: string) => {
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member) {
    throw new AppError('User is not a member of this collection', StatusCodes.FORBIDDEN);
  }

  const collection = await Collection.findById(collectionId);
  const members = await CollectionMember.find({ collectionId }).lean();
  const transactions = await CollectionTransaction.find({ collectionId }).populate('transactionId').select('-_id -__v').lean();
  const flattenedTransactions = transactions.map((t) => t.transactionId).filter(Boolean);
  const splits = await Split.find({ collectionId }).lean();

  // Hydrate user IDs
  const userIdsSet = new Set<string>();
  if (collection) userIdsSet.add(collection.ownerId.toString());
  members.forEach((m) => userIdsSet.add(m.userId.toString()));
  splits.forEach((s) => {
    userIdsSet.add(s.paidBy.toString());
    s.splits.forEach((si) => userIdsSet.add(si.userId.toString()));
  });

  const userData = await UserService.hydrateUsers(Array.from(userIdsSet));
  const userMap = new Map();
  userData.forEach((u) => userMap.set(u._id.toString(), u));

  // Map user data back to collection owner
  const colObj = (collection as any).toObject ? (collection as any).toObject() : collection;
  const hydratedCollection = {
    ...colObj,
    owner: userMap.get(collection?.ownerId.toString() || '') || { _id: collection?.ownerId },
  };

  const amountSpentMap = new Map<string, number>();

  transactions.forEach((t: any) => {
    const userId = t.addedBy.toString();
    const amount = t.amount || 0;

    amountSpentMap.set(userId, (amountSpentMap.get(userId) || 0) + amount);
  });

  // Map user data back to members
  const hydratedMembers = members.map((m) => ({
    ...m,
    amountSpent: amountSpentMap.get(m.userId.toString()) || 0,
    user: userMap.get(m.userId.toString()) || { _id: m.userId },
  }));

  // Map user data back to splits with user-specific details
  const hydratedSplits = formatSplitsWithMemberDetails(splits, userId, userMap);

  // Calculate transaction totals
  let totalCredit = 0;
  let totalDebit = 0;

  transactions.forEach((tx: any) => {
    const bankTx = tx.transactionId;
    if (bankTx) {
      if (bankTx.type === 'CREDIT') {
        totalCredit += bankTx.amount || 0;
      } else if (bankTx.type === 'DEBIT') {
        totalDebit += bankTx.amount || 0;
      }
    }
  });

  const outStandingAmount = totalDebit - totalCredit;
  const banks = await new FipRepository().getBank(userId);
  const enrichedTransactions = await enrichTransactionWithBankDetails(flattenedTransactions, banks);
  const enrichedMap = new Map(enrichedTransactions.map((tx: any) => [tx._id.toString(), tx]));
  const finalTransactions = transactions.reduce((acc: any[], t: any) => {
    const enriched = enrichedMap.get(t.transactionId?._id.toString());
    acc.push({
      ...t,
      transactionId: enriched || t.transactionId,
    });
    return acc;
  }, []);

  return {
    collection: hydratedCollection,
    members: hydratedMembers,
    transactions: finalTransactions,
    splits: hydratedSplits,
    totalCredit,
    totalDebit,
    outStandingAmount,
  };
};

export interface IFriendInput {
  friendId: string;
  role?: string;
}

export const addMembers = async (collectionId: string, authorId: string, friends: IFriendInput[]) => {
  const authorMember = await CollectionMember.findOne({ collectionId, userId: authorId });
  if (!authorMember || authorMember.role !== 'CONTRIBUTE') {
    throw new AppError('You do not have permission to add members', StatusCodes.FORBIDDEN);
  }

  return runInTransaction(async (session) => {
    const addedMembers = [];
    for (const friend of friends) {
      const { friendId, role } = friend;

      const counts = await CollectionMember.aggregate([
        { $match: { userId: friendId } },
        {
          $lookup: {
            from: 'collections',
            localField: 'collectionId',
            foreignField: '_id',
            as: 'collectionData',
          },
        },
        { $unwind: '$collectionData' },
        { $match: { 'collectionData.status': 'ACTIVE' } },
        { $count: 'count' },
      ]).session(session);

      const friendCollectionCount = counts.length > 0 ? counts[0].count : 0;
      if (friendCollectionCount >= MAX_COLLECTIONS_PER_USER) {
        throw new AppError(`User ${friendId} has already reached the maximum allowed collections (2)`, StatusCodes.BAD_REQUEST);
      }

      const existingMember = await CollectionMember.findOne({ collectionId, userId: friendId }).session(session);
      if (existingMember) {
        throw new AppError(`User ${friendId} is already a member of this collection`, StatusCodes.BAD_REQUEST);
      }

      const newMember = new CollectionMember({
        collectionId,
        userId: friendId,
        role: role || 'VIEW',
      });
      await newMember.save({ session });
      addedMembers.push(newMember);
    }

    // Hydrate before returning
    const userIds = addedMembers.map((m) => m.userId.toString());
    const userData = await UserService.hydrateUsers(userIds);
    const userMap = new Map();
    userData.forEach((u) => userMap.set(u._id.toString(), u));

    return addedMembers.map((m) => ({
      ...m.toObject(),
      user: userMap.get(m.userId.toString()) || { _id: m.userId },
    }));
  });
};

export const addTransactions = async (collectionId: string, userId: string, transactionIds: string[], splitType?: 'EQUAL' | 'CUSTOM', customSplits?: ISplitItem[]) => {
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member || member.role !== 'CONTRIBUTE') {
    throw new AppError('You do not have permission to add transactions to this collection', StatusCodes.FORBIDDEN);
  }

  if (!transactionIds || transactionIds.length === 0) {
    throw new AppError('No transactions provided', StatusCodes.BAD_REQUEST);
  }

  // Check if all transactions exist
  const transactions = await BankTransaction.find({ _id: { $in: transactionIds } });
  if (transactions.length !== transactionIds.length) {
    throw new AppError('One or more transactions not found', StatusCodes.NOT_FOUND);
  }

  // Check if any transaction is already added to this collection
  const existingColTxs = await CollectionTransaction.find({ collectionId, transactionId: { $in: transactionIds } });
  if (existingColTxs.length > 0) {
    throw new AppError('One or more transactions already added to this collection', StatusCodes.BAD_REQUEST);
  }

  const totalAmount = transactions.reduce((sum, tx) => sum + (tx.amount || 0), 0);

  return runInTransaction(async (session) => {
    const collection = await Collection.findById(collectionId).session(session);
    if (!collection || collection.status === 'CLOSED') {
      throw new AppError('Collection not found or closed', StatusCodes.BAD_REQUEST);
    }

    const colTxs = [];
    for (const tx of transactions) {
      const colTx = new CollectionTransaction({
        collectionId,
        transactionId: tx._id,
        addedBy: userId,
        amount: tx.amount,
      });
      await colTx.save({ session });
      colTxs.push(colTx);
    }

    // increment collection total
    collection.totalAmount = (collection.totalAmount || 0) + totalAmount;
    await collection.save({ session });

    // ── PERSONAL collection: no splits, return early ──
    if (collection.type === 'PERSONAL') {
      return { colTxs, splitDoc: null };
    }

    // ── SHARED collection: generate splits ──
    if (!splitType) {
      throw new AppError('splitType is required for shared collections', StatusCodes.BAD_REQUEST);
    }

    let splits: ISplitItem[] = [];
    if (splitType === 'EQUAL') {
      const allMembers = await CollectionMember.find({ collectionId }).session(session);
      const splitAmount = totalAmount / allMembers.length;
      splits = allMembers.map((m) => ({
        userId: m.userId,
        amount: splitAmount,
      }));
    } else {
      if (!customSplits || customSplits.length === 0) {
        throw new AppError('Custom splits must be provided', StatusCodes.BAD_REQUEST);
      }
      const totalSplit = customSplits.reduce((acc, s) => acc + parseInt(s.amount?.toString() || '0'), 0);
      // allows small floating precision diffs
      if (Math.abs(Math.round(totalSplit) - Math.round(totalAmount)) !== 0) {
        throw new AppError('Custom splits total must equal total transaction amount', StatusCodes.BAD_REQUEST);
      }
      splits = customSplits;
    }

    const splitDoc = new Split({
      collectionId,
      transactionIds,
      paidBy: userId, // Primary logic fallback
      splits,
      splitType,
    });
    // Let's assume paidBy is the user of the first transaction (assuming they all belong to the same person)
    splitDoc.paidBy = transactions[0].userId as unknown as mongoose.Types.ObjectId;

    await splitDoc.save({ session });

    // Hydrate users in splits before returning
    const userIdsToHydrate = new Set<string>();
    userIdsToHydrate.add(splitDoc.paidBy.toString());
    splitDoc.splits.forEach((s) => {
      if (s.userId) userIdsToHydrate.add(s.userId.toString());
    });

    const userData = await UserService.hydrateUsers(Array.from(userIdsToHydrate));
    const userMap = new Map();
    userData.forEach((u) => userMap.set(u._id.toString(), u));

    const plainSplitDoc = splitDoc.toObject();
    const hydratedSplit = {
      ...plainSplitDoc,
      paidByUser: userMap.get(plainSplitDoc.paidBy.toString()) || { _id: plainSplitDoc.paidBy },
      splits: plainSplitDoc.splits.map((s: any) => ({
        ...s,
        user: s.userId ? userMap.get(s.userId.toString()) || { _id: s.userId } : null,
      })),
    };

    return { colTxs, splitDoc: hydratedSplit };
  });
};

export const updateSplit = async (collectionId: string, userId: string, splitId: string, customSplits: ISplitItem[]) => {
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member || member.role !== 'CONTRIBUTE') {
    throw new AppError('You do not have permission to modify splits', StatusCodes.FORBIDDEN);
  }

  const splitDoc = await Split.findOne({ _id: splitId, collectionId });
  if (!splitDoc) {
    throw new AppError('Split not found', StatusCodes.NOT_FOUND);
  }

  const transactions = await BankTransaction.find({ _id: { $in: splitDoc.transactionIds } });
  if (!transactions || transactions.length === 0) throw new AppError('Transactions not found for split', StatusCodes.NOT_FOUND);

  const totalAmount = transactions.reduce((acc, tx) => acc + (tx.amount || 0), 0);

  const totalSplit = customSplits.reduce((acc, s) => acc + s.amount, 0);
  if (Math.abs(totalSplit - totalAmount) > 0.01) {
    throw new AppError('Custom splits total must equal total transaction amount', StatusCodes.BAD_REQUEST);
  }

  splitDoc.splitType = 'CUSTOM';
  splitDoc.splits = customSplits;
  await splitDoc.save();

  // Hydrate before returning
  const userIdsToHydrate = new Set<string>();
  userIdsToHydrate.add(splitDoc.paidBy.toString());
  splitDoc.splits.forEach((s) => {
    if (s.userId) userIdsToHydrate.add(s.userId.toString());
  });

  const userData = await UserService.hydrateUsers(Array.from(userIdsToHydrate));
  const userMap = new Map();
  userData.forEach((u) => userMap.set(u._id.toString(), u));

  const plainSplitDoc = splitDoc.toObject();
  return {
    ...plainSplitDoc,
    paidByUser: userMap.get(plainSplitDoc.paidBy.toString()) || { _id: plainSplitDoc.paidBy },
    splits: plainSplitDoc.splits.map((s: any) => ({
      ...s,
      user: s.userId ? userMap.get(s.userId.toString()) || { _id: s.userId } : null,
    })),
  };
};

export const getAvailableTransactions = async (userId: string, collectionId: string, page: number = 1, limit: number = 20) => {
  const collectionTransactions = await CollectionTransaction.find({ collectionId }).select('transactionId -_id');

  const usedTransactionIds = collectionTransactions.map((t) => new mongoose.Types.ObjectId(t.transactionId));

  const query = {
    userId,
    _id: { $nin: usedTransactionIds },
  };

  const total = await BankTransaction.countDocuments(query);
  const transactions = await BankTransaction.find(query)
    .sort({ transactionTimestamp: -1 })
    .skip((page - 1) * limit)
    .limit(limit)
    .lean();

  const banks = await new FipRepository().getBank(userId);
  const enrichedTransactions = await enrichTransactionWithBankDetails(transactions, banks);

  return {
    transactions: enrichedTransactions,
    pagination: {
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
    },
  };
};

export const getCollectionSplits = async (collectionId: string, userId: string) => {
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member) {
    throw new AppError('User is not a member of this collection', StatusCodes.FORBIDDEN);
  }

  // Find all splits for this collection
  // Populate the transaction tracking
  const splits = await Split.find({ collectionId }).populate('transactionIds').lean();

  // Hydrate user IDs
  const userIdsSet = new Set<string>();
  splits.forEach((s) => {
    userIdsSet.add(s.paidBy.toString());
    s.splits.forEach((si) => userIdsSet.add(si.userId.toString()));
  });
  const userData = await UserService.hydrateUsers(Array.from(userIdsSet));
  const userMap = new Map();
  userData.forEach((u) => userMap.set(u._id.toString(), u));

  const hydratedSplits = splits.map((s) => ({
    ...s,
    paidByUser: userMap.get(s.paidBy.toString()) || { _id: s.paidBy },
    splits: s.splits.map((si) => ({
      ...si,
      user: userMap.get(si.userId.toString()) || { _id: si.userId },
    })),
  }));

  return hydratedSplits;
};

export const getBalances = async (collectionId: string, userId: string) => {
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member) {
    throw new AppError('User is not a member of this collection', StatusCodes.FORBIDDEN);
  }

  const splits = await Split.find({ collectionId }).lean();

  // Sum all payment records for this collection, grouped by (splitId + payerId + receiverId)
  const allPayments = await SplitPayment.find({ collectionId }).lean();
  const paymentTotals = new Map<string, number>();
  allPayments.forEach((p) => {
    const key = `${p.splitId}_${p.payerId}_${p.receiverId}`;
    paymentTotals.set(key, (paymentTotals.get(key) || 0) + p.paidAmount);
  });

  // Per-split breakdown
  // toPay  => logged-in user is the debtor  (splitItem.userId === userId, paidBy !== userId)
  // toReceive => logged-in user is the creditor (paidBy === userId, splitItem.userId !== userId)
  const toPayItems: Array<any> = [];
  const toReceiveItems: Array<any> = [];

  for (const split of splits) {
    const paidBy = split.paidBy.toString();

    for (const splitItem of split.splits) {
      if (!splitItem.userId) continue;
      const splitUserId = splitItem.userId.toString();

      // Skip: paidBy covers their own share – no external debt
      if (splitUserId === paidBy) continue;

      const originalAmount = splitItem.amount;
      const payKey = `${split._id}_${splitUserId}_${paidBy}`;
      const paidAmount = paymentTotals.get(payKey) || 0;
      const remainingAmount = Math.max(0, originalAmount - paidAmount);

      const status = paidAmount === 0 ? 'PENDING' : remainingAmount === 0 ? 'SETTLED' : 'PARTIAL';

      if (splitUserId === userId) {
        // Logged-in user owes the paidBy person
        toPayItems.push({
          splitId: split._id,
          receiverId: paidBy,
          totalAmount: originalAmount,
          paidAmount,
          remainingAmount,
          status,
          date: split.createdAt,
        });
      } else if (paidBy === userId) {
        // splitUserId owes the logged-in user
        toReceiveItems.push({
          splitId: split._id,
          payerId: splitUserId,
          totalAmount: originalAmount,
          clearedAmount: paidAmount,
          pendingAmount: remainingAmount,
          status,
          date: split.createdAt,
        });
      }
    }
  }

  // Calculate totals (only unsettled items)
  const totalToPay = toPayItems.filter((i) => i.status !== 'SETTLED').reduce((sum, i) => sum + i.remainingAmount, 0);

  const totalToReceive = toReceiveItems.filter((i) => i.status !== 'SETTLED').reduce((sum, i) => sum + i.pendingAmount, 0);

  // Hydrate user IDs
  const userIdsSet = new Set<string>();
  toPayItems.forEach((i) => userIdsSet.add(i.receiverId));
  toReceiveItems.forEach((i) => userIdsSet.add(i.payerId));

  const userData = await UserService.hydrateUsers(Array.from(userIdsSet));
  const userMap = new Map();
  userData.forEach((u) => userMap.set(u._id.toString(), u));

  return {
    totalToPay,
    totalToReceive,
    toPay: toPayItems.map((item) => ({
      ...item,
      friend: userMap.get(item.receiverId) || { _id: item.receiverId },
    })),
    toReceive: toReceiveItems.map((item) => ({
      ...item,
      friend: userMap.get(item.payerId) || { _id: item.payerId },
    })),
  };
};

/**
 * Payer (X) records a payment towards their split debt to the receiver (Y = split.paidBy).
 * Full or partial amounts are allowed. Multiple payments accumulate until fully settled.
 */
export const recordPayment = async (
  collectionId: string,
  userId: string, // payer / debtor
  splitId: string,
  amount: number,
  note?: string
) => {
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member) {
    throw new AppError('User is not a member of this collection', StatusCodes.FORBIDDEN);
  }

  const split = await Split.findOne({ _id: splitId, collectionId }).lean();
  if (!split) {
    throw new AppError('Split not found', StatusCodes.NOT_FOUND);
  }

  const splitItem = split.splits.find((s) => s.userId?.toString() === userId);
  if (!splitItem) {
    throw new AppError('You do not have a share in this split', StatusCodes.BAD_REQUEST);
  }

  const receiverId = split.paidBy.toString();
  if (receiverId === userId) {
    throw new AppError('You cannot record a payment to yourself', StatusCodes.BAD_REQUEST);
  }

  // Calculate remaining balance
  const existingPayments = await SplitPayment.find({ splitId, payerId: userId, receiverId }).lean();
  const alreadyPaid = existingPayments.reduce((sum, p) => sum + p.paidAmount, 0);
  const remaining = splitItem.amount - alreadyPaid;

  if (remaining <= 0) {
    throw new AppError('This split debt is already fully settled', StatusCodes.BAD_REQUEST);
  }
  if (amount <= 0 || amount > remaining + 0.01) {
    throw new AppError(`Amount must be > 0 and ≤ remaining balance of ${remaining}`, StatusCodes.BAD_REQUEST);
  }

  const payment = new SplitPayment({
    collectionId,
    splitId,
    payerId: userId,
    receiverId,
    splitAmount: splitItem.amount,
    paidAmount: Math.min(amount, remaining),
    initiatedBy: userId,
    note,
  });
  await payment.save();

  // Hydrate and return
  const userData = await UserService.hydrateUsers([userId, receiverId]);
  const userMap = new Map();
  userData.forEach((u) => userMap.set(u._id.toString(), u));

  return {
    ...payment.toObject(),
    payer: userMap.get(userId) || { _id: userId },
    receiver: userMap.get(receiverId) || { _id: receiverId },
    newRemainingAmount: remaining - payment.paidAmount,
  };
};

/**
 * Receiver (Y = split.paidBy) clears/confirms that the debtor (X) paid them.
 * Can be called independently (offline cash scenario) without the payer having
 * called recordPayment first. Full or partial amounts allowed.
 */
export const clearPayment = async (
  collectionId: string,
  userId: string, // receiver / creditor (Y)
  splitId: string,
  payerId: string, // the debtor (X) whose debt is being cleared
  amount: number,
  note?: string
) => {
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member) {
    throw new AppError('User is not a member of this collection', StatusCodes.FORBIDDEN);
  }

  const split = await Split.findOne({ _id: splitId, collectionId }).lean();
  if (!split) {
    throw new AppError('Split not found', StatusCodes.NOT_FOUND);
  }

  if (split.paidBy.toString() !== userId) {
    throw new AppError('Only the creditor (person who paid the split) can clear payments', StatusCodes.FORBIDDEN);
  }

  const splitItem = split.splits.find((s) => s.userId?.toString() === payerId);
  if (!splitItem) {
    throw new AppError('This user does not have a share in this split', StatusCodes.BAD_REQUEST);
  }

  if (payerId === userId) {
    throw new AppError('You cannot clear a payment for yourself', StatusCodes.BAD_REQUEST);
  }

  // Calculate remaining balance
  const existingPayments = await SplitPayment.find({ splitId, payerId, receiverId: userId }).lean();
  const alreadyPaid = existingPayments.reduce((sum, p) => sum + p.paidAmount, 0);
  const remaining = splitItem.amount - alreadyPaid;

  if (remaining <= 0) {
    throw new AppError('This split debt is already fully settled', StatusCodes.BAD_REQUEST);
  }
  if (amount <= 0 || amount > remaining + 0.01) {
    throw new AppError(`Amount must be > 0 and ≤ remaining balance of ${remaining}`, StatusCodes.BAD_REQUEST);
  }

  const payment = new SplitPayment({
    collectionId,
    splitId,
    payerId,
    receiverId: userId,
    splitAmount: splitItem.amount,
    paidAmount: Math.min(amount, remaining),
    initiatedBy: userId,
    note,
  });
  await payment.save();

  // Hydrate and return
  const userData = await UserService.hydrateUsers([userId, payerId]);
  const userMap = new Map();
  userData.forEach((u) => userMap.set(u._id.toString(), u));

  return {
    ...payment.toObject(),
    payer: userMap.get(payerId) || { _id: payerId },
    receiver: userMap.get(userId) || { _id: userId },
    newRemainingAmount: remaining - payment.paidAmount,
  };
};

/**
 * Owner sets spending limits for multiple collection members in one call.
 * Only the collection owner can perform this action.
 */
export const setMemberLimits = async (
  collectionId: string,
  userId: string, // must be owner
  limits: Array<{ userId: string; limitAmount: string }>
) => {
  const collection = await Collection.findById(collectionId);
  if (!collection) {
    throw new AppError('Collection not found', StatusCodes.NOT_FOUND);
  }
  if (collection.ownerId.toString() !== userId) {
    throw new AppError('Only the collection owner can set member limits', StatusCodes.FORBIDDEN);
  }
  if (!limits || limits.length === 0) {
    throw new AppError('limits array must not be empty', StatusCodes.BAD_REQUEST);
  }

  const updatedMembers: any[] = [];

  for (const limit of limits) {
    const targetMember = await CollectionMember.findOne({ collectionId, userId: limit.userId });
    if (!targetMember) {
      throw new AppError(`Member with userId ${limit.userId} not found in this collection`, StatusCodes.NOT_FOUND);
    }
    targetMember.limitAmount = limit.limitAmount;
    await targetMember.save();
    updatedMembers.push(targetMember.toObject());
  }

  // Hydrate user data
  const userIds = limits.map((l) => l.userId);
  const userData = await UserService.hydrateUsers(userIds);
  const userMap = new Map();
  userData.forEach((u) => userMap.set(u._id.toString(), u));

  return updatedMembers.map((m) => ({
    ...m,
    user: userMap.get(m.userId.toString()) || { _id: m.userId },
  }));
};

export const deleteCollection = async (collectionId: string, userId: string) => {
  const collection = await Collection.findById(collectionId);
  if (!collection) {
    throw new AppError('Collection not found', StatusCodes.NOT_FOUND);
  }
  if (collection.ownerId.toString() !== userId.toString()) {
    throw new AppError('Only the owner can delete the collection', StatusCodes.FORBIDDEN);
  }

  await runInTransaction(async (session) => {
    await Collection.findByIdAndDelete(collectionId).session(session);
    await CollectionMember.deleteMany({ collectionId }).session(session);
    await CollectionTransaction.deleteMany({ collectionId }).session(session);
    await Split.deleteMany({ collectionId }).session(session);
  });
};

export const updateCollection = async (collectionId: string, userId: string, data: { name?: string; description?: string; expiryAt?: Date }) => {
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member || member.role !== 'CONTRIBUTE') {
    throw new AppError('You do not have permission to update this collection', StatusCodes.FORBIDDEN);
  }

  const collection = await Collection.findById(collectionId);
  if (!collection) {
    throw new AppError('Collection not found', StatusCodes.NOT_FOUND);
  }
  if (collection.status === 'CLOSED') {
    throw new AppError('Cannot update a closed collection', StatusCodes.BAD_REQUEST);
  }

  if (data.name !== undefined) collection.name = data.name;
  if (data.description !== undefined) collection.description = data.description;
  if (data.expiryAt !== undefined) collection.expiryAt = data.expiryAt;

  await collection.save();
  return collection.toObject();
};

export const closeCollection = async (collectionId: string, userId: string) => {
  const collection = await Collection.findById(collectionId);
  if (!collection) {
    throw new AppError('Collection not found', StatusCodes.NOT_FOUND);
  }
  if (collection.ownerId.toString() !== userId.toString()) {
    throw new AppError('Only the owner can close the collection', StatusCodes.FORBIDDEN);
  }
  if (collection.status === 'CLOSED') {
    throw new AppError('Collection is already closed', StatusCodes.BAD_REQUEST);
  }

  collection.status = 'CLOSED';
  await collection.save();
  return collection.toObject();
};

export const getAllTransactions = async (collectionId: string, userId: string, page: number = 1, limit: number = 20) => { 
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member) {
    throw new AppError('User is not a member of this collection', StatusCodes.FORBIDDEN);
  }

  const total = await CollectionTransaction.countDocuments({ collectionId });
  const colTxs = await CollectionTransaction.find({ collectionId })
    .populate('transactionId')
    .sort({ createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(limit)
    .lean();

  let totalCredit = 0;
  let totalDebit = 0;

  // pute totals across ALL transactions (not just this page)
  const allColTxs = await CollectionTransaction.find({ collectionId }).populate('transactionId').lean();
  allColTxs.forEach((ct: any) => {
    const tx = ct.transactionId;
    if (tx) {
      if (tx.type === 'CREDIT') totalCredit += tx.amount || 0;
      else if (tx.type === 'DEBIT') totalDebit += tx.amount || 0;
    }
  });

  const outStandingAmount = totalDebit - totalCredit;

  return {
    transactions: colTxs,
    totalCredit,
    totalDebit,
    outStandingAmount,
    pagination: {
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
    },
  };
};

export const updateCollectionMember = async (collectionId: string, userId: string, targetUserId: string, role?: 'VIEW' | 'CONTRIBUTE', limitAmount?: string) => {
  const requesterMember = await CollectionMember.findOne({ collectionId, userId });
  if (!requesterMember || requesterMember.role !== 'CONTRIBUTE') {
    throw new AppError('You do not have permission to update member amounts', StatusCodes.FORBIDDEN);
  }

  const targetMember = await CollectionMember.findOne({ collectionId, userId: targetUserId });
  if (!targetMember) {
    throw new AppError('Target member not found in this collection', StatusCodes.NOT_FOUND);
  }

  if (role) {
    targetMember.role = role;
  }

  if (limitAmount) {
    targetMember.limitAmount = limitAmount;
  }

  await targetMember.save();

  // Hydrate user data before returning
  const userData = await UserService.hydrateUsers([targetUserId]);
  const hydratedMember = {
    ...targetMember.toObject(),
    user: userData[0] || { _id: targetUserId },
  };

  return hydratedMember;
};

export const exitCollectionByMember = async (collectionId: string, userId: string) => {
  // Check if member exists in the collection
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member) {
    throw new AppError('You are not a member of this collection', StatusCodes.NOT_FOUND);
  }

  // Delete the collection member document
  await CollectionMember.deleteOne({ collectionId, userId });

  return {
    message: 'Successfully exited the collection',
  };
};

export default {
  createCollection,
  getUserCollections,
  getCollectionById,
  addMembers,
  addTransactions,
  updateSplit,
  deleteCollection,
  getAvailableTransactions,
  getCollectionSplits,
  getBalances,
  updateCollection,
  closeCollection,
  getAllTransactions,
  updateCollectionMember,
  exitCollectionByMember,
  recordPayment,
  clearPayment,
  setMemberLimits,
};

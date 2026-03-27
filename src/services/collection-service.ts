import mongoose from 'mongoose';
import Collection, { ICollection } from '../models/collections/collection.model';
import CollectionMember from '../models/collections/collection-member.model';
import CollectionTransaction from '../models/collections/collection-transaction.model';
import Split, { ISplitItem } from '../models/collections/split.model';
import BankTransaction from '../models/transactions-automation/transaction';
import AppError from '../utils/errors/app-error';
import { StatusCodes } from 'http-status-codes';
import UserService from './user-service';

const MAX_COLLECTIONS_PER_USER = 2;

export const createCollection = async (userId: string, data: any) => {
  const memberCount = await CollectionMember.countDocuments({ userId });
  if (memberCount >= MAX_COLLECTIONS_PER_USER) {
    throw new AppError('User has reached the maximum allowed collections (2)', StatusCodes.BAD_REQUEST);
  }

  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    const collection = new Collection({
      ...data,
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

    await session.commitTransaction();
    session.endSession();

    return hydratedCollection;
  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    throw error;
  }
};

export const getUserCollections = async (userId: string) => {
  const members = await CollectionMember.find({ userId }).populate('collectionId');
  const collections = members.map((m) => m.collectionId as unknown as ICollection);

  // Hydrate ownerIds
  const ownerIds = collections.map(c => c.ownerId.toString());
  const userData = await UserService.hydrateUsers(ownerIds);
  const userMap = new Map();
  userData.forEach(u => userMap.set(u._id.toString(), u));

  return collections.map(c => {
    const co = (c as any).toObject ? (c as any).toObject() : c;
    return {
      ...co,
      owner: userMap.get(c.ownerId.toString()) || { _id: c.ownerId }
    };
  });
};

export const getCollectionById = async (collectionId: string, userId: string) => {
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member) {
    throw new AppError('User is not a member of this collection', StatusCodes.FORBIDDEN);
  }

  const collection = await Collection.findById(collectionId);
  const members = await CollectionMember.find({ collectionId }).lean();
  const transactions = await CollectionTransaction.find({ collectionId }).populate('transactionId');
  const splits = await Split.find({ collectionId }).lean();

  // Hydrate user IDs
  const userIdsSet = new Set<string>();
  if (collection) userIdsSet.add(collection.ownerId.toString());
  members.forEach(m => userIdsSet.add(m.userId.toString()));
  splits.forEach(s => {
    userIdsSet.add(s.paidBy.toString());
    s.splits.forEach(si => userIdsSet.add(si.userId.toString()));
  });

  const userData = await UserService.hydrateUsers(Array.from(userIdsSet));
  const userMap = new Map();
  userData.forEach(u => userMap.set(u._id.toString(), u));

  // Map user data back to collection owner
  const colObj = (collection as any).toObject ? (collection as any).toObject() : collection;
  const hydratedCollection = {
    ...colObj,
    owner: userMap.get(collection?.ownerId.toString() || '') || { _id: collection?.ownerId }
  };

  // Map user data back to members
  const hydratedMembers = members.map(m => ({
    ...m,
    user: userMap.get(m.userId.toString()) || { _id: m.userId }
  }));

  // Map user data back to splits
  const hydratedSplits = splits.map(s => ({
    ...s,
    paidByUser: userMap.get(s.paidBy.toString()) || { _id: s.paidBy },
    splits: s.splits.map(si => ({
      ...si,
      user: userMap.get(si.userId.toString()) || { _id: si.userId }
    }))
  }));

  return { collection: hydratedCollection, members: hydratedMembers, transactions, splits: hydratedSplits };
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

  const addedMembers = [];
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    for (const friend of friends) {
      const { friendId, role } = friend;

      const friendCollectionCount = await CollectionMember.countDocuments({ userId: friendId }).session(session);
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
    const userIds = addedMembers.map(m => m.userId.toString());
    const userData = await UserService.hydrateUsers(userIds);
    const userMap = new Map();
    userData.forEach(u => userMap.set(u._id.toString(), u));

    const result = addedMembers.map(m => ({
      ...m.toObject(),
      user: userMap.get(m.userId.toString()) || { _id: m.userId }
    }));

    await session.commitTransaction();
    session.endSession();

    return result;
  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    throw error;
  }
};

export const addTransactions = async (
  collectionId: string,
  userId: string,
  transactionIds: string[],
  splitType: 'EQUAL' | 'CUSTOM',
  customSplits?: ISplitItem[]
) => {
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member || member.role !== 'CONTRIBUTE') {
    throw new AppError('You do not have permission to add transactions to this collection', StatusCodes.FORBIDDEN);
  }

  const collection = await Collection.findById(collectionId);
  if (!collection || collection.status === 'CLOSED') {
    throw new AppError('Collection not found or closed', StatusCodes.BAD_REQUEST);
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

  const session = await mongoose.startSession();
  session.startTransaction();
  try {
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

    // generate splits
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
      const totalSplit = customSplits.reduce((acc, s) => acc + s.amount, 0);
      // allows small floating precision diffs
      if (Math.abs(totalSplit - totalAmount) > 0.01) {
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
    splitDoc.splits.forEach(s => {
      if (s.userId) userIdsToHydrate.add(s.userId.toString());
    });

    const userData = await UserService.hydrateUsers(Array.from(userIdsToHydrate));
    const userMap = new Map();
    userData.forEach(u => userMap.set(u._id.toString(), u));

    const plainSplitDoc = splitDoc.toObject();
    const hydratedSplit = {
      ...plainSplitDoc,
      paidByUser: userMap.get(plainSplitDoc.paidBy.toString()) || { _id: plainSplitDoc.paidBy },
      splits: plainSplitDoc.splits.map((s: any) => ({
        ...s,
        user: s.userId ? userMap.get(s.userId.toString()) || { _id: s.userId } : null
      }))
    };

    await session.commitTransaction();
    session.endSession();

    return { colTxs, splitDoc: hydratedSplit };
  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    throw error;
  }
};

export const updateSplit = async (
  collectionId: string,
  userId: string,
  splitId: string,
  customSplits: ISplitItem[]
) => {
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
  splitDoc.splits.forEach(s => {
    if (s.userId) userIdsToHydrate.add(s.userId.toString());
  });

  const userData = await UserService.hydrateUsers(Array.from(userIdsToHydrate));
  const userMap = new Map();
  userData.forEach(u => userMap.set(u._id.toString(), u));

  const plainSplitDoc = splitDoc.toObject();
  return {
    ...plainSplitDoc,
    paidByUser: userMap.get(plainSplitDoc.paidBy.toString()) || { _id: plainSplitDoc.paidBy },
    splits: plainSplitDoc.splits.map((s: any) => ({
      ...s,
      user: s.userId ? userMap.get(s.userId.toString()) || { _id: s.userId } : null
    }))
  };
};

export const getAvailableTransactions = async (
  userId: string,
  collectionId: string,
  page: number = 1,
  limit: number = 20
) => {
  const collectionTransactions = await CollectionTransaction.find({ collectionId }).select('transactionId -_id');
  const usedTransactionIds = collectionTransactions.map(t => t.transactionId);

  const query = {
    userId,
    _id: { $nin: usedTransactionIds }
  };

  const total = await BankTransaction.countDocuments(query);
  const transactions = await BankTransaction.find(query)
    .sort({ createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(limit)
    .lean();

  return {
    transactions,
    pagination: {
      total,
      page,
      limit,
      pages: Math.ceil(total / limit)
    }
  };
};

export const getCollectionSplits = async (collectionId: string, userId: string) => {
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member) {
    throw new AppError('User is not a member of this collection', StatusCodes.FORBIDDEN);
  }

  // Find all splits for this collection
  // Populate the transaction tracking
  const splits = await Split.find({ collectionId })
    .populate('transactionIds')
    .lean();

  // Hydrate user IDs
  const userIdsSet = new Set<string>();
  splits.forEach(s => {
    userIdsSet.add(s.paidBy.toString());
    s.splits.forEach(si => userIdsSet.add(si.userId.toString()));
  });
  const userData = await UserService.hydrateUsers(Array.from(userIdsSet));
  const userMap = new Map();
  userData.forEach(u => userMap.set(u._id.toString(), u));

  const hydratedSplits = splits.map(s => ({
    ...s,
    paidByUser: userMap.get(s.paidBy.toString()) || { _id: s.paidBy },
    splits: s.splits.map(si => ({
      ...si,
      user: userMap.get(si.userId.toString()) || { _id: si.userId }
    }))
  }));

  return hydratedSplits;
};

export const getBalances = async (collectionId: string, userId: string) => {
  // Validate authorization
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member) {
    throw new AppError('User is not a member of this collection', StatusCodes.FORBIDDEN);
  }

  const splits = await Split.find({ collectionId });
  const netBalances: Record<string, number> = {};

  splits.forEach(split => {
    const paidBy = split.paidBy.toString();
    split.splits.forEach(s => {
      if (!s.userId) return;
      const owingUser = s.userId.toString();
      if (paidBy !== owingUser) {
        netBalances[paidBy] = (netBalances[paidBy] || 0) + s.amount;
        netBalances[owingUser] = (netBalances[owingUser] || 0) - s.amount;
      }
    });
  });

  // Get unique user IDs to hydrate
  const userIds = Object.keys(netBalances);
  const userData = await UserService.hydrateUsers(userIds);
  const userMap = new Map();
  userData.forEach(u => userMap.set(u._id.toString(), u));

  // Convert to an array format
  const balances = Object.keys(netBalances).map(uId => {
    const bal = netBalances[uId];
    return {
      userId: uId,
      user: userMap.get(uId) || { _id: uId },
      balance: Math.abs(bal),
      type: bal > 0 ? 'toReceive' : (bal < 0 ? 'toPay' : 'settled')
    };
  }).filter(b => b.type !== 'settled');

  return balances;
};

export const deleteCollection = async (collectionId: string, userId: string) => {
  const collection = await Collection.findById(collectionId);
  if (!collection) {
    throw new AppError('Collection not found', StatusCodes.NOT_FOUND);
  }
  if (collection.ownerId.toString() !== userId.toString()) {
    throw new AppError('Only the owner can delete the collection', StatusCodes.FORBIDDEN);
  }

  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    await Collection.findByIdAndDelete(collectionId).session(session);
    await CollectionMember.deleteMany({ collectionId }).session(session);
    await CollectionTransaction.deleteMany({ collectionId }).session(session);
    await Split.deleteMany({ collectionId }).session(session);

    await session.commitTransaction();
    session.endSession();
  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    throw error;
  }
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
};

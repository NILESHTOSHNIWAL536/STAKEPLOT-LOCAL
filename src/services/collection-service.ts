import mongoose from 'mongoose';
import Collection, { ICollection } from '../models/collections/collection.model';
import CollectionMember from '../models/collections/collection-member.model';
import CollectionTransaction from '../models/collections/collection-transaction.model';
import Split, { ISplitItem } from '../models/collections/split.model';
import BankTransaction from '../models/transactions-automation/transaction';
import AppError from '../utils/errors/app-error';
import { StatusCodes } from 'http-status-codes';
import UserService from './user-service';

const MAX_COLLECTIONS_PER_USER = 5;

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
  const transactions = await CollectionTransaction.find({ collectionId }).populate('transactionId').select('-_id -__v');;
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

  return {
    collection: hydratedCollection,
    members: hydratedMembers,
    transactions,
    splits: hydratedSplits,
    totalCredit,
    totalDebit,
    outStandingAmount
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
  splitType?: 'EQUAL' | 'CUSTOM',
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

    console.log("collection: ", collection);

    // ── PERSONAL collection: no splits, return early ──
    if (collection.type === 'PERSONAL') {
      await session.commitTransaction();
      session.endSession();
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

  const usedTransactionIds = collectionTransactions.map(t =>
    new mongoose.Types.ObjectId(t.transactionId)
  );

  const query = {
    userId,
    _id: { $nin: usedTransactionIds }
  };

  const total = await BankTransaction.countDocuments(query);
  const transactions = await BankTransaction.find(query)
    .sort({ transactionTimestamp: -1 })
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

  // Per-user net from logged-in user's perspective:
  //   positive => other user owes the logged-in user (toReceive)
  //   negative => logged-in user owes the other user (toPay)
  const userBalances: Record<string, number> = {};

  splits.forEach(split => {
    const paidBy = split.paidBy.toString();
    
    // Calculate how much each person in the split owes/is owed
    split.splits.forEach(splitItem => {
      if (!splitItem.userId) return;
      const splitUserId = splitItem.userId.toString();
      const amount = splitItem.amount;

      if (splitUserId === userId) {
        // The logged-in user's share in this split
        if (paidBy === userId) {
          // Logged-in user paid: they advanced money for their own share
          // Net effect: no debt (they paid for themselves)
        } else {
          // Someone else paid for the logged-in user's share
          // Logged-in user owes the payer their share amount
          userBalances[paidBy] = (userBalances[paidBy] || 0) - amount;
        }
      } else {
        // Another user's share in this split
        if (paidBy === userId) {
          // Logged-in user paid: other users owe them their share amounts
          userBalances[splitUserId] = (userBalances[splitUserId] || 0) + amount;
        }
        // If someone else paid, we don't track balances with this other person from this split
      }
    });
  });

  // Hydrate involved user IDs
  const friendIds = Object.keys(userBalances);
  const userData = await UserService.hydrateUsers([userId, ...friendIds]);
  const userMap = new Map();
  userData.forEach(u => userMap.set(u._id.toString(), u));

  const toPay: Array<{ friend: any; amount: number }> = [];
  const toReceive: Array<{ friend: any; amount: number }> = [];

  for (const friendId of friendIds) {
    const net = userBalances[friendId];
    if (net === 0) continue; // settled, skip

    const entry = {
      friend: userMap.get(friendId) || { _id: friendId },
      amount: Math.abs(net),
    };

    if (net > 0) {
      toReceive.push(entry); // friend owes logged-in user
    } else {
      toPay.push(entry); // logged-in user owes friend
    }
  }

  return { toPay, toReceive };
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

export const updateCollection = async (
  collectionId: string,
  userId: string,
  data: { name?: string; description?: string; expiryAt?: Date }
) => {
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

export const getAllTransactions = async (
  collectionId: string,
  userId: string,
  page: number = 1,
  limit: number = 20
) => {
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

  // Compute totals across ALL transactions (not just this page)
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
};

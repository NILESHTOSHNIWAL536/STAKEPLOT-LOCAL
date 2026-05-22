import { Types } from 'mongoose';

function buildMatch({ userId, keywords, type, manualTransaction, Hidden, accountId, minAmount, maxAmount, startDate, endDate }) {
  const match: any = {
    userId: new Types.ObjectId(userId),
  };

  if (Hidden) match.Hidden = true;
  else match.Hidden = false;

  if (type) match.type = type;
  if (manualTransaction === true) match.manualTransaction = true;

  if (accountId) {
    if (Array.isArray(accountId)) {
      match.accountId = { $in: accountId.map((id) => new Types.ObjectId(id)) };
    } else {
      match.accountId = new Types.ObjectId(accountId);
    }
  }

  if (minAmount !== undefined || maxAmount !== undefined) {
    match.amount = {};
    if (minAmount !== undefined) match.amount.$gte = minAmount;
    if (maxAmount !== undefined) match.amount.$lte = maxAmount;
  }

  if (startDate || endDate) {
    match.transactionTimestamp = {};
    if (startDate) match.transactionTimestamp.$gte = startDate;
    if (endDate) match.transactionTimestamp.$lte = endDate;
  }

  function buildSearchObjects(words: string[]) {
    return words.flatMap((word) => [
      { narration: { $regex: word, $options: 'i' } },
      { name: { $regex: word, $options: 'i' } },
      { merchant: { $regex: word, $options: 'i' } },
      { category: { $regex: word, $options: 'i' } },
    ]);
  }

  const searchObjects = buildSearchObjects(keywords);
  if (searchObjects.length > 0) match.$or = searchObjects;

  return match;
}

export default buildMatch;

import { Types } from 'mongoose';
import { getNextFetch } from './get-next-fetch';
import { Account } from '@/models';

async function updateNextFetchForFailedAccounts(accountId: string | Types.ObjectId) {
  try {
    const accounts = await Account.find({ accountId });
    for (const account of accounts) {
      const nextFetch = getNextFetch(); // replace with your own logic
      account.nextFetch = new Date(nextFetch);
      await account.save();
    }
  } catch (error) {
    console.error('Error updating nextFetch:', error);
  }
}

export default updateNextFetchForFailedAccounts;

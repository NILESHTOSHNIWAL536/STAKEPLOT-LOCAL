import mongoose from 'mongoose';
import { Transaction } from '../../models';
import { Types } from 'mongoose';
// ---------------------- Types ---------------------- //

export type SearchFilter = { amount: number } | { type: RegExp } | { category: RegExp } | { narration: RegExp } | { subcategory: RegExp };

interface TransactionDoc {
  narration?: string;
  category?: string;
  subcategory?: string;
  [key: string]: any;
}

// ---------------------- buildSearchFilter ---------------------- //

export const buildSearchFilter = (searchText: string): SearchFilter[] => {
  const trimmedText = searchText.trim() === 'empty' ? '' : searchText.trim();

  const searchFilter: SearchFilter[] = [];

  if (trimmedText) {
    const regex = new RegExp(trimmedText, 'i');

    if (!isNaN(Number(trimmedText))) {
      searchFilter.push({ amount: Number(trimmedText) });
    } else if (['debit', 'credit', 'CREDIT', 'DEBIT'].includes(trimmedText)) {
      searchFilter.push({ type: regex });
    } else {
      searchFilter.push({ category: regex }, { narration: regex }, { subcategory: regex });
    }
  }

  return searchFilter;
};

// ---------------------- escapeRegex ---------------------- //

export const escapeRegex = (str: string): string => str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

// ---------------------- getMatchedKeywords ---------------------- //

export const getMatchedKeywords = async (userId: string | Types.ObjectId, searchText: string): Promise<string[]> => {
  if (!searchText || searchText.trim() === '' || searchText.trim() === 'empty') return [];

  const trimmedSearch = searchText.trim().toLowerCase();
  const regex = new RegExp('^' + escapeRegex(trimmedSearch), 'i');
  const objectUserId = new mongoose.Types.ObjectId(userId);

  const projectionFields = {
    narration: 1,
    category: 1,
    subcategory: 1,
  };

  const matchedDocs = await Transaction.find(
    {
      userId: objectUserId,
      Hidden: false,
      $or: [{ narration: { $regex: regex } }, { category: { $regex: regex } }, { subcategory: { $regex: regex } }],
    },
    projectionFields
  ).lean<TransactionDoc[]>();

  const matchedKeywordsSet = new Set<string>();

  matchedDocs.forEach((doc) => {
    ['narration', 'category', 'subcategory'].forEach((field) => {
      const value = doc[field];
      if (value) {
        const words = value.split(/\s+/);
        words.forEach((word: any) => {
          const cleanWord = word.replace(/[^a-zA-Z0-9]/g, '').toLowerCase();
          if (regex.test(cleanWord)) {
            matchedKeywordsSet.add(cleanWord);
          }
        });
      }
    });
  });

  return [...matchedKeywordsSet];
};

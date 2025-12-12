import type { PipelineStage } from 'mongoose';
import type { SearchPipelineInput } from '@/types/bank/search.types';

/**
 * Build a simple search pipeline for transactions.
 * This mirrors the JS baseQuery logic from your original repository.
 */
export const buildSearchPipeline = (input: SearchPipelineInput): PipelineStage[] => {
  const { userId, searchFilter, accountId, minAmount, maxAmount, startDate, endDate } = input;
  console.log('input from here: ', input);

  const hasCash = Array.isArray(searchFilter) && searchFilter.some((f) => typeof f === 'string' && f.toLowerCase() === 'cash');

  const baseMatch: Record<string, any> = {
    userId,
    Hidden: false,
  };

  if (hasCash) baseMatch.manualTransaction = true;
  if (searchFilter && searchFilter.length > 0) baseMatch.$or = searchFilter;
  if (accountId && accountId != '-') baseMatch.accountId = accountId;

  if (minAmount !== undefined || maxAmount !== undefined) {
    baseMatch.amount = {};
    if (minAmount !== undefined) baseMatch.amount.$gte = minAmount;
    if (maxAmount !== undefined) baseMatch.amount.$lte = maxAmount;
  }

  if (startDate || endDate) {
    baseMatch.transactionTimestamp = {};
    if (startDate) baseMatch.transactionTimestamp.$gte = startDate;
    if (endDate) baseMatch.transactionTimestamp.$lte = endDate;
  }

  const pipeline: PipelineStage[] = [{ $match: baseMatch }, { $sort: { transactionTimestamp: -1 } }];

  return pipeline;
};

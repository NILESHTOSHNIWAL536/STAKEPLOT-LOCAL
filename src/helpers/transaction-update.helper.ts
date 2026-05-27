// src2/helpers/transaction-update.helper.ts

import type { Model, Types } from "mongoose";
import { IBankTransaction } from '@/types/bank';
import type { ITransactionRule } from "@/models/transactions-automation/transactionRule";

import extractNarrationPattern from "@/utils/helpers/extractNarrationPattern";
import { PredictedCategories } from "@/models"; // adjust import based on your project
import { handleDailyCounter } from "@/utils/helpers/increment_score";
import { scoreToAdd, scoreToGetReward } from "../utils/common/enums";
import { createRecurringPaymentFromTransaction, detectAndStoreAutoPays } from "@/services/auto-service";
import { parseNarration } from "@/utils/narration/parseNarration";
import { normalizeMerchantKey, upsertMerchantDirectory } from "@/utils/narration/merchantDirectoryLookup";

interface UpdateInput {
  userId: string | Types.ObjectId;
  txId: string | Types.ObjectId
  data: Partial<IBankTransaction> & {
    predictedCategories?: any[];
    selectedCategory?: string;
  };
  Transaction: Model<IBankTransaction>;
  TransactionRule: Model<ITransactionRule>;
}

export const updateTransactionLogic = async ({
  userId,
  txId,
  data,
  Transaction,
  TransactionRule
}: UpdateInput) => {
  const updated = await Transaction.findOneAndUpdate(
    { _id: txId, userId },
    { $set: data },
    { new: true }
  );

  if (!updated) {
    return { success: false, message: "Transaction not found" };
  }

  // If category changed → update TransactionRule
  if ("category" in data) {

    const narrationPattern = extractNarrationPattern(updated.narration);
    const pattern = narrationPattern?.toLowerCase() || '';
  

    await TransactionRule.findOneAndUpdate(
      {
        userId: updated.userId,
        narrationPattern: pattern,
        amount: updated.amount
      },
      {
        userId: updated.userId,
        narrationPattern: pattern,
        amount: updated.amount,
        category: updated.category,
        subcategory: updated.subcategory ?? "",
        source: "manual"
      },
      { upsert: true }
    );

    // Cross-user write-back: persist merchant → category into the shared directory
    // so all future users who transact with the same counterparty benefit immediately.
    const parsed = parseNarration(updated.narration);
    if (parsed) {
      const key =
        parsed.counterpartyVPA && !/^\d+$/.test(parsed.counterpartyVPA)
          ? normalizeMerchantKey(parsed.counterpartyVPA)
          : parsed.counterpartyName
          ? normalizeMerchantKey(parsed.counterpartyName)
          : null;
      if (key) {
        await upsertMerchantDirectory(
          key,
          updated.category,
          updated.subcategory ?? '',
          'user_correction',
          0.95,
        );
      }
    }

    // ML training document
    if (data.predictedCategories && data.selectedCategory) {
      await PredictedCategories.create({
        narration: updated.narration,
        selectedCategory: data.selectedCategory,
        predictedCategories: data.predictedCategories
      });
    }

    await handleDailyCounter(
      updated.userId,
      "dailyTags",
      1,
      txId,
      scoreToAdd.Tag,
      scoreToGetReward.Tag
    );
  }

  if (data.isAutoPay === true) {
    await createRecurringPaymentFromTransaction(userId, txId);
  } else if (
    "amount" in data ||
    "narration" in data ||
    "transactionTimestamp" in data ||
    "isExcluded" in data ||
    "Hidden" in data
  ) {
    await detectAndStoreAutoPays(userId);
  }

  return {
    success: true,
    message: "Transaction updated",
    data: updated
  };
};

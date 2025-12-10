// src2/helpers/transaction-update.helper.ts

import type { Model } from "mongoose";
import type { ITransaction } from "../types/transaction.types";
import type { ITransactionRule } from "../types/rule.types";

import extractNarrationPattern from "../utils/extractNarrationPattern"; // your util
import { PredictedCategories } from "../models"; // adjust import based on your project
import { handleDailyCounter } from "../utils/increment_score";
import { scoreToAdd, scoreToGetReward } from "../utils/common/enums";

interface UpdateInput {
  userId: string;
  txId: string;
  data: Partial<ITransaction> & {
    predictedCategories?: any[];
    selectedCategory?: string;
  };
  Transaction: Model<ITransaction>;
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
    const narrationPattern = extractNarrationPattern(
      updated.narration
    ).toLowerCase();

    await TransactionRule.findOneAndUpdate(
      {
        userId: updated.userId,
        narrationPattern,
        amount: updated.amount
      },
      {
        userId: updated.userId,
        narrationPattern,
        amount: updated.amount,
        category: updated.category,
        subcategory: updated.subcategory ?? "",
        source: "manual"
      },
      { upsert: true }
    );

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

  return {
    success: true,
    message: "Transaction updated",
    data: updated
  };
};

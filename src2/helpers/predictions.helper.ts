// src2/helpers/predictions.helper.ts

import axios from "axios";
import { PREDICT_URL } from "../config/env"; // define this as needed

/**
 * Takes a list of transactions → returns same list with predicted categories appended.
 */
export const predictCategoriesForTransactions = async (transactions: any[]) => {
  if (!transactions.length) return transactions;

  try {
    const narrations = transactions.map((t) => t.narration);

    const { data } = await axios.post(`${PREDICT_URL}/predict`, {
      narrations
    });

    return transactions.map((tx, idx) => ({
      ...tx,
      predictedCategories: data?.predictions?.[idx] ?? []
    }));
  } catch (error) {
    // Fail silently, return transactions unchanged
    return transactions;
  }
};

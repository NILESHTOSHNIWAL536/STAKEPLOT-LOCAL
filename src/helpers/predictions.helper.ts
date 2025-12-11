import axios from "axios";
import { ServerConfig } from "@/config";

/**
 * Takes a list of transactions → returns same list with predicted categories appended.
 */
export const predictCategoriesForTransactions = async (transactions: any[]) => {
  if (!transactions.length) return transactions;

  try {
    const narrations = transactions.map((t) => t.narration);

    const { data } = await axios.post(`${ServerConfig.PREDICT_URL}/predict`, {
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

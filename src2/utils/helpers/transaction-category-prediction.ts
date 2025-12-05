import axios from 'axios';
import dotenv from 'dotenv';
dotenv.config();

import logger from '../common/logger';
import categories  from '../../config/categories';

// -------------------- Interfaces -------------------- //

export interface TransactionInput {
  category: string;
  type: string;
  mode: string;
  amount: number;
  transactionTimestamp: string | Date;
  narration: string;
  merchant?: string;
  [key: string]: any; // Allow dynamic fields
}

export interface RawPredictionResponse {
  [key: string]: string | number | undefined;
  top1_category?: string;
  top1_score?: number;
  top2_category?: string;
  top2_score?: number;
  top3_category?: string;
  top3_score?: number;
  top4_category?: string;
  top4_score?: number;
  top5_category?: string;
  top5_score?: number;
}

export interface CleanedPrediction {
  [key: string]: string | number;
  top1_category: string;
  top1_score: number;
  top2_category?: string;
  top2_score?: number;
  top3_category?: string;
  top3_score?: number;
  top4_category?: string;
  top4_score?: number;
  top5_category?: string;
  top5_score?: number;
}

// -------------------- Env Vars -------------------- //

const PREDICT_URL = process.env.PREDICT_URL as string;

// -------------------- Main Function -------------------- //

export async function transactionWithPredictions(txWithBank: TransactionInput[]): Promise<TransactionInput[]> {
  return Promise.all(
    txWithBank.map(async (tx) => {
      if (tx.category === 'Untagged') {
        try {
          const { data } = await axios.post<RawPredictionResponse>(`${PREDICT_URL}/predict`, {
            type: tx.type,
            mode: tx.mode,
            amount: tx.amount,
            transactionTimestamp: tx.transactionTimestamp,
            narration: tx.narration,
            merchant: tx.merchant ?? '',
          });

          const cleanData = cleanPredictions(data);
          return { ...tx, predictions: cleanData };
        } catch (err) {
          logger.error('Prediction failed:', err);
          return { ...tx, predictions: { error: 'Prediction failed' } };
        }
      }

      // Already tagged → return as-is
      return tx;
    })
  );
}

// -------------------- Category Helpers -------------------- //

function getMainCategory(subCategory: string): string {
  const lowerSub = subCategory.toLowerCase();

  // Exact match with main category
  for (const main of Object.keys(categories)) {
    if (main.toLowerCase() === lowerSub) {
      return main;
    }
  }

  // Match with subcategories
  for (const [mainCat, subCats] of Object.entries(categories)) {
    for (const sub of subCats) {
      if (sub.toLowerCase() === lowerSub) {
        return mainCat;
      }
    }
  }

  return subCategory;
}

function processCategories(data: RawPredictionResponse[]): Record<string, number> {
  const categoryScores: Record<string, number> = {};

  data.forEach((entry, index) => {
    const i = index + 1;
    const mainCat = getMainCategory(entry[`top${i}_category`] as string);
    const score = entry[`top${i}_score`] as number;

    if (!categoryScores[mainCat] || score > categoryScores[mainCat]) {
      categoryScores[mainCat] = score;
    }
  });

  return categoryScores;
}

function convertCategoryObjectToTopN(obj: Record<string, number>): CleanedPrediction {
  const entries = Object.entries(obj);

  // Sort by highest score
  entries.sort((a, b) => b[1] - a[1]);

  const result: CleanedPrediction = {
    top1_category: '',
    top1_score: 0,
  };

  entries.forEach(([category, score], index) => {
    const i = index + 1;
    result[`top${i}_category`] = category;
    result[`top${i}_score`] = score;
  });

  return result;
}

// -------------------- Prediction Cleaning -------------------- //

function cleanPredictions(predictions: RawPredictionResponse): CleanedPrediction {
  const temp: { category: string; score: number }[] = [];
  const arrayOfResult: RawPredictionResponse[] = [];

  // Collect scores for top1-top4 if > 0
  for (let i = 1; i <= 4; i++) {
    const category = predictions[`top${i}_category`] as string;
    const score = (predictions[`top${i}_score`] as number) ?? 0;

    if (score > 0) {
      temp.push({ category, score });
    }
  }

  // Always include top5
  temp.push({
    category: predictions[`top5_category`] as string,
    score: (predictions[`top5_score`] as number) || 1,
  });

  // Reformat entries
  temp.forEach((item, index) => {
    const i = index + 1;
    arrayOfResult.push({
      [`top${i}_category`]: item.category,
      [`top${i}_score`]: item.score,
    });
  });

  const processed = processCategories(arrayOfResult);
  return convertCategoryObjectToTopN(processed);
}

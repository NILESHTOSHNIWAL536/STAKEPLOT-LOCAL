const axios = require("axios");
const dotenv = require("dotenv");
dotenv.config();
const logger = require("../common/logger");
const { categories } = require("../../config/categories");

const PREDICT_URL = process.env.PREDICT_URL;

async function transactionWithPredictions(txWithBank) {
  return Promise.all(
    txWithBank.map(async (tx) => {
      if (tx.category === "Untagged") {
        try {
          const { data } = await axios.post(`${PREDICT_URL}/predict`, {
            type: tx.type,
            mode: tx.mode,
            amount: tx.amount,
            transactionTimestamp: tx.transactionTimestamp,
            narration: tx.narration,
            merchant: tx.merchant ?? "",
          });
          let cleanData = cleanPredictions(data);

          return { ...tx, predictions: cleanData };
        } catch (err) {
          return { ...tx, predictions: { error: "Prediction failed" } };
        }
      }

      // already tagged → just forward it unchanged
      return tx;
    })
  );
}

function getMainCategory(subCategory) {
  const lowerSubCategory = subCategory.toLowerCase();

  // Check if subCategory is already a main category (case-insensitive)
  for (const mainCat of Object.keys(categories)) {
    if (mainCat.toLowerCase() === lowerSubCategory) {
      return mainCat; // Return actual mainCat to preserve case
    }
  }

  // Check if it's a subcategory (case-insensitive)
  for (const [mainCat, subCats] of Object.entries(categories)) {
    for (const sub of subCats) {
      if (sub.toLowerCase() === lowerSubCategory) {
        return mainCat;
      }
    }
  }

  // Return original if no match found
  return subCategory;
}

function processCategories(data) {
  // Map to store categories with their highest scores
  try {
    const categoryScores = {};

    // Process each entry
    data.forEach((entry, index) => {
      const i = index + 1;
      const mainCat = getMainCategory(entry[`top${i}_category`]);
      const score = entry[`top${i}_score`];
      // Update if category doesn't exist or if new score is higher
      if (!categoryScores[mainCat] || score > categoryScores[mainCat].score) {
        categoryScores[mainCat] = score;
      }
    });

    return categoryScores;
  } catch (e) {
    console.log(e);
  }
}

function convertCategoryObjectToTopN(obj) {
  const entries = Object.entries(obj);

  // Sort by score descending
  entries.sort((a, b) => b[1] - a[1]);

  const result = {};

  entries.forEach(([category, score], index) => {
    const i = index + 1;
    result[`top${i}_category`] = category;
    result[`top${i}_score`] = score;
  });

  return result;
}

function cleanPredictions(predictions) {
  const result = {};
  const temp = [];
  const arrayOfResult = [];

  // Collect non-zero predictions (except 5th)
  for (let i = 1; i <= 4; i++) {
    const category = predictions[`top${i}_category`];
    const score = predictions[`top${i}_score`];

    if (score > 0) {
      temp.push({ category, score });
    }
  }

  // Always include 5th prediction
  temp.push({
    category: predictions[`top5_category`],
    score: predictions[`top5_score`] || 1,
  });

  // Reformat with top1_*, top2_*, etc.

  temp.forEach((entry, index) => {
    const i = index + 1;
    arrayOfResult.push({
      [`top${i}_category`]: entry.category,
      [`top${i}_score`]: entry.score,
    });
  });

  const result2 = processCategories(arrayOfResult);
  const finalResult = convertCategoryObjectToTopN(result2);

  return finalResult;
}

module.exports = transactionWithPredictions;

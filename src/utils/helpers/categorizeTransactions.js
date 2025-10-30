const { categories } = require("../../config/categories");

function categorizeTransactions(
  transactionsData,
  accountId,
  userId,
  bankId,
  ruleMap
) {
  return transactionsData.map((transaction) => {
    const narration = transaction.narration
      ? transaction.narration.toLowerCase()
      : "";
    let matchedCategory = "Untagged";
    let matchedSubcategory = "";
    let needsReview = false;

    // Step 1: Check transaction type for CREDIT
    if (transaction.type === "CREDIT") {
      matchedCategory = "Income";
      // Extract keyword from narration for subcategory
      const narrationParts = transaction.narration.split(/[-/]/);
      for (const part of narrationParts) {
        const trimmedPart = part.trim();
        if (
          trimmedPart &&
          trimmedPart !== "UPI" &&
          trimmedPart !== "CR" &&
          !trimmedPart.match(/^\d+$/)
        ) {
          matchedSubcategory = trimmedPart;
          break;
        }
      }
    } else {
      // Step 2: Derive narrationPattern consistent with groupSimilarTransactions
      let narrationPattern = narration;
      if (narration.includes("/")) {
        const splitNarration = narration.split("/");
        if (splitNarration.length >= 5) {
          narrationPattern = `${splitNarration[3]}/${splitNarration[4]}`;
        }
      }

      // Step 3: Check for matching TransactionRule
      const ruleKey = `${narrationPattern}_${transaction.amount}`;
      const matchingRule = ruleMap.get(ruleKey);

      if (matchingRule) {
        // Apply rule-based categorization
        matchedCategory = matchingRule.category || "Untagged";
        matchedSubcategory = matchingRule.subcategory || "";
        needsReview = true;
      } else {
        // Step 4: Fall back to existing categorization logic
        // Special handling for UPI-CR transactions
        if (narration.startsWith("upi-cr") || narration.startsWith("upi cr")) {
          matchedCategory = "Personal Transfer Received";
          const narrationParts = transaction.narration.split("-");
          if (narrationParts.length > 2) {
            matchedSubcategory = narrationParts[2].trim();
          }
        }
        // Special handling for Personal Transfer
        else if (
          narration.startsWith("pos") ||
          narration.startsWith("cash wdl") ||
          narration.startsWith("atm") ||
          narration.startsWith("to:")
        ) {
          matchedCategory = "Personal Transfer";
          matchedSubcategory = "";
        }
        // Special handling for Income (credit transactions)
        else if (
          narration.startsWith("neft-cr") ||
          narration.startsWith("neft cr")
        ) {
          for (const keyword of categories["Income"] || []) {
            const regex = new RegExp(`\\b${keyword.toLowerCase()}\\b`, "i");
            if (regex.test(narration)) {
              matchedCategory = "Income";
              matchedSubcategory = keyword;
              break;
            }
          }
        }
        // Regular category matching
        else {
          for (const [category, keywords] of Object.entries(categories)) {
            for (const keyword of keywords) {
              const regex = new RegExp(`\\b${keyword.toLowerCase()}\\b`, "i");
              if (regex.test(narration)) {
                matchedCategory = category;
                matchedSubcategory = keyword;
                break;
              }
            }
            if (matchedCategory !== "Untagged") break;
          }
        }
      }
    }

    return {
      ...transaction,

      // Handle either field name, parse if it’s a string with commas
      currentBalance: (() => {
        const raw =
          transaction.transactionalBalance ?? transaction.currentBalance ?? 0;

        return typeof raw === "string"
          ? parseFloat(raw.replace(/,/g, ""))
          : raw;
      })(),

      transactionTimestamp: transaction.transactionTimestamp
        ? new Date(transaction.transactionTimestamp)
        : null,
      valueDate: transaction.valueDate ? new Date(transaction.valueDate) : null,

      category: matchedCategory,
      subcategory: transaction.subcategory || matchedSubcategory,

      manualTransaction:
        transaction.manualTransaction !== undefined
          ? transaction.manualTransaction
          : false,

      accountId,
      userId,
      bankId,

      needsReview: needsReview || false,
    };
  });
}

module.exports = { categorizeTransactions };

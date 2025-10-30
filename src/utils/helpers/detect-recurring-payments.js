const mongoose = require("mongoose");
const autoPayMerchants = require("../../config/autoPayMerchants");
const { Transaction, RecurringPayment } = require("../../models/index");

function globalExcludeIf(txn) {
  return (
    /zomato|swiggy|food|eat|meals/i.test(txn.narration || "") ||
    txn.category?.toLowerCase() === "food"
  );
}

function normalizeNarration(narration) {
  return (narration || "")
    .toUpperCase()
    .replace(/[^A-Z0-9 ]+/g, " ") // Remove special chars
    .replace(/\b\d+\b/g, "") // Remove standalone numbers
    .replace(/\b(UPI|IMPS|NEFT|RTGS|TO|FROM|REF|TXN)\b/g, "") // Remove common UPI/IMPS/NEFT terms
    .replace(/\s+/g, " ") // Normalize multiple spaces
    .trim()
    .split(" ")
    .filter((word) => word.length > 3) // Keep words longer than 3 chars
    .slice(0, 2) // Take top 2 keywords
    .join("_");
}

function inferFrequency(transactions) {
  if (transactions.length < 2) return null;

  const intervals = [];
  for (let i = 1; i < transactions.length; i++) {
    const diffDays =
      (new Date(transactions[i].transactionTimestamp) -
        new Date(transactions[i - 1].transactionTimestamp)) /
      (1000 * 60 * 60 * 24);
    intervals.push(diffDays);
  }

  const avg = intervals.reduce((a, b) => a + b, 0) / intervals.length;

  if (Math.abs(avg - 1) <= 0.5) return "daily";
  if (Math.abs(avg - 7) <= 2) return "weekly";
  if (Math.abs(avg - 30) <= 5) return "monthly";
  if (Math.abs(avg - 90) <= 10) return "quarterly";
  if (Math.abs(avg - 180) <= 15) return "biannual";

  return null;
}

function calculateNextReminder({ recentMostTransactionTimestamp, frequency }) {
  const msInDay = 24 * 60 * 60 * 1000;
  const now = new Date();
  let baseDate = new Date(recentMostTransactionTimestamp);

  if (isNaN(baseDate)) {
    throw new Error(`Invalid base date: ${recentMostTransactionTimestamp}`);
  }

  let nextTxnDate = new Date(baseDate);

  const advanceDate = (date) => {
    switch (frequency) {
      case "daily":
        date.setUTCDate(date.getUTCDate() + 1);
        break;
      case "weekly":
        date.setUTCDate(date.getUTCDate() + 7);
        break;
      case "monthly":
        date.setUTCMonth(date.getUTCMonth() + 1);
        break;
      case "quarterly":
        date.setUTCMonth(date.getUTCMonth() + 3);
        break;
      case "biannual":
        date.setUTCMonth(date.getUTCMonth() + 6);
        break;
      default:
        throw new Error(`Unknown frequency: ${frequency}`);
    }
  };

  // Keep advancing until the nextTxnDate is in the future
  while (nextTxnDate.getTime() <= now.getTime()) {
    advanceDate(nextTxnDate);
  }

  // Subtract 2 days for reminder, but never go before 'now'
  let reminderDate = new Date(nextTxnDate.getTime() - 2 * msInDay);
  if (reminderDate.getTime() <= now.getTime()) {
    reminderDate = now;
  }

  // Set time to 9:00 AM UTC
  reminderDate.setUTCHours(9, 0, 0, 0);

  return reminderDate;
}

async function detectRecurringPayments(userId, options = {}) {
  const { fromDate, timeWindowMonths = 4 } = options;

  let cutoffDate;

  if (fromDate) {
    cutoffDate = new Date(fromDate);
  } else {
    cutoffDate = new Date();
    cutoffDate.setMonth(cutoffDate.getMonth() - timeWindowMonths);
  }

  const transactions = await Transaction.find({
    userId: new mongoose.Types.ObjectId(userId),
    transactionTimestamp: { $gte: cutoffDate },
    type: "DEBIT",
  });

  const merchantGrouped = {};
  const genericGrouped = {};

  for (const txn of transactions) {
    const matchedMerchant = autoPayMerchants.find(
      (m) =>
        m.regex.test(txn.narration) &&
        !globalExcludeIf(txn) &&
        !m.excludeIf?.(txn)
    );

    const roundedAmount = Math.round(txn.amount / 10) * 10;

    if (matchedMerchant) {
      const key = `${matchedMerchant.name}_${roundedAmount}`;
      if (!merchantGrouped[key]) merchantGrouped[key] = [];
      merchantGrouped[key].push({
        ...txn.toObject(),
        merchant: matchedMerchant.name,
      });
    } else {
      const keyword = normalizeNarration(txn.narration);
      const key = `${keyword}_${roundedAmount}`;
      if (!genericGrouped[key]) genericGrouped[key] = [];
      genericGrouped[key].push({ ...txn.toObject(), merchant: keyword });
    }
  }

  const autoPays = [];

  function processGroups(grouped, isKnownMerchant = false) {
    for (const txns of Object.values(grouped)) {
      if (txns.length < 2) continue;

      txns.sort(
        (a, b) =>
          new Date(a.transactionTimestamp) - new Date(b.transactionTimestamp)
      );

      // fetch the frequency of the occurence (daily, weekly, monthly)
      const frequency = inferFrequency(txns);

      if (frequency) {
        const mostRecent = txns[txns.length - 1];
        autoPays.push({
          recentMostTransactionId: mostRecent._id,
          merchant: mostRecent.merchant,
          frequency,
          amount: mostRecent.amount,
          recentMostTransactionTimestamp: mostRecent.transactionTimestamp,
          narration: mostRecent.narration,
          source: isKnownMerchant ? "merchantMatch" : "patternMatch",
          recentMostTwoOccurrences: txns
            .slice(-2)
            .map((t) => t.transactionTimestamp),
          occurrencesCount: txns.length,
          nextReminderAt: calculateNextReminder({
            recentMostTransactionTimestamp: mostRecent.transactionTimestamp,
            frequency,
          }),
        });
      }
    }
  }

  // process the merchantGrouped, genericGrouped(pattern matched) json's
  processGroups(merchantGrouped, true);
  processGroups(genericGrouped, false);

  // Insert the documents in the DB
  const docsToInsert = autoPays.map((autopay) => ({ ...autopay, userId }));
  await RecurringPayment.insertMany(docsToInsert);

  return autoPays;
}

module.exports = detectRecurringPayments;

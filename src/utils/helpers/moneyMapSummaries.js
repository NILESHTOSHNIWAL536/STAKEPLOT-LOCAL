const { getCurrentWeekRange } = require("../helpers/getCurrentWeekRange");

async function getMonthlySummaryForMoneyMap(transactions) {
  const today = new Date();
  const currentMonth = today.getMonth()+1;
  const currentYear = today.getFullYear();
  const previousMonth = currentMonth === 0 ? 11 : currentMonth - 1;
  const previousMonthYear = currentMonth === 0 ? currentYear - 1 : currentYear;


  // Initialize summary structure
  const summary = {
    totalSpent: 0,
    spent: {},
    previousDays: [
      { totalSpent: 0 }, // yesterday
      { totalSpent: 0 }, // day before
      { totalSpent: 0 }, // two days before
    ],
    subscriptions: [],
    income: 0,
    previousMonth: {
      income: 0,
      spent: {},
    },
    swiggyOrder: {
    count: 0,
    totalAmount: 0
    },
    zomatoOrder: {
      count: 0,
      totalAmount: 0
    }
  };

  // Process transactions
  transactions.forEach((txn) => {
    if (!txn.amount) return;

    const txnDateRaw = txn.transactionTimestamp;
    const txnDate = txnDateRaw ? new Date(txnDateRaw) : null;
    if (!txnDate) return;

    const txnMonth = txnDate.getMonth()+1;
    const txnYear = txnDate.getFullYear();

    // Skip "Untagged" categories
    const category = txn.category?.toLowerCase() || "uncategorized";
    if (category === "untagged") return;

    if (txn.type === "CREDIT") {
      // Income calculation (assumed to always be current month only)
      if (txnMonth === currentMonth && txnYear === currentYear) {
        summary.income += txn.amount;
      } else if (txnMonth === previousMonth && txnYear === previousMonthYear){
        summary.previousMonth.income += txn.amount;
      }
    } else if (txn.type === "DEBIT") {
      const category = txn.category?.toLowerCase() || "uncategorized";

      if (txnMonth === currentMonth && txnYear === currentYear) {
        // Current month spending
        summary.spent[category] = (summary.spent[category] || 0) + txn.amount;
      } else if (txnMonth === previousMonth && txnYear === previousMonthYear) {
        // Previous month spending
        summary.previousMonth.spent[category] = (summary.previousMonth.spent[category] || 0) + txn.amount;
      }

      // Handle subscriptions (current month only, as per your logic)
      if (txnMonth === currentMonth && txnYear === currentYear) {
        const subcategory = txn.subcategory?.toLowerCase() || "";
        if (["netflix", "spotify"].includes(subcategory)) {
          const existingSub = summary.subscriptions.find(sub => sub.name.toLowerCase() === subcategory);
          if (!existingSub) {
            summary.subscriptions.push({
              name: subcategory.charAt(0).toUpperCase() + subcategory.slice(1),
              amount: txn.amount,
              nextRenewalDate: new Date(txnDate.getTime() + 30 * 24 * 60 * 60 * 1000) // Assume 30-day renewal
            });
          }
        }
        // ✅ Swiggy / Zomato tracking separately
        if (subcategory === "Swiggy") {
          summary.swiggyOrder.count += 1;
          summary.swiggyOrder.totalAmount += txn.amount;
        } else if (subcategory === "Zomato") {
          summary.zomatoOrder.count += 1;
          summary.zomatoOrder.totalAmount += txn.amount;
        }
      }

      // Calculate previous days' spending (only for current month transactions)
      const daysDiff = Math.floor((today - txnDate) / (24 * 60 * 60 * 1000));
      if (daysDiff >= 0 && daysDiff < 3) {
        summary.previousDays[daysDiff].totalSpent += txn.amount;
      }
    }
  });

  summary.totalSpent = Object.values(summary.spent).reduce((a, b) => a + b, 0);
  return summary;
}

async function getWeeklySummaryForMoneyMap(transactions) {
  const { currentWeekStart, currentWeekEnd } = getCurrentWeekRange();

  // Initialize summary structure
  const summary = {
    totalSpent: 0,
    spent: {},
    weekdaySpent: 0,
    weekendSpent: 0,
    orders: {
      swiggy: 0,
      zomato: 0,
      eatsure: 0
    },
    count: 0
  };

  // Process transactions
  transactions.forEach((txn) => {
    if (txn.type !== "DEBIT" || !txn.amount) return;

    const txnDate = new Date(txn.transactionTimestamp.$date);
    if (txnDate < currentWeekStart || txnDate > currentWeekEnd) return;

    // Accumulate total spent
    summary.totalSpent += txn.amount;

    // Categorize spending
    const category = txn.category.toLowerCase();
    summary.spent[category] = (summary.spent[category] || 0) + txn.amount;

    // Calculate weekday vs weekend spending
    const isWeekend = txnDate.getDay() === 0 || txnDate.getDay() === 6;
    if (isWeekend) {
      summary.weekendSpent += txn.amount;
    } else {
      summary.weekdaySpent += txn.amount;
    }

    // Handle food delivery orders (special case for swiggy, zomato, eatsure in subcategory)
    const subcategory = txn.subcategory?.toLowerCase() || "";
    if (subcategory in summary.orders) {
      summary.orders[subcategory] += 1; // Count orders, not amount
    }

    summary.count += 1;
  });

  return summary;
}

module.exports = { getMonthlySummaryForMoneyMap, getWeeklySummaryForMoneyMap };
// Function to fill missing dates for weekly/monthly budgets
const fillMissingDatesAndCalculateTotals = (transactions, startDate, endDate) => {
  let totalDebitAmount = 0;
  let totalCreditAmount = 0;

  const transactionsMap = new Map();

  transactions.forEach((tx) => {
    let formattedDate = tx._id;

    // Check if the _id is in "DD-MM-YYYY" format and convert it to "YYYY-MM-DD"
    if (/^\d{2}-\d{2}-\d{4}$/.test(tx._id)) {
      const [day, month, year] = tx._id.split("-");
      formattedDate = `${year}-${month}-${day}`;
    }

    transactionsMap.set(formattedDate, { ...tx, _id: formattedDate });
  });

  const filledTransactions = [];
  let currentDate = new Date(startDate);

  while (currentDate < endDate) {
    const dateString = currentDate.toISOString().split("T")[0];

    const transaction = transactionsMap.get(dateString) || {
      _id: dateString,
      debitTotalAmount: 0,
      creditTotalAmount: 0,
      debit: {},
      credit: {},
    };

    // Accumulate totals
    totalDebitAmount += transaction.debitTotalAmount;
    totalCreditAmount += transaction.creditTotalAmount;

    filledTransactions.push(transaction);
    currentDate.setDate(currentDate.getDate() + 1);
  }

  return {
    transactions: filledTransactions,
    totalDebitAmount,
    totalCreditAmount,
  };
};

// Function to fill missing months for yearly budgets
const fillMissingMonthsAndCalculateTotals = (transactions, startDate, endDate) => {
  let totalDebitAmount = 0;
  let totalCreditAmount = 0;

  // Convert transactions array to a Map for quick lookup (assuming _id is month name)
  const transactionsMap = new Map(transactions.map((tx) => [tx._id, tx]));

  // Generate month names between startDate and endDate
  const allMonths = [];
  let currentDate = new Date(startDate);
  while (currentDate <= endDate) {
    const monthName = currentDate.toLocaleString("default", {
      month: "long",
    });
    if (!allMonths.includes(monthName)) {
      allMonths.push(monthName);
    }
    currentDate.setMonth(currentDate.getMonth() + 1);
  }

  // Create the final response ensuring all months are present
  const filledTransactions = allMonths.map((month) => {
    const transaction = transactionsMap.get(month) || {
      _id: month,
      debitTotalAmount: 0,
      creditTotalAmount: 0,
      debit: {},
      credit: {},
    };

    // Accumulate totals
    totalDebitAmount += transaction.debitTotalAmount;
    totalCreditAmount += transaction.creditTotalAmount;

    return transaction;
  });

  return {
    transactions: filledTransactions,
    totalDebitAmount,
    totalCreditAmount,
  };
};


module.exports = {fillMissingDatesAndCalculateTotals, fillMissingMonthsAndCalculateTotals};
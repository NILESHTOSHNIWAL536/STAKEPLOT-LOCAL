// utils/dateUtils.js
const getStartDateOfISOWeek = (weekNum, year) => {
  const simple = new Date(year, 0, 1 + (weekNum - 1) * 7);
  const dayOfWeek = simple.getDay();
  const ISOweekStart = simple;
  if (dayOfWeek <= 4)
    ISOweekStart.setDate(simple.getDate() - simple.getDay() + 1);
  else ISOweekStart.setDate(simple.getDate() + 8 - simple.getDay());
  return ISOweekStart;
};

const getDateRange = (type, value) => {
  let startDate, endDate, groupBy = "day";

  if (type === "month") {
    const [year, month] = value.split('-');
    const y = parseInt(year, 10);
    const m = parseInt(month, 10) - 1; // JS month index 0-11

    startDate = new Date(Date.UTC(y, m, 1, 0, 0, 0, 0)); // Start of month
    endDate = new Date(Date.UTC(y, m + 1, 0, 23, 59, 59, 999)); // End of month
  } 

  else if (type === "week") {
    const [year, weekNumber] = value.split("-W");
    const weekNum = parseInt(weekNumber, 10);

    startDate = getStartDateOfISOWeek(weekNum, parseInt(year, 10));
    startDate = new Date(Date.UTC(startDate.getUTCFullYear(), startDate.getUTCMonth(), startDate.getUTCDate(), 0, 0, 0, 0));

    endDate = new Date(startDate);
    endDate.setUTCDate(endDate.getUTCDate() + 6);
    endDate.setUTCHours(23, 59, 59, 999);
  } 

  else if (type === "custom") {
    const [start, end] = value.split(",");
    startDate = new Date(start); // Assume user sends ISO format (YYYY-MM-DD or full ISO)
    endDate = new Date(end);
    startDate.setUTCHours(0, 0, 0, 0);
    endDate.setUTCHours(23, 59, 59, 999);
  } 

  else if (type === "year") {
    const y = parseInt(value, 10);

    startDate = new Date(Date.UTC(y, 0, 1, 0, 0, 0, 0)); // Jan 1st
    endDate = new Date(Date.UTC(y, 11, 31, 23, 59, 59, 999)); // Dec 31st
    groupBy = "month";
  } 
  
  else {
    throw new Error("Invalid type parameter");
  }

  return { startDate, endDate, groupBy };
};


const initializeResults = (type, startDate, endDate, monthNames) => {
  const result = {};

  if (type === "year") {
    for (let month = 0; month < 12; month++) {
      result[monthNames[month]] = { debit: 0, credit: 0 };
    }
  } else {
    while (startDate <= endDate) {
      const dateString = startDate.toISOString().split("T")[0];
      result[dateString] = { debit: 0, credit: 0 };
      startDate.setDate(startDate.getDate() + 1);
    }
  }

  return result;
};

const fillTransactionData = (response, result, type, monthNames) => {
  let minAmount = 0;
  let maxAmount = 0;
  let totalDebit = 0;
  let totalCredit = 0;

  response.forEach(({ _id, debit, credit }) => {
    if (type === "year") {
      const [, month] = _id.date.split("-");
      const monthIndex = parseInt(month, 10) - 1;
      const monthKey = monthNames[monthIndex];

      if (monthKey) {
        result[monthKey] = { debit, credit };
      }
    } else {
      const dateString = _id.date;
      if (result[dateString]) {
        result[dateString] = { debit, credit };
      }
    }

    minAmount = Math.min(minAmount, debit, credit);
    maxAmount = Math.max(maxAmount, debit, credit);
    totalDebit += debit;
    totalCredit += credit;
  });

  return { result, minAmount, maxAmount, totalDebit, totalCredit };
};

module.exports = {
  getDateRange,
  initializeResults,
  fillTransactionData,
};

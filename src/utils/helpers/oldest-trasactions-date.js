const mongoose = require("mongoose");
const {Transaction} = require("../../models/"); // adjust path

async function getOldestTransactionMonthYear(userId)
{
  const result = await Transaction
    .findOne({ userId: new mongoose.Types.ObjectId(userId) })
    .sort({ transactionTimestamp: 1 })
    .select({ transactionTimestamp: 1 })
    .lean(); 

  if (!result) {
    return ''; 
  }

  const date = new Date(result.transactionTimestamp);
  const firstOfMonth = new Date(date.getFullYear(), date.getMonth(), 1); // Proper date: 1st of that month
  return firstOfMonth;
}


module.exports = {getOldestTransactionMonthYear};
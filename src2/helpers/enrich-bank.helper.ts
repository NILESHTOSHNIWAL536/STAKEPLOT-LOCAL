// src2/helpers/enrich-bank.helper.ts

export const enrichWithBankDetails = async (
  transactions: any[],
  banks: any[]
) => {
  const bankMap = new Map(banks.map((b: any) => [String(b._id), b]));

  return transactions.map((tx) => {
    const acc = tx.accountId ? bankMap.get(String(tx.accountId.bankId)) : null;
    return {
      ...tx,
      bank: acc ?? null
    };
  });
};

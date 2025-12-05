export interface TransactionInput {
  narration: string;
  type: string; // e.g., "CREDIT" | "DEBIT"
  amount: number;
  transactionalBalance?: number | string;
  currentBalance?: number | string;
  transactionTimestamp?: string | Date | null;
  valueDate?: string | Date | null;
  subcategory?: string;
  manualTransaction?: boolean;
  [key: string]: any; // fallback for extra fields
}

export function deduplicateTransactions<T extends TransactionInput>(transactions: T[]): T[] {
  const seen = new Map<string, boolean>();

  return transactions.filter((transaction) => {
    const { narration, transactionTimestamp, amount } = transaction;

    // Normalize to lowercase + trimmed narration
    const narrationKey = narration?.trim().toLowerCase() ?? '';

    // Convert timestamp to a consistent comparable form
    const timestampKey = transactionTimestamp instanceof Date ? transactionTimestamp.toISOString() : transactionTimestamp;

    const key = `${narrationKey}_${timestampKey}_${amount}`;

    if (seen.has(key)) {
      return false; // duplicate found
    }

    seen.set(key, true);
    return true;
  });
}

export default { deduplicateTransactions };

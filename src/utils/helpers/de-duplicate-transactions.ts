import { IBankTransaction } from '@/types/bank';

function deduplicateTransactions<T extends IBankTransaction>(transactions: Partial<T>[]): Partial<T>[] {
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

export default deduplicateTransactions;

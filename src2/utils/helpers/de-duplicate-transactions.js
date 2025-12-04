function deduplicateTransactions(transactions) {
    const seen = new Map();

    // Filter transactions based on unique key (narration + timestamp + amount)
    return transactions.filter(transaction => {
        const { narration, transactionTimestamp, amount } = transaction;
        // Create a unique key for the transaction
        const key = `${narration.trim().toLowerCase()}_${transactionTimestamp}_${amount}`;

        // If the key is already seen, skip this transaction (it's a duplicate)
        if (seen.has(key)) {
            return false;
        }

        // Mark this transaction as seen
        seen.set(key, true);
        return true;
    });
}

module.exports = { deduplicateTransactions };
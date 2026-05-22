/**
 * Response-layer timestamp formatter.
 *
 * MongoDB stores all timestamps in UTC. Before sending transactions to the
 * client we convert every known timestamp field to an IST ISO string so the
 * frontend receives human-readable Indian time (e.g. "2024-01-15T12:57:15+05:30").
 *
 * Usage:
 *   res.json({ data: toISTArray(transactions) })
 *   res.json({ data: toISTArray(singleTransaction) })
 */

// IST = UTC + 5 hours 30 minutes
const IST_OFFSET_MS = (5 * 60 + 30) * 60 * 1000;

// Fields that hold transaction timestamps and should be converted.
const TIMESTAMP_FIELDS = ['transactionTimestamp', 'valueDate'];

/**
 * Converts a single UTC Date / ISO string to an IST ISO 8601 string.
 *
 * e.g. 2026-04-04T07:27:15.000Z  →  "2026-04-04T12:57:15.000+05:30"
 *
 * Returns undefined for null / undefined / invalid inputs.
 */
export function toISTString(date: Date | string | null | undefined): string | undefined {
  if (date == null) return undefined;

  // Coerce to a JS Date
  const d = date instanceof Date ? date : new Date(String(date));
  if (isNaN(d.getTime())) return undefined;

  // Shift to IST by adding the offset, then format with +05:30 suffix
  const ist = new Date(d.getTime() + IST_OFFSET_MS);
  // toISOString() always produces UTC ("Z"), strip the Z and append +05:30
  return ist.toISOString().replace('Z', '+05:30');
}

/**
 * Converts timestamp fields on a single transaction object to IST strings.
 *
 * Works with:
 *  - Plain JS objects (lean Mongoose results, enriched objects)
 *  - Mongoose Documents (calls .toObject() to strip the prototype first)
 */
export function toIST<T extends Record<string, any>>(tx: T): T {
  if (!tx || typeof tx !== 'object' || Array.isArray(tx)) return tx;

  // Flatten to a truly plain object so property access is predictable
  let plain: Record<string, any>;
  if (typeof (tx as any).toObject === 'function') {
    // Full Mongoose Document
    plain = (tx as any).toObject({ getters: false, virtuals: false });
  } else if (typeof (tx as any).toJSON === 'function') {
    // Some Mongoose lean/schema objects expose toJSON
    plain = (tx as any).toJSON();
  } else {
    // Already a plain object — use Object.assign to avoid spread losing getters
    plain = Object.assign({}, tx);
  }

  for (const field of TIMESTAMP_FIELDS) {
    const raw = plain[field];
    if (raw == null) continue;

    const converted = toISTString(raw);
    if (converted !== undefined) {
      plain[field] = converted;
    }
  }

  return plain as T;
}

/**
 * Converts timestamp fields on an array of transactions, or a single transaction.
 * Safe to call with null / undefined — returns the input unchanged.
 */
export function toISTArray<T extends Record<string, any>>(txs: T | T[] | null | undefined): T | T[] | null | undefined {
  if (txs == null) return txs;
  if (Array.isArray(txs)) return txs.map(toIST);
  return toIST(txs);
}

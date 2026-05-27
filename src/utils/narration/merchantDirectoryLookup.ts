import MerchantDirectory from '@/models/transactions-automation/merchantDirectory';
import { ParsedNarration } from './types';

export interface MerchantMatch {
  category: string;
  subcategory: string;
  key: string;
}

/**
 * Normalizes a raw merchant name or VPA into a stable, comparable key.
 *
 * - Lowercased
 * - Whitespace collapsed to single space and trimmed
 * - UPI VPAs left as-is after lowercasing (they are already stable)
 */
export function normalizeMerchantKey(raw: string): string {
  return raw.toLowerCase().replace(/\s+/g, ' ').trim();
}

/**
 * Looks up a merchant in the cross-user directory.
 *
 * Resolution order:
 *   1. counterpartyVPA (primary — most stable identifier)
 *   2. normalized counterpartyName (secondary — fallback when VPA is a raw account number)
 *
 * Returns null when no entry exists (caller should fall through to keyword config).
 */
export async function lookupMerchantDirectory(
  parsed: ParsedNarration | null,
): Promise<MerchantMatch | null> {
  if (!parsed) return null;

  const candidates: string[] = [];

  // Primary: VPA — skip if it looks like a raw account number (all digits)
  if (parsed.counterpartyVPA && !/^\d+$/.test(parsed.counterpartyVPA)) {
    candidates.push(normalizeMerchantKey(parsed.counterpartyVPA));
  }

  // Secondary: normalized merchant name
  if (parsed.counterpartyName) {
    candidates.push(normalizeMerchantKey(parsed.counterpartyName));
  }

  if (candidates.length === 0) return null;

  const entry = await MerchantDirectory.findOne({ key: { $in: candidates } })
    .select('key category subcategory')
    .lean();

  if (!entry) return null;

  return {
    category: entry.category,
    subcategory: entry.subcategory,
    key: entry.key,
  };
}

/**
 * Persists a merchant → category mapping into the directory.
 * Uses upsert so it is safe to call multiple times for the same key.
 *
 * @param key          Normalized VPA or merchant name (use normalizeMerchantKey)
 * @param category     Resolved category string
 * @param subcategory  Resolved subcategory string
 * @param resolvedBy   Source of this resolution
 * @param confidence   0–1 confidence score (default 0.9 for user corrections)
 */
export async function upsertMerchantDirectory(
  key: string,
  category: string,
  subcategory: string,
  resolvedBy: 'user_correction' | 'keyword' | 'llm',
  confidence = 0.9,
): Promise<void> {
  await MerchantDirectory.findOneAndUpdate(
    { key },
    {
      $set: {
        category,
        subcategory,
        resolvedBy,
        confidenceScore: confidence,
      },
    },
    { upsert: true },
  );
}

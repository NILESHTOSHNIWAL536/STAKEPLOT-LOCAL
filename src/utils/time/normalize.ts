/**
 * 🚨 CRITICAL:
 * All transaction timestamps MUST pass through this function.
 * Do NOT use new Date() directly for external data.
 */

import moment from 'moment-timezone';
import { BANK_TIMEZONE_CONFIG } from '@/config/bankTimezone';

const DEFAULT_TZ = 'Asia/Kolkata';

/**
 * Maps a raw bank identifier (FIP ID, DB string, or similar) to a logical
 * bank key used to look up timezone config.
 *
 * Priority:
 *  1. Direct match in BANK_TIMEZONE_CONFIG (e.g. 'FINVU', 'sbi-fip')
 *  2. Case-insensitive match
 *  3. Falls back to 'UNKNOWN' → normalizer treats timestamp as IST (safe default)
 */
export function getBankKey(bankId: string | null | undefined): string {
  if (!bankId) return 'UNKNOWN';

  // Direct match
  if (bankId in BANK_TIMEZONE_CONFIG) return bankId;

  // Case-insensitive scan
  const upper = bankId.toUpperCase();
  for (const key of Object.keys(BANK_TIMEZONE_CONFIG)) {
    if (key.toUpperCase() === upper) return key;
  }

  return 'UNKNOWN';
}

/**
 * Normalizes an incoming transaction timestamp to a correct UTC Date.
 *
 * Behaviour matrix:
 *  - Already a Date object            → returned as-is (assumed already correct)
 *  - ISO string with Z / +offset:
 *      bankKey = 'UTC'  → parse literally (bank is trustworthy)
 *      bankKey = 'IST'  → reinterpret the wall-clock time as IST, then convert to UTC
 *                         (bank sends IST but incorrectly labels it UTC)
 *  - String without timezone info     → assume IST, convert to UTC
 *  - null / undefined                 → returns undefined
 */
export function normalizeTransactionTimestamp(
  input: string | Date | null | undefined,
  bankKey: string,
): Date | undefined {
  if (input == null) return undefined;

  // Already a JS Date — assume caller supplied a correct UTC Date
  if (input instanceof Date) return input;

  const config = BANK_TIMEZONE_CONFIG[bankKey];

  // ISO string that explicitly carries timezone info (ends in Z or contains +)
  const hasExplicitTz = input.endsWith('Z') || /[+\-]\d{2}:?\d{2}$/.test(input);
  console.log("has Expits: ", hasExplicitTz);

  let normalized: Date | undefined;

  if (hasExplicitTz) {
    if (config === 'UTC') {
      // Bank is trustworthy — parse the offset at face value
      normalized = new Date(input);
    } else {
      // config === 'IST' or unknown: bank sent IST disguised as UTC.
      // Strip the timezone decorator and reinterpret the wall-clock as IST.
      const wallClock = input
        .replace(/Z$/, '')
        .replace(/[+\-]\d{2}:?\d{2}$/, '');
      normalized = moment.tz(wallClock, DEFAULT_TZ).utc().toDate();
    }
  } else {
    // No timezone info at all → assume IST
    normalized = moment.tz(input, DEFAULT_TZ).utc().toDate();
  }

  // Guard against invalid dates produced by malformed input
  if (!normalized || isNaN(normalized.getTime())) {
    console.warn('[normalizeTransactionTimestamp] Could not parse timestamp', { bankKey, input });
    return undefined;
  }

  console.log('[normalizeTransactionTimestamp]', { bankKey, raw: input, normalized });

  return normalized;
}

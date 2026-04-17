/**
 * Maps logical bank keys to their known timestamp timezone behaviour.
 *
 * 'UTC' → the bank sends genuine UTC timestamps (trust them as-is).
 * 'IST' → the bank sends IST timestamps (possibly mislabelled as UTC).
 *
 * If a bank key is NOT present here, the normalizer falls back to treating
 * the timestamp as IST, which is the safe default for Indian banks.
 */
export const BANK_TIMEZONE_CONFIG: Record<string, 'UTC' | 'IST'> = {
  'IOB-FIP': 'UTC',
  'KarurVysyaBank-FIP': 'IST',
  'BOI-FIP': 'IST',
  BARBFIP: 'UTC',
  'UBI-FIP': 'IST',
  'sbi-fip': 'IST',
  'HDFC-FIP': 'IST'
  // Add more banks as their behaviour is confirmed, e.g.:
  // 'sbi-fip': 'IST',
  // 'HDFC-FIP': 'IST',
  // 'ICICI-FIP': 'IST',
};

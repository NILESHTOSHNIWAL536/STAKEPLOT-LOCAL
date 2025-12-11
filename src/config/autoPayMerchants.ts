export interface TransactionForAutoPayCheck {
  category?: string;
  subcategory?: string;
  narration?: string;
}

export interface AutoPayMerchant {
  name: string;
  regex: RegExp;
  expectedFrequency: 'monthly' | 'weekly' | 'yearly';
  excludeIf?: (txn: TransactionForAutoPayCheck) => boolean;
}

const autoPayMerchants: AutoPayMerchant[] = [
  { name: 'Netflix', regex: /NETFLIX/i, expectedFrequency: 'monthly' },
  { name: 'Prime Video', regex: /AMAZON.*PRIME|PRIME.*VIDEO/i, expectedFrequency: 'monthly' },
  { name: 'Disney+ Hotstar', regex: /DISNEY|HOTSTAR/i, expectedFrequency: 'monthly' },
  { name: 'SonyLIV', regex: /SONYLIV/i, expectedFrequency: 'monthly' },
  { name: 'Zee5', regex: /ZEE5/i, expectedFrequency: 'monthly' },
  { name: 'JioCinema', regex: /JIOCINEMA/i, expectedFrequency: 'monthly' },
  { name: 'Sun NXT', regex: /SUNNXT|SUN\s*NXT/i, expectedFrequency: 'monthly' },
  { name: 'Aha', regex: /AHA/i, expectedFrequency: 'monthly' },
  { name: 'Apple TV+', regex: /APPLE\s*TV|\bTV\s*PLUS\b/i, expectedFrequency: 'monthly' },
  { name: 'MX Player', regex: /MX\s*PLAYER/i, expectedFrequency: 'monthly' },
  { name: 'Discovery+', regex: /DISCOVERY\+/i, expectedFrequency: 'monthly' },
  { name: 'Voot', regex: /VOOT/i, expectedFrequency: 'monthly' },
  { name: 'ALTBalaji', regex: /ALT\s*BALA?JI/i, expectedFrequency: 'monthly' },
  { name: 'Spotify', regex: /SPOTIFY/i, expectedFrequency: 'monthly' },
  { name: 'YouTube', regex: /YOUTUBE/i, expectedFrequency: 'monthly' },
  { name: 'Lenskart', regex: /LENSKART/i, expectedFrequency: 'monthly' },
  { name: 'Jar', regex: /\bJAR\b/i, expectedFrequency: 'monthly' },
  { name: "BYJU'S", regex: /BYJU'?S/i, expectedFrequency: 'monthly' },
  { name: 'PVR', regex: /\bPVR\b/i, expectedFrequency: 'monthly' },
  { name: 'Tata Sky', regex: /TATA\s*SKY/i, expectedFrequency: 'monthly' },
  {
    name: 'Airtel',
    regex: /\bAIRTEL(?:\s*(RECHARGE|PAYMENT|BILL))?\b/i,
    expectedFrequency: 'monthly',
    excludeIf: (txn) =>
      txn.category?.toLowerCase() === 'food' ||
      txn.subcategory?.toLowerCase().includes('zomato') ||
      /rzp@rxairtel/i.test(txn.narration ?? ''),
  },
  { name: 'Jio Recharge', regex: /JIO.*RECHARGE/i, expectedFrequency: 'monthly' },
  { name: 'Electricity Bill', regex: /ELECTRICITY|BILLDESK.*ELECTRIC/i, expectedFrequency: 'monthly' },
  { name: 'Water Bill', regex: /WATER\s*BILL/i, expectedFrequency: 'monthly' },
  { name: 'Gas Bill', regex: /GAS\s*BILL/i, expectedFrequency: 'monthly' },
  { name: 'Internet Bill', regex: /INTERNET\s*BILL/i, expectedFrequency: 'monthly' },
  { name: 'Utility Bill', regex: /UTILITY\s*BILL/i, expectedFrequency: 'monthly' },
  { name: 'Mobile Recharge', regex: /MOBILE\s*RECHARGE/i, expectedFrequency: 'monthly' },
  { name: 'DTH Recharge', regex: /DTH\s*RECHARGE/i, expectedFrequency: 'monthly' },
  { name: 'Metro Autopay', regex: /METRO\s*AUTOPAY/i, expectedFrequency: 'monthly' },
  { name: 'Toll Autopay', regex: /TOLL\s*AUTOPAY/i, expectedFrequency: 'monthly' },
];

export default autoPayMerchants;

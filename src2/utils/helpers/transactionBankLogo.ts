import logger from '../common/logger';
import bankLogos from '../../config/bankLogos';

// ------------------- Types & Interfaces ------------------- //

export interface Bank {
  _id: string;
  fipId: string;
  fipName: string;
}

export interface Transaction {
  _id: string;
  accountId?: {
    bankId?: string;
  };
  bankId?: string;
  category: string;
  narration: string;
  toObject: () => any;
}

export interface EnrichedTransaction extends ReturnType<Transaction['toObject']> {
  title: string;
  bankId: string | null;
  bankName: string | null;
  bankLogo: string | null;
}

// ------------------ extractImportantInfo ------------------ //

export function extractImportantInfo(narration: string): string {
  if (!narration || typeof narration !== 'string') return 'Unknown Transaction';

  if (narration === 'NEFT CHARGES') return 'NEFT Charges';
  if (narration.startsWith('INT PAYOUT:')) return 'Interest Payout';
  if (narration.startsWith('PRINC PAYOUT:')) return 'Principal Payout';

  const autoSweepoutMatch = narration.match(/^[0-9]+\/[0-9]+\s+([^/]+?)\s+AUTO SWEEPOUT/);
  if (autoSweepoutMatch) return autoSweepoutMatch[1].trim() || 'Auto Sweepout';

  const neftMatch = narration.match(/NEFT (CR|DR)-[A-Z0-9]+-(.*?)-/);
  if (neftMatch) return neftMatch[2] || 'NEFT';

  const impsMatch = narration.match(/IMPS\/[0-9]+\/([^/]+)\//);
  if (impsMatch) return impsMatch[1].trim() || 'IMPS Transaction';

  const upiArAbMatch = narration.match(/(UPIAR|UPIAB)\/[0-9]+\/(CR|DR)\/([^/]+)\/[A-Z]{3,}\//);
  if (upiArAbMatch) {
    const name = upiArAbMatch[3].trim();
    if (['PhonePe', 'IRCTC Rail APP', 'ZEPTO', 'AMAZON PAY', 'Swiggy L'].includes(name)) return name;

    if (!name.match(/^[A-Za-z0-9]+@[a-z]+$/)) return name;

    const vpa = narration.match(/\/([^/]+)$/);
    if (vpa) {
      const vpaStr = vpa[1].trim();
      if (vpaStr.includes('paytm') || vpaStr.includes('@yb')) return 'Paytm';
      if (vpaStr.includes('BBPSBP')) return 'PhonePe';
      if (vpaStr.includes('swiggy')) return 'Swiggy';
      if (vpaStr.includes('MYNTRA')) return 'Myntra';
      if (vpaStr.includes('airtel')) return 'Airtel';
      if (vpaStr.includes('unikon')) return 'Unikon';
      if (vpaStr.includes('actcorp')) return 'Atria Convergence';
      if (vpaStr.includes('pinelabs')) return '28 Foods';
      if (vpaStr.includes('JARGOLDONLINE')) return 'Jar Gold';
      if (vpaStr.includes('gpay-')) return 'Google Pay';
      if (vpaStr.includes('greaterhyderab')) return 'Greater Hyderabad';
    }
  }

  const upiSlashCrDrMatch = narration.match(/UPI\/[0-9]+\/(CR|DR)\/([^/]+)\/[A-Z]{3,}\//);
  if (upiSlashCrDrMatch) {
    const name = upiSlashCrDrMatch[2].trim();
    if (!name.match(/^[A-Za-z0-9]+@[a-z]+$/)) return name;
    if (narration.includes('Paytm')) return 'Paytm';
    if (narration.includes('PhonePe')) return 'PhonePe';
  }

  const upiDashMatch = narration.match(/UPI-(CR|DR)-([0-9]+)-(.*?)-([A-Z]{4}-)/);
  if (upiDashMatch) {
    const parts = narration.split('-');
    const fourth = parts[3]?.trim() || '';
    if (fourth && !fourth.match(/^[A-Z]{4}$/) && !fourth.match(/^[A-Za-z0-9]+@[a-z]+$/)) {
      return fourth;
    }
    const third = upiDashMatch[3].trim();
    if (!third.match(/^[A-Za-z0-9]+@[a-z]+$/)) return third;
    if (narration.includes('Paytm')) return 'Paytm';
    if (narration.includes('PhonePe')) return 'PhonePe';
  }

  const upiNameMatch = narration.match(/^UPI-([^-]+)-([A-Za-z0-9@]+|[0-9]+-?[0-9]*@?[A-Za-z]*)-[A-Z]{4,}/);
  if (upiNameMatch) {
    const name = upiNameMatch[1].trim();
    if (['PhonePe', 'IRCTC Rail APP', 'ZEPTO', 'AMAZON PAY'].includes(name)) return name;

    if (narration.includes('PAID VIA NAVI UPI') || narration.includes('PAYMENT FROM PHONE') || narration.includes('PAY TO MERCHANT')) return name;

    return name;
  }

  const upiSlashMatch = narration.match(/UPI\/[0-9]+\/[0-9]+\/UPI\/([^/]+)/);
  if (upiSlashMatch) {
    const recipient = upiSlashMatch[1];
    if (recipient.includes('paytmqr') || recipient.includes('paytm-') || recipient.includes('PTYS') || recipient.includes('PTYBL')) return 'Paytm';
    if (recipient.includes('BHARATPE')) return 'BharatPe';
    if (recipient.includes('gpay-') || recipient.includes('OKBIZAXIS') || recipient.includes('OKAXIS')) return 'Google Pay';

    if (recipient.match(/^[A-Za-z0-9]+@[a-z]+$/)) {
      if (recipient.endsWith('@ybl')) return 'Paytm';
      if (recipient.includes('ok') || recipient.includes('OKAXIS')) return 'Google Pay';
    }
    return recipient;
  }

  if (narration.includes('PAID VIA NAVI UPI')) return 'Navi UPI';
  if (narration.includes('PAYMENT FROM PHONE')) return 'PhonePe';
  if (narration.includes('REQUEST FROM AMAZO')) return 'Amazon Pay';
  if (narration.includes('HUNGERBOX ORDER')) return 'Hungerbox';
  if (narration.includes('PAY TO MERCHANT')) return 'Merchant Payment';

  const blacklist = ['UPI', 'CR', 'DR', 'TXN', 'TRANSFER', 'PAYMENT', 'FROM', 'TO', 'REF', 'VIA', 'RTGS', 'TPT', 'TRF'];

  return extractCleanName(narration, blacklist) || narration;
}

// ------------------ extractCleanName ------------------ //

function extractCleanName(narration: string, blacklist: string[] = []): string | null {
  const parts = narration.split('-');
  const parts2 = narration.split('/');
  const candidates = [parts[1]?.trim(), parts[2]?.trim(), parts[3]?.trim(), parts2[1]?.trim(), parts2[2]?.trim(), parts2[3]?.trim()];

  for (const name of candidates) {
    if (name && /^[A-Za-z\s]+$/.test(name) && !blacklist.includes(name)) {
      return name;
    }
  }

  const knownBrands = [
    'AMAZON',
    'FLIPKART',
    'MYNTRA',
    'ZEPTO',
    'SWIGGY',
    'ZOMATO',
    'IRCTC',
    'MEESHO',
    'AJIO',
    'NYKAA',
    'OLA',
    'UBER',
    'PAYTM',
    'PHONEPE',
    'GOOGLE',
    'MICROSOFT',
    'APPLE',
    'NETFLIX',
    'SPOTIFY',
    'HOTSTAR',
    'YOUTUBE',
    'JIO',
    'AIRTEL',
    'VI',
    'BSNL',
    'CRED',
    'TATASKY',
    'BIGBASKET',
    'DUNZO',
    'LIC',
    'HDFCLIFE',
    'ICICIPRULIFE',
    'MOBIKWIK',
    'FREECHARGE',
    'TATA',
    'RELIANCE',
    'BYJU',
    'UNACADEMY',
    'NAVI',
    'BAJAJFINSERV',
    'CROMA',
    'REDBUS',
    'MAKEMYTRIP',
    'BOOKMYSHOW',
    'INDIGO',
    'AIRINDIA',
    'VISTARA',
    'GOFIRST',
    'SPICEJET',
    'DMART',
    'RELIANCETRENDS',
    'SNAPDEAL',
    'SHOPCLUES',
  ];

  const found = knownBrands.find((b) => narration.toUpperCase().includes(b));

  if (found) return found;

  return parts.length === 1 ? narration : null;
}

// ------------------ enrichTransactionWithBankDetails ------------------ //

export async function enrichTransactionWithBankDetails(transactions: Transaction[], banks: Bank[]): Promise<EnrichedTransaction[]> {
  const bankMap = new Map(banks.map((b) => [b._id, b]));

  return Promise.all(
    transactions.map(async (txn) => {
      try {
        if (!txn.accountId) {
          return {
            ...txn.toObject(),
            title: extractImportantInfo(txn.narration || txn.category),
            bankId: null,
            bankName: null,
            bankLogo: null,
          };
        }

        const bank = (txn.bankId && bankMap.get(txn.bankId)) || (txn.accountId.bankId && bankMap.get(txn.accountId.bankId)) || null;

        if (!bank) {
          logger.warn(`Bank not found for transaction ${txn._id}`);
        }

        const bankLogo = bank?.fipId && bankLogos[bank.fipId] ? bankLogos[bank.fipId] : 'https://cdn.finvu.in/finvulogos/bank_large_light.png';

        const title = extractImportantInfo(txn.narration || txn.category);

        return {
          ...txn.toObject(),
          title,
          bankId: bank?.fipId || null,
          bankName: bank?.fipName || null,
          bankLogo,
        };
      } catch (err: any) {
        logger.error(`Error enriching transaction ${txn._id}: ${err.message}`);
        throw err;
      }
    })
  );
}

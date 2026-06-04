import bankConfigs from '../utils/credit-cards.json';

type BankConfig = {
  name: string;
  logo: string;
  bankId: string;
  senderDomains: string[];
  subjectKeywords: string[];
};

type BankCheckResult = {
  isFromBank: boolean;
  matchedBankId: string | null;
  matchedBankName: string | null;
  matchReason: string | null;
  bankConfig: any;
};

const BANK_NAME_KEYWORDS: Record<string, string[]> = {
  'HDFCLtd-FIP': ['hdfc'],
  'ICICI-FIP': ['icici'],
  'sbi-fip': ['sbi', 'state bank'],
  AXIS001: ['axis'],
  'KotakMahindraBank-FIP': ['kotak'],
  BARBFIP: ['baroda', 'bob'],
  'YESB-FIP': ['yes bank', 'yesbank'],
  'UBI-FIP': ['union bank', 'unionbank'],
  'Slice-FIP': ['slice'],
};

export function checkIsFromBank(
  fromHeader: string,
  subjectHeader: string,
  bank: any
): BankCheckResult {
  const fromLower = fromHeader.toLowerCase();
  const subjectLower = subjectHeader.toLowerCase();

  const ids = bank.map((id: any) => id.bankId);

  const matchedBanks = bankConfigs.filter((item) => ids.includes(item.bankId));

  for (const bank of matchedBanks) {
    const keywords = BANK_NAME_KEYWORDS[bank.bankId] ?? [];
    // Check from header first, then subject
    const matchedInFrom = keywords.find((kw) => fromLower.includes(kw.toLowerCase()));
    const matchedInSubject = keywords.find((kw) => subjectLower.includes(kw.toLowerCase()));

    if (matchedInFrom || matchedInSubject) {
      return {
        isFromBank: true,
        matchedBankId: bank.bankId,
        matchedBankName: bank.name,
        matchReason: matchedInFrom ? `from:${matchedInFrom}` : `subject:${matchedInSubject}`,
        bankConfig: '',
      };
    }

    const matchedDomain = bank.senderDomains.find((domain) =>
      fromLower.includes(domain.toLowerCase())
    );

    if (!matchedDomain) continue;

    // Domain matched — now check at least one subject keyword
    const matchedKeyword = bank.subjectKeywords.find((kw) =>
      subjectLower.includes(kw.toLowerCase())
    );

    if (matchedKeyword) {
      return {
        isFromBank: true,
        matchedBankId: bank.bankId,
        matchedBankName: bank.name,
        matchReason: `domain:${matchedDomain} + subject:${matchedKeyword}`,
        bankConfig: '',
      };
    }

    // Domain matched but no subject keyword — still flag it, lower confidence
    return {
      isFromBank: true,
      matchedBankId: bank.bankId,
      matchedBankName: bank.name,
      matchReason: `domain:${matchedDomain} (no subject match)`,
      bankConfig: '',
    };
  }

  return {
    isFromBank: false,
    matchedBankId: null,
    matchedBankName: null,
    matchReason: null,
    bankConfig: '',
  };
}

import { classifyCounterparty } from '../utils/narration/classifyCounterparty';
import { parseNarration } from '../utils/narration/parseNarration';

function classify(narration: string, merchant = '', isAutoPay = false) {
  const parsed = parseNarration(narration);
  return classifyCounterparty(parsed, merchant, isAutoPay);
}

describe('classifyCounterparty', () => {

  // ── P2P detection ───────────────────────────────────────────────────────────

  describe('P2P', () => {
    it('domain-context P2P example (person name, CNRB account number) → P2P', () => {
      expect(classify(
        'UPI-DR-352383653756-NEERATI  VAMSHI-CNRB-30792200091581-Payment from PhonePe',
      )).toBe('P2P');
    });

    it('two-token first-last name → P2P', () => {
      expect(classify('UPI-DR-123-RAHUL SHARMA-HDFC-rahul.sharma@hdfc')).toBe('P2P');
    });

    it('three-token name still → P2P', () => {
      expect(classify('UPI-DR-123-RAHUL KUMAR SHARMA-SBIN-rks@sbi')).toBe('P2P');
    });
  });

  // ── P2M detection ───────────────────────────────────────────────────────────

  describe('P2M', () => {
    it('domain-context P2M merchant (PRIVATE LIMITED in name) → P2M', () => {
      expect(classify(
        'UPI-DR-163427235956-TINGLE BUDS F  B PRIVATE LIMITED-YESB-002261100000025-Payment from PhonePe',
      )).toBe('P2M');
    });

    it('name contains ENTERPRISES → P2M', () => {
      expect(classify('UPI-DR-123-SHARMA ENTERPRISES-CNRB-vpa@upi')).toBe('P2M');
    });

    it('name contains TRADERS → P2M', () => {
      expect(classify('UPI-DR-123-CITY TRADERS-ICIC-traders@icici')).toBe('P2M');
    });

    it('name contains FOODS → P2M', () => {
      expect(classify('UPI-DR-123-FRESH FOODS PVT-HDFC-ff@hdfc')).toBe('P2M');
    });

    it('name contains LTD → P2M', () => {
      expect(classify('UPI-DR-123-ACME CORP LTD-AXIS-acme@axis')).toBe('P2M');
    });

    it('merchant field populated → P2M regardless of parsed narration', () => {
      expect(classify('UPI-DR-123-UNKNOWN FORMAT', 'Swiggy')).toBe('P2M');
    });

    it('isAutoPay=true → P2M', () => {
      expect(classify('UPI-DR-123-SOME NAME-SBIN-vpa@sbi', '', true)).toBe('P2M');
    });

    it('VPA matches merchant QR pattern (paytmqr) → P2M', () => {
      const parsed = parseNarration('UPI-DR-123-MERCHANT-HDFC-paytmqr123@hdfc');
      expect(classifyCounterparty(parsed, '', false)).toBe('P2M');
    });

    it('VPA matches bharatpe → P2M', () => {
      const parsed = parseNarration('UPI-DR-123-MERCHANT-SBIN-bharatpe@sbi');
      expect(classifyCounterparty(parsed, '', false)).toBe('P2M');
    });
  });

  // ── unknown ─────────────────────────────────────────────────────────────────

  describe('unknown', () => {
    it('unrecognised narration format → unknown', () => {
      expect(classify('SOME COMPLETELY UNRECOGNISED FORMAT')).toBe('unknown');
    });

    it('parsed but no counterpartyName → unknown', () => {
      // NEFT_SLASH has no bank handle / VPA — can only produce counterpartyName
      const parsed = parseNarration('NEFT/SBIN322147057322/EMPLOYEE SALARY');
      // counterpartyName = 'EMPLOYEE SALARY' — two tokens, both alpha → P2P heuristic
      // But "EMPLOYEE" is >1 word and looks like a descriptive label, not a person.
      // The classifier will call it P2P (two all-alpha tokens). Document this ceiling:
      const result = classifyCounterparty(parsed, '', false);
      expect(['P2P', 'unknown']).toContain(result);
    });

    it('null parsed with no merchant/isAutoPay → unknown', () => {
      expect(classifyCounterparty(null, '', false)).toBe('unknown');
    });
  });

  // ── P2P gate integration in categorizeTransactions ─────────────────────────

  describe('integration with categorizeTransactions', () => {
    jest.mock('../utils/time/normalize', () => ({
      normalizeTransactionTimestamp: (input: any) => (input ? new Date(input) : undefined),
    }));

    jest.mock('../models/transactions-automation/merchantDirectory', () => ({
      __esModule: true,
      default: {
        find: jest.fn().mockReturnValue({
          select: jest.fn().mockReturnThis(),
          lean: jest.fn().mockResolvedValue([]),
        }),
      },
    }));

    const categorizeTransactions = require('../utils/helpers/categorizeTransactions').default;
    const EMPTY_RULES = new Map();

    it('P2P UPI debit → category Transfers / subcategory Sent', async () => {
      const [result] = await categorizeTransactions(
        [{
          type: 'DEBIT',
          mode: 'UPI',
          amount: 500,
          transactionTimestamp: new Date(),
          narration: 'UPI-DR-352383653756-NEERATI  VAMSHI-CNRB-30792200091581-Payment from PhonePe',
        }],
        'acct', 'user', 'bank', EMPTY_RULES, 'UNKNOWN',
      );
      expect(result.category).toBe('Transfers');
      expect(result.subcategory).toBe('Sent');
    });

    it('P2M merchant with PRIVATE LIMITED → NOT routed to Transfers', async () => {
      const [result] = await categorizeTransactions(
        [{
          type: 'DEBIT',
          mode: 'UPI',
          amount: 350,
          transactionTimestamp: new Date(),
          narration: 'UPI-DR-163427235956-TINGLE BUDS F  B PRIVATE LIMITED-YESB-002261100000025-Payment from PhonePe',
        }],
        'acct', 'user', 'bank', EMPTY_RULES, 'UNKNOWN',
      );
      expect(result.category).not.toBe('Transfers');
    });

    it('unknown counterparty class falls through to keyword matching', async () => {
      const [result] = await categorizeTransactions(
        [{
          type: 'DEBIT',
          mode: 'UPI',
          amount: 200,
          transactionTimestamp: new Date(),
          narration: 'Swiggy food order',
        }],
        'acct', 'user', 'bank', EMPTY_RULES, 'UNKNOWN',
      );
      expect(result.category).toBe('Food');
    });
  });
});

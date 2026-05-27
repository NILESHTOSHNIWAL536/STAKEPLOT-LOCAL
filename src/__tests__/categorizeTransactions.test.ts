import categorizeTransactions from '../utils/helpers/categorizeTransactions';

// normalizeTransactionTimestamp is pure date logic — mock it to return the input unchanged.
jest.mock('../utils/time/normalize', () => ({
  normalizeTransactionTimestamp: (_input: any) => (_input ? new Date(_input) : undefined),
}));

// Mock MerchantDirectory so tests don't need a live MongoDB connection.
// All tests in this file assume an empty directory (no pre-seeded entries).
// Directory-specific behaviour is tested in the merchantDirectory integration tests.
jest.mock('../models/transactions-automation/merchantDirectory', () => ({
  __esModule: true,
  default: {
    find: jest.fn().mockReturnValue({
      select: jest.fn().mockReturnThis(),
      lean: jest.fn().mockResolvedValue([]),
    }),
  },
}));

const FAKE_USER = 'user123';
const FAKE_ACCOUNT = 'account123';
const FAKE_BANK = 'bank123';
const EMPTY_RULE_MAP = new Map();

function makeTxn(overrides: Record<string, any>): any {
  return {
    type: 'DEBIT',
    mode: 'UPI',
    amount: 100,
    transactionTimestamp: new Date('2024-01-01T00:00:00Z'),
    ...overrides,
  };
}

async function categorize(txns: any[]) {
  return categorizeTransactions(txns, FAKE_ACCOUNT, FAKE_USER, FAKE_BANK, EMPTY_RULE_MAP, 'UNKNOWN');
}

// ─── Domain-context example narrations ───────────────────────────────────────

describe('P2P person-transfer detection', () => {
  it('UPI-DR person narration (CNRB format) → Transfers / Sent', async () => {
    const [result] = await categorize([makeTxn({
      narration: 'UPI-DR-352383653756-NEERATI  VAMSHI-CNRB-30792200091581-Payment from PhonePe',
    })]);
    expect(result.category).toBe('Transfers');
    expect(result.subcategory).toBe('Sent');
    expect(result.needsReview).toBe(false);
  });
});

describe('P2M merchant categorization', () => {
  it('F&B merchant with PRIVATE LIMITED in name → not routed to Transfers', async () => {
    const [result] = await categorize([makeTxn({
      narration: 'UPI-DR-163427235956-TINGLE BUDS F  B PRIVATE LIMITED-YESB-002261100000025-Payment from PhonePe',
    })]);
    expect(result.category).not.toBe('Transfers');
  });

  it('Swiggy → Food / FoodDelivery', async () => {
    const [result] = await categorize([makeTxn({ narration: 'UPI-DR-123-Swiggy-ICIC-xxx' })]);
    expect(result.category).toBe('Food');
    expect(result.subcategory).toBe('FoodDelivery');
  });

  it('Zomato → Food / FoodDelivery', async () => {
    const [result] = await categorize([makeTxn({ narration: 'UPI-DR-456-Zomato-HDFC-yyy' })]);
    expect(result.category).toBe('Food');
    expect(result.subcategory).toBe('FoodDelivery');
  });

  it('Amazon → Shopping / Ecommerce (Shopping appears before Commerce in config)', async () => {
    const [result] = await categorize([makeTxn({ narration: 'UPI-DR-789-Amazon-SBIN-zzz' })]);
    expect(result.category).toBe('Shopping');
    expect(result.subcategory).toBe('Ecommerce');
  });

  it('Netflix → Subscriptions / OTT', async () => {
    const [result] = await categorize([makeTxn({ narration: 'UPI-DR-999-Netflix-AXIS-abc' })]);
    expect(result.category).toBe('Subscriptions');
    expect(result.subcategory).toBe('OTT');
  });

  it('Ola → Travel / CabServices', async () => {
    const [result] = await categorize([makeTxn({ narration: 'UPI-DR-111-Ola-CNRB-def' })]);
    expect(result.category).toBe('Travel');
    expect(result.subcategory).toBe('CabServices');
  });

  it('Uber → Travel / CabServices', async () => {
    const [result] = await categorize([makeTxn({ narration: 'UPI-DR-222-Uber-ICIC-ghi' })]);
    expect(result.category).toBe('Travel');
    expect(result.subcategory).toBe('CabServices');
  });

  it('dmart → Groceries / Supermarkets', async () => {
    const [result] = await categorize([makeTxn({ narration: 'UPI-DR-333-dmart-HDFC-jkl' })]);
    expect(result.category).toBe('Groceries');
    expect(result.subcategory).toBe('Supermarkets');
  });
});

// ─── Salary / NEFT ───────────────────────────────────────────────────────────

describe('NEFT salary (CREDIT type)', () => {
  it('NEFT salary narration → Income', async () => {
    const [result] = await categorize([makeTxn({
      type: 'CREDIT',
      mode: 'NEFT',
      narration: 'NEFT/SBIN322147057322/EMPLOYEE SALARY',
    })]);
    expect(result.category).toBe('Income');
  });
});

// ─── Prefix-based rules ───────────────────────────────────────────────────────

describe('Prefix-based rules', () => {
  it('UPI-CR with person name → P2P gate routes to Transfers', async () => {
    // "FRIEND NAME" is two alpha tokens → P2P → Transfers supersedes old prefix rule.
    const [result] = await categorize([makeTxn({
      narration: 'UPI-CR-123456-FRIEND NAME-ICIC-vpa@icici',
    })]);
    expect(result.category).toBe('Transfers');
  });

  it('ATM withdrawal → Personal Transfer', async () => {
    const [result] = await categorize([makeTxn({ narration: 'ATM WITHDRAWAL 500' })]);
    expect(result.category).toBe('Personal Transfer');
  });

  it('CASH WDL → Personal Transfer', async () => {
    const [result] = await categorize([makeTxn({ narration: 'CASH WDL 1000' })]);
    expect(result.category).toBe('Personal Transfer');
  });

  it('POS transaction → Personal Transfer', async () => {
    const [result] = await categorize([makeTxn({ narration: 'POS MERCHANT TERMINAL' })]);
    expect(result.category).toBe('Personal Transfer');
  });
});

// ─── CREDIT transactions ──────────────────────────────────────────────────────

describe('CREDIT transactions', () => {
  it('any CREDIT → category is Income', async () => {
    const results = await categorize([
      makeTxn({ type: 'CREDIT', narration: 'RANDOM NARRATION' }),
      makeTxn({ type: 'CREDIT', narration: 'UPI-CR-123-FRIEND-HDFC-vpa' }),
    ]);
    results.forEach((r) => expect(r.category).toBe('Income'));
  });
});

// ─── Rule-map (learned rules) ────────────────────────────────────────────────

describe('RuleMap (learned rules)', () => {
  it('ruleMap hit overrides keyword match and sets needsReview', async () => {
    const ruleMap = new Map([
      ['swiggy_100', { category: 'Food', subcategory: 'FoodDelivery' }],
    ]);
    const [result] = await categorizeTransactions(
      [makeTxn({ narration: 'swiggy', amount: 100 })],
      FAKE_ACCOUNT, FAKE_USER, FAKE_BANK, ruleMap, 'UNKNOWN',
    );
    expect(result.category).toBe('Food');
    expect(result.subcategory).toBe('FoodDelivery');
    expect(result.needsReview).toBe(true);
  });
});

// ─── Merchant directory layer ─────────────────────────────────────────────────

describe('Merchant directory', () => {
  it('directory hit takes precedence over keyword config', async () => {
    // Seed the mock to return a directory entry for "swiggy@icici"
    const MerchantDirectory = require('../models/transactions-automation/merchantDirectory').default;
    MerchantDirectory.find.mockReturnValueOnce({
      select: jest.fn().mockReturnThis(),
      lean: jest.fn().mockResolvedValue([
        { key: 'swiggy@icici', category: 'Food', subcategory: 'FoodDelivery' },
      ]),
    });

    const [result] = await categorize([makeTxn({
      narration: 'UPI-DR-123-Swiggy-ICIC-swiggy@icici',
    })]);
    expect(result.category).toBe('Food');
    expect(result.subcategory).toBe('FoodDelivery');
  });

  it('unknown P2M merchant with no directory hit sets needsReview', async () => {
    // "PRIVATE LIMITED" → P2M; no keyword in config matches "XYZZY TECH"; no directory hit
    const [result] = await categorize([makeTxn({
      narration: 'UPI-DR-123-XYZZY TECH PRIVATE LIMITED-HDFC-xyzzy@hdfc',
    })]);
    expect(result.category).toBe('Untagged');
    expect(result.needsReview).toBe(true);
  });
});

// ─── Edge cases ───────────────────────────────────────────────────────────────

describe('Edge cases', () => {
  it('empty narration → Untagged, no crash', async () => {
    const [result] = await categorize([makeTxn({ narration: '' })]);
    expect(result.category).toBe('Untagged');
  });

  it('null narration → Untagged, no crash', async () => {
    const [result] = await categorize([makeTxn({ narration: null })]);
    expect(result.category).toBe('Untagged');
  });

  it('narration with only numeric tokens → Untagged', async () => {
    const [result] = await categorize([makeTxn({ narration: '123456789 000111222' })]);
    expect(result.category).toBe('Untagged');
  });

  it('truncated merchant name does not match keyword', async () => {
    const [result] = await categorize([makeTxn({ narration: 'UPI-DR-123-Swi-ICIC' })]);
    expect(result.category).toBe('Untagged');
  });

  it('full keyword match works', async () => {
    const [result] = await categorize([makeTxn({ narration: 'UPI-DR-123-Swiggy-ICIC' })]);
    expect(result.category).toBe('Food');
  });

  it('case-insensitive keyword match', async () => {
    const [result] = await categorize([makeTxn({ narration: 'payment to NETFLIX subscription' })]);
    expect(result.category).toBe('Subscriptions');
  });

  it('subcategory is the subcategory key, not the raw keyword', async () => {
    const [result] = await categorize([makeTxn({ narration: 'Swiggy delivery order' })]);
    expect(result.subcategory).toBe('FoodDelivery');
  });

  it('missing delimiter → falls through to keyword match', async () => {
    const [result] = await categorize([makeTxn({ narration: 'Zomato food delivery' })]);
    expect(result.category).toBe('Food');
  });

  it('existing subcategory on transaction is preserved', async () => {
    const [result] = await categorize([makeTxn({ narration: 'Swiggy', subcategory: 'ManualTag' })]);
    expect(result.subcategory).toBe('ManualTag');
  });

  it('idempotent: same transaction twice produces same result', async () => {
    const txn = makeTxn({ narration: 'Swiggy food order', amount: 250 });
    const [first] = await categorize([txn]);
    const [second] = await categorize([txn]);
    expect(first.category).toBe(second.category);
    expect(first.subcategory).toBe(second.subcategory);
  });

  it('accountId, userId, bankId are set on result', async () => {
    const [result] = await categorize([makeTxn({ narration: 'test' })]);
    expect(result.accountId).toBe(FAKE_ACCOUNT);
    expect(result.userId).toBe(FAKE_USER);
    expect(result.bankId).toBe(FAKE_BANK);
  });
});

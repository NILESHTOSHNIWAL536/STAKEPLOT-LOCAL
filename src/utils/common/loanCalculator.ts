export type LoanType = 'home' | 'car' | 'personal';
export type CreditScoreRange = '<600' | '600-650' | '650-700' | '700-750' | '750+';

export interface Expenses {
  food?: number;
  entertainment?: number;
  shopping?: number;
  travel?: number;
  rent?: number;
  snacks?: number;
  untagged?: number;
  [key: string]: number | undefined; // allow dynamic categories
}

export interface LoanEligibilityInput {
  income: number; // monthly income
  existingEmi: number; // sum of ongoing EMIs
  creditScore: CreditScoreRange; // credit score range
  loanType: LoanType;
  expenses?: Expenses;
}

export interface LoanEligibilityOutput {
  loanType: LoanType;
  eligibility?: string;
  safeEmiRange?: string;
  maxLoanAmount?: string;
  maxSuggestedLoanAmount?: string;
  expectedEmi?: string;
  interestBracket?: string;
  suggestedTimeline?: string[];
  alternatives?: string[];
  tip?: string;
  bonusInsights?: string[];
}

export function calculateLoanEligibility({ income, existingEmi, creditScore, loanType, expenses = {} }: LoanEligibilityInput): LoanEligibilityOutput {
  // --- 1. Auto Interest Rate Bracket by Credit Score ---
  let annualRate!: number;
  let interestBracket!: string;

  let low: number | null = null;
  let high: number | null = null;

  if (creditScore.includes('-')) {
    [low, high] = creditScore.split('-').map((v) => parseInt(v, 10));
  } else if (creditScore.includes('<')) {
    high = parseInt(creditScore.replace('<', ''), 10);
  } else if (creditScore.includes('+')) {
    low = parseInt(creditScore.replace('+', ''), 10);
  }

  if (high !== null && high <= 600) {
    return {
      loanType,
      eligibility: 'loan approval unlikely (Credit Score < 600)',
      alternatives: [
        'Apply for Gold Loans.',
        'Consider salary-backed loans (show your last 3–6 months salary slips).',
        'Explore credit union loans or NBFCs offering secured loans.',
        'Improve your credit score by paying bills/EMIs on time before applying again.',
      ],
      tip: 'Building a positive repayment history will improve your future eligibility.',
    };
  } else if (low !== null && low >= 750) {
    annualRate = 9;
    interestBracket = '8%–10%';
  } else if (low !== null && high !== null && low >= 700 && high <= 750) {
    annualRate = 11.5;
    interestBracket = '10%–13%';
  } else if (low !== null && high !== null && low >= 650 && high <= 700) {
    annualRate = 14;
    interestBracket = '13%–16%';
  } else if (low !== null && high !== null && low >= 600 && high <= 650) {
    annualRate = 18;
    interestBracket = '16%–20%';
  } else {
    return {
      loanType,
      eligibility: 'Invalid credit score range provided',
    };
  }

  // --- 2. Default Tenure by Loan Type ---
  let defaultTenure: number;
  if (loanType === 'home') defaultTenure = 20;
  else if (loanType === 'car') defaultTenure = 7;
  else defaultTenure = 5;

  // --- 3. Safe EMI Range ---
  const safeEmiMin = income * 0.3 - existingEmi;
  const safeEmiMax = income * 0.4 - existingEmi;

  if (safeEmiMax <= 0) {
    return {
      loanType,
      safeEmiRange: '⚠️ Taking another loan right now may strain your finances as current EMIs already exceed safe borrowing limits.',
      maxLoanAmount: 'Not advisable',
      expectedEmi: 'Not applicable',
      interestBracket,
      suggestedTimeline: ['Not applicable at this stage'],
      bonusInsights: [
        `Your existing EMIs of ₹${existingEmi} already exceed the safe limit for your income (₹${income}).`,
        'Focus on clearing some of your ongoing loans or increasing income before considering new borrowing.',
      ],
    };
  }

  // Monthly interest rate
  const R = annualRate / 100 / 12;
  const N = defaultTenure * 12;

  // --- 4. Max Loan Amount ---
  const maxLoan = (safeEmiMax * (Math.pow(1 + R, N) - 1)) / (R * Math.pow(1 + R, N));

  const emi = (maxLoan * R * Math.pow(1 + R, N)) / (Math.pow(1 + R, N) - 1);

  // --- 5. Suggested Timelines ---
  function calculateEmi(principal: number, years: number, rate: number): number {
    const r = rate / 100 / 12;
    const n = years * 12;
    return (principal * r * Math.pow(1 + r, n)) / (Math.pow(1 + r, n) - 1);
  }

  const shortTenure = loanType === 'home' ? 10 : defaultTenure - 2;
  const longTenure = loanType === 'home' ? 25 : defaultTenure + 2;

  const emiShort = calculateEmi(maxLoan, shortTenure, annualRate);
  const emiMedium = calculateEmi(maxLoan, defaultTenure, annualRate);
  const emiLong = calculateEmi(maxLoan, longTenure, annualRate);

  // --- 6. Bonus Insights ---
  const bonusInsights: string[] = [];

  if (existingEmi > 0) {
    bonusInsights.push(`If you clear your current EMIs of ₹${existingEmi}, you'll qualify for more loan eligibility.`);
  }

  if ((low ?? 0) < 750 || (high ?? 0) < 750) {
    bonusInsights.push(`Improving your credit score by 50 points can lower your interest by ~2%.`);
  }

  if (existingEmi / income > 0.5) {
    bonusInsights.push('Your debt-to-income ratio is above 50%, lenders may hesitate for higher amounts.');
  }

  // --- Lifestyle spends ---
  const lifestyleCategories = ['food', 'entertainment', 'shopping', 'snacks'];
  let lifestyleSpend = 0;

  lifestyleCategories.forEach((cat) => {
    lifestyleSpend += expenses[cat] || 0;
  });

  const lifestyleRatio = (lifestyleSpend / income) * 100;

  if (lifestyleRatio > 30) {
    const cutAmount = Math.round(lifestyleSpend * 0.1);
    const improvedBorrowing = cutAmount * 12 * 0.4;

    bonusInsights.push(
      `Your ${lifestyleCategories.join(', ')} spends take up ${lifestyleRatio.toFixed(
        1
      )}% of your income. Cutting 10% (₹${cutAmount}/month) can improve safe borrowing power by ~₹${Math.round(improvedBorrowing)}.`
    );
  }

  // --- Untagged spends ---
  const untagged = expenses['untagged'] || 0;
  const untaggedPercent = (untagged / income) * 100;

  if (untaggedPercent > 30) {
    const cutAmount = Math.round(untagged * 0.1);
    const improvedBorrowing = cutAmount * 12 * 0.4;
    bonusInsights.push(
      `30%+ of your income goes into untagged spends. Reducing them by 10% boosts borrowing power by ~₹${Math.round(
        improvedBorrowing
      )}. Regularly tagging your expenses will also unlock better understanding and personalized insights.`
    );
  } else if (untaggedPercent > 10) {
    bonusInsights.push(`You spent ₹${untagged} on untagged items. Tagging them will help us give more personalized advice.`);
  }

  // --- Savings / EMI readiness ---
  const totalExpenses = Object.values(expenses).reduce((sum: number, value) => sum + (value ?? 0), 0);

  const savings = income - totalExpenses - existingEmi;
  const savingswithunexpectedexpense = savings * 0.8;

  if (savings > 0) {
    const emiBoost = savingswithunexpectedexpense * 6;
    bonusInsights.push(`If you save ₹${savingswithunexpectedexpense} each month for 6 months, you'll be EMI-ready for ~₹${emiBoost} extra loan without stress.`);
  } else {
    bonusInsights.push(`Your expenses match or exceed income. Reducing discretionary spends will improve EMI readiness.`);
  }

  // --- Final Output ---
  return {
    loanType,
    safeEmiRange: `₹${Math.round(safeEmiMin)} – ₹${Math.round(safeEmiMax)}/month`,
    maxSuggestedLoanAmount: `₹${(maxLoan / 100000).toFixed(2)} Lakh`,
    expectedEmi: `₹${Math.round(emi)}/month at ${defaultTenure} years`,
    interestBracket,
    suggestedTimeline: [
      `${shortTenure} years → EMI ~ ₹${Math.round(emiShort)}/month`,
      `${defaultTenure} years → EMI ~ ₹${Math.round(emiMedium)}/month`,
      `${longTenure} years → EMI ~ ₹${Math.round(emiLong)}/month`,
    ],
    bonusInsights,
  };
}

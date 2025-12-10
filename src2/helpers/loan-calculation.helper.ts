// src2/helpers/loan-calculation.helper.ts

export interface LoanInput {
  income: number;
  existingEmi: number;
  creditScore: number;
  loanType: string;
  expenses: number;
}

export const calculateLoanEligibilityTS = ({
  income,
  existingEmi,
  creditScore,
  loanType,
  expenses
}: LoanInput) => {
  const disposableIncome = income - (existingEmi + expenses);

  if (disposableIncome <= 0) {
    return { eligible: false, maxLoanAmount: 0 };
  }

  const creditMultiplier =
    creditScore >= 750 ? 20 : creditScore >= 650 ? 15 : 10;

  const typeMultiplier =
    loanType === "personal" ? 1 : loanType === "home" ? 2 : 1.5;

  const maxLoanAmount = disposableIncome * creditMultiplier * typeMultiplier;

  return {
    eligible: maxLoanAmount > 0,
    maxLoanAmount
  };
};

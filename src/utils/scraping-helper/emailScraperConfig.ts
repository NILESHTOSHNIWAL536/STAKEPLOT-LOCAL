
import { StatementPasswordInput } from '../../services/email-password-request';
import { getNinetyDaysAgo, getNHoursAgo } from './get-time-date';


export function buildEmailScraperConfig(
  creditCard: any[],
  mode: 'initial' | 'incremental',
  statementPasswords: StatementPasswordInput[]
) {
  const afterDate =
    mode === 'initial'
      ? getNinetyDaysAgo(2)
      : getNHoursAgo(12);

  const bankConfig = creditCard;

  const bankFilters: string[] = [];

  const pdfPasswordsByBank: Record<string, string[]> = {};

  const banksWithPassword = new Set(
    statementPasswords
      .filter((item) => item.password)
      .map((item) => item.bankId)
  );

  const passwordList = statementPasswords
    .map((e) => e.password)
    .filter(Boolean);

  bankConfig.forEach((element) => {
    const bankName = element.name
      .toString()
      .toLowerCase()
      .trim();

    const passwords = statementPasswords
      .filter((item) => item.bankId === element.bankId)
      .map((item) => item.password)
      .filter(Boolean);

    bankFilters.push(bankName);

    addPasswordsForBank(pdfPasswordsByBank,element,passwords);
  });

  return {
    afterDate,
    bankConfig,
    bankFilters,
    pdfPasswordsByBank,
    banksWithPassword,
    passwordList,
  };
}




function addPasswordsForBank(
  passwordMap: Record<string, string[]>,
  bank: any,
  passwords: string[]
) {
  const aliases = new Set<string>();
  const bankName = String(bank.name || '').trim();
  const bankId = String(bank.bankId || '').trim();

  [bankName, bankName.toLowerCase(), bankId, bankId.toLowerCase()].forEach((alias) => {
    if (alias) aliases.add(alias);
  });

  const firstWord = bankName.split(/\s+/)[0];
  if (firstWord) {
    aliases.add(firstWord);
    aliases.add(firstWord.toLowerCase());
  }

  for (const alias of aliases) {
    passwordMap[alias] = mergeUnique(passwordMap[alias] || [], passwords);
  }
}

function mergeUnique(existing: string[], incoming: string[]) {
  return Array.from(new Set([...existing, ...incoming].filter(Boolean)));
}


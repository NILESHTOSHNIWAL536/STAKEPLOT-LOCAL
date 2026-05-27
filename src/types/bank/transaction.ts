import { Document, Types } from 'mongoose';

export interface IBankTransaction extends Document {
  type: 'DEBIT' | 'CREDIT' | 'TDS';
  mode: string;
  name?: string;

  amount: number;
  transactionalBalance: number;
  balanceOut: number;

  transactionTimestamp?: Date;
  valueDate?: Date;

  txnId: string;
  narration: string;
  reference: string;

  manualTransaction: boolean;

  category: string;
  subcategory: string;

  Hidden: boolean;
  isBill: boolean;
  isDebt: boolean;
  isSplit: boolean;
  needsReview: boolean;
  isAutoPay: boolean;
  isExcluded: boolean;
  isBalanceOut: boolean;

  autoPayId: string;
  merchant: string;
  expectedFrequency: string;

  accountId?: string |Types.ObjectId | null;
  userId: string | Types.ObjectId;
  bankId?: string | Types.ObjectId | null;


  merchantId?: string,
  isDebit?: string,
  label?: string,
  remainderId?: string
  currentBalance?: string | number

  // Parsed narration fields (populated by the narration parser layer, PR2+PR6)
  counterpartyName?: string;
  counterpartyVPA?: string;
  counterpartyBankHandle?: string;
}

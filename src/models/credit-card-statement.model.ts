import { Schema, model, Types, Document } from 'mongoose';

export interface ICreditCardStatement extends Document {
  userId: Types.ObjectId;

  statementHash: string;

  bankId: string;
  bankName: string;

  cardNumber: string;
  cardLast4: string;

  statementDate: Date;

  billingPeriod: {
    start: Date;
    end: Date;
  };

  paymentDue: {
    totalAmountDue: number;
    minimumDue: number;
    dueDate: Date;
  };

  creditLimits: {
    totalLimit: number;
    availableCredit: number;
    availableCash: number;
    creditUsed: number;
    utilizationPercent: number;
  };

  billingCycle: {
    previousDues: number;
    paymentsCredits: number;
    purchasesDebits: number;
    financeCharges: number;
    cashbackEarned: number;
  };

  transactionCount: number;
}

const creditCardStatementSchema =
  new Schema<ICreditCardStatement>(
    {
      userId: {
        type: Schema.Types.ObjectId,
        required: true,
      },

      statementHash: {
        type: String,
        required: true,
        unique: true,
        index: true,
      },

      bankId: String,
      bankName: String,

      cardNumber: String,
      cardLast4: String,

      statementDate: Date,

      billingPeriod: {
        start: Date,
        end: Date,
      },

      paymentDue: {
        totalAmountDue: Number,
        minimumDue: Number,
        dueDate: Date,
      },

      creditLimits: {
        totalLimit: Number,
        availableCredit: Number,
        availableCash: Number,
        creditUsed: Number,
        utilizationPercent: Number,
      },

      billingCycle: {
        previousDues: Number,
        paymentsCredits: Number,
        purchasesDebits: Number,
        financeCharges: Number,
        cashbackEarned: Number,
      },

      transactionCount: Number,
    },
    {
      timestamps: true,
    }
  );

export const CreditCardStatement = model<ICreditCardStatement>(
  'creditCardStatement',
  creditCardStatementSchema
);
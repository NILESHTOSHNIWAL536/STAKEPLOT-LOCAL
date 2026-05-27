import mongoose, { Schema, Document } from 'mongoose';

/**
 * Cross-user merchant directory.
 *
 * Maps a stable merchant key (counterpartyVPA or normalized merchant name) to a
 * category/subcategory pair. One user resolving an unknown merchant benefits all
 * subsequent users who transact with the same counterparty.
 *
 * Resolution order in categorizeTransactions:
 *   directory hit → keyword config → LLM stub → needsReview = true
 *
 * Key strategy:
 *   Primary  — counterpartyVPA (e.g. "swiggy@icici"): stable across users/banks.
 *   Secondary — normalized merchant name (lowercase, whitespace-collapsed):
 *               used when VPA is unavailable or is a raw account number.
 */
export interface IMerchantDirectory extends Document {
  key: string;
  category: string;
  subcategory: string;
  /**
   * How this entry was created:
   *   'user_correction' — a user manually recategorized a transaction
   *   'keyword'         — seeded from the keyword config during backfill
   *   'llm'             — resolved by LLM enrichment (future)
   */
  resolvedBy: 'user_correction' | 'keyword' | 'llm';
  /** 0–1; higher values take precedence over lower ones on conflicts */
  confidenceScore: number;
  updatedAt: Date;
}

const merchantDirectorySchema = new Schema<IMerchantDirectory>(
  {
    key: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    category: {
      type: String,
      required: true,
    },
    subcategory: {
      type: String,
      default: '',
    },
    resolvedBy: {
      type: String,
      enum: ['user_correction', 'keyword', 'llm'],
      required: true,
    },
    confidenceScore: {
      type: Number,
      default: 0.8,
      min: 0,
      max: 1,
    },
  },
  { timestamps: true },
);

const MerchantDirectory = mongoose.model<IMerchantDirectory>(
  'MerchantDirectory',
  merchantDirectorySchema,
);

export default MerchantDirectory;

/**
 * LLM / external enrichment extension point.
 *
 * This stub is intentionally a no-op. When you are ready to add LLM-based
 * merchant categorization, replace the body of `enrichWithLLM` with the real
 * implementation. Everything else in the pipeline (categorizeTransactions,
 * MerchantDirectory write-back) is already wired to use the result.
 *
 * Suggested implementation approach:
 *   1. Call the existing `predictCategoriesForTransactions` helper, OR
 *   2. Hit the Anthropic API with a structured prompt containing
 *      counterpartyName + VPA + remark and parse the JSON response.
 *   3. On success, call `upsertMerchantDirectory` with resolvedBy='llm' and
 *      a confidence score from the model's output (e.g. 0.7 for LLM vs 0.9 for
 *      user_correction) so human corrections always take precedence.
 */

export interface MerchantEnrichInput {
  counterpartyName?: string;
  counterpartyVPA?: string;
  remark?: string;
  narration: string;
}

export interface MerchantEnrichResult {
  category: string;
  subcategory: string;
  /** 0–1 model confidence; used as confidenceScore in MerchantDirectory */
  confidence: number;
}

/**
 * Attempts to categorize an unknown merchant using an LLM or enrichment service.
 *
 * @returns A categorization result, or null if the service is unavailable or
 *          confidence is below the acceptable threshold.
 */
export async function enrichWithLLM(
  _input: MerchantEnrichInput,
): Promise<MerchantEnrichResult | null> {
  // TODO: implement LLM/enrichment call here.
  // The function signature and integration points are stable — only the body changes.
  return null;
}

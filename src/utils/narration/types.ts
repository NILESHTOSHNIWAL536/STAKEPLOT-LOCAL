/**
 * Structured fields extracted from a raw bank narration string.
 * All fields are optional — parsers populate only what they can extract.
 */
export interface ParsedNarration {
  /** e.g. "DR" | "CR" */
  direction?: string;
  /** UPI reference / bank transaction reference number */
  ref?: string;
  /** Human-readable counterparty name (person or merchant) */
  counterpartyName?: string;
  /** Counterparty bank handle or FIP abbreviation (e.g. "CNRB", "YESB") */
  bankHandle?: string;
  /** Counterparty account number or VPA (e.g. "user@upi", "9876543210@ybl") */
  counterpartyVPA?: string;
  /** PSP remark / payment description appended by the app */
  remark?: string;
  /** Originating format label — used for debugging and future routing */
  format: string;
}

/**
 * A single parser definition. The registry tries each parser in order;
 * the first whose `pattern` matches the narration wins.
 *
 * `extract` receives the full RegExp match (index 0 = full string,
 * indexes 1..n = capture groups) and returns a ParsedNarration.
 */
export interface NarrationParserDef {
  /** Stable label for this parser (used in ParsedNarration.format) */
  name: string;
  /** Tested against the raw narration (case-insensitive) */
  pattern: RegExp;
  extract: (match: RegExpMatchArray, raw: string) => ParsedNarration;
}

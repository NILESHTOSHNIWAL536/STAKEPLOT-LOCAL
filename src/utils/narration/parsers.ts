import { NarrationParserDef, ParsedNarration } from './types';

/**
 * Data-driven parser registry.
 *
 * ADD NEW BANK FORMATS HERE — one entry per distinct narration shape.
 * Order matters: first match wins, so put more-specific patterns first.
 *
 * Capture group layout for each pattern is documented inline.
 */
export const NARRATION_PARSERS: NarrationParserDef[] = [

  // ── UPI dash format (most common) ────────────────────────────────────────
  // e.g. "UPI-DR-352383653756-NEERATI  VAMSHI-CNRB-30792200091581-Payment from PhonePe"
  //       UPI - DR - <ref>   - <name>          - <bank> - <acct/vpa>      - <remark>
  {
    name: 'UPI_DASH',
    pattern: /^UPI-(CR|DR)-(\d+)-(.+?)-([A-Z]{3,6})-([^-]+)-?(.*)$/i,
    extract(match): ParsedNarration {
      return {
        format: 'UPI_DASH',
        direction: match[1].toUpperCase(),
        ref: match[2],
        counterpartyName: match[3].trim().replace(/\s{2,}/g, ' '),
        bankHandle: match[4].toUpperCase(),
        counterpartyVPA: match[5].trim(),
        remark: match[6]?.trim() || undefined,
      };
    },
  },

  // ── UPIAR / UPIAB (Axis / AU bank format) ────────────────────────────────
  // e.g. "UPIAR/352383/CR/MERCHANT NAME/ICIC/vpa@icici/remark"
  {
    name: 'UPI_SLASH_AR',
    pattern: /^UPI(?:AR|AB)\/(\d+)\/(CR|DR)\/(.+?)\/([A-Z]{3,6})\/([^/]+)\/?(.*)$/i,
    extract(match): ParsedNarration {
      return {
        format: 'UPI_SLASH_AR',
        direction: match[2].toUpperCase(),
        ref: match[1],
        counterpartyName: match[3].trim(),
        bankHandle: match[4].toUpperCase(),
        counterpartyVPA: match[5].trim(),
        remark: match[6]?.trim() || undefined,
      };
    },
  },

  // ── UPI slash (generic) ───────────────────────────────────────────────────
  // e.g. "UPI/352383/CR/MERCHANT NAME/ICIC/vpa@icici/remark"
  {
    name: 'UPI_SLASH',
    pattern: /^UPI\/(\d+)\/(CR|DR)\/(.+?)\/([A-Z]{3,6})\/([^/]+)\/?(.*)$/i,
    extract(match): ParsedNarration {
      return {
        format: 'UPI_SLASH',
        direction: match[2].toUpperCase(),
        ref: match[1],
        counterpartyName: match[3].trim(),
        bankHandle: match[4].toUpperCase(),
        counterpartyVPA: match[5].trim(),
        remark: match[6]?.trim() || undefined,
      };
    },
  },

  // ── NEFT dash ─────────────────────────────────────────────────────────────
  // e.g. "NEFT CR-SBIN322147057322-EMPLOYEE SALARY-HDFC-..."
  {
    name: 'NEFT_DASH',
    pattern: /^NEFT\s*(CR|DR)-([A-Z0-9]+)-(.+?)(?:-([A-Z]{3,6})-(.*))?$/i,
    extract(match): ParsedNarration {
      return {
        format: 'NEFT_DASH',
        direction: match[1].toUpperCase(),
        ref: match[2],
        counterpartyName: match[3].trim(),
        bankHandle: match[4]?.toUpperCase(),
        counterpartyVPA: match[5]?.trim(),
      };
    },
  },

  // ── NEFT slash ────────────────────────────────────────────────────────────
  // e.g. "NEFT/SBIN322147057322/EMPLOYEE SALARY"
  {
    name: 'NEFT_SLASH',
    pattern: /^NEFT\/([A-Z0-9]+)\/(.+)$/i,
    extract(match): ParsedNarration {
      return {
        format: 'NEFT_SLASH',
        ref: match[1],
        counterpartyName: match[2].trim(),
      };
    },
  },

  // ── IMPS slash ────────────────────────────────────────────────────────────
  // e.g. "IMPS/352383653756/MERCHANT NAME/ICIC/"
  {
    name: 'IMPS_SLASH',
    pattern: /^IMPS\/(\d+)\/(.+?)\/([A-Z]{3,6})\/?(.*)$/i,
    extract(match): ParsedNarration {
      return {
        format: 'IMPS_SLASH',
        ref: match[1],
        counterpartyName: match[2].trim(),
        bankHandle: match[3].toUpperCase(),
        remark: match[4]?.trim() || undefined,
      };
    },
  },

  // ── RTGS / NACH ───────────────────────────────────────────────────────────
  // e.g. "RTGS-SBIN0001234-COUNTERPARTY NAME" or "NACH-00000-MERCHANT"
  {
    name: 'RTGS_NACH',
    pattern: /^(RTGS|NACH)[/ -]([A-Z0-9]+)[/ -](.+)$/i,
    extract(match): ParsedNarration {
      return {
        format: match[1].toUpperCase(),
        ref: match[2],
        counterpartyName: match[3].trim(),
      };
    },
  },
];

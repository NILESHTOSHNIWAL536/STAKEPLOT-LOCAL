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

  // UPI/ref/direction/name/bank/remark
  // e.g. "UPI/642552450652/DR/Mr BETHAMALLA/YES/Drinks"
  {
    name: 'UPI_SLASH_REF_DIRECTION_REMARK',
    pattern: /^UPI\/(\d+)\/(CR|DR)\/(.+?)\/([A-Z]{3,6})\/(.+)$/i,
    extract(match): ParsedNarration {
      return {
        format: 'UPI_SLASH_REF_DIRECTION_REMARK',
        direction: match[2].toUpperCase(),
        ref: match[1],
        counterpartyName: match[3].trim().replace(/\s{2,}/g, ' '),
        bankHandle: match[4].toUpperCase(),
        remark: match[5]?.trim() || undefined,
      };
    },
  },

  // UPI/ref/name/bank/remark
  // e.g. "UPI/102839572751/       SPOTIFY/HDF/Execution"
  {
    name: 'UPI_SLASH_REF_NAME_REMARK',
    pattern: /^UPI\/(\d+)\/(.+?)\/((?!UPI)[A-Z]{3,6})\/(.+)$/i,
    extract(match): ParsedNarration {
      return {
        format: 'UPI_SLASH_REF_NAME_REMARK',
        ref: match[1],
        counterpartyName: match[2].trim().replace(/\s{2,}/g, ' '),
        bankHandle: match[3].toUpperCase(),
        remark: match[4]?.trim() || undefined,
      };
    },
  },

  // UPI/name/vpa-or-handle/remark/bank
  // e.g. "UPI/Zepto Mark/ZeptoMarketpla/Payment fr/AIRTEL PA"
  {
    name: 'UPI_SLASH_NAME_VPA_REMARK_BANK',
    pattern: /^UPI\/(?!\d+\/)(.+?)\/([^/]+)\/([^/]+)\/(.+)$/i,
    extract(match): ParsedNarration {
      return {
        format: 'UPI_SLASH_NAME_VPA_REMARK_BANK',
        counterpartyName: match[1].trim().replace(/\s{2,}/g, ' '),
        counterpartyVPA: match[2].trim(),
        remark: match[3]?.trim() || undefined,
        bankHandle: match[4]?.trim(),
      };
    },
  },

  // UPI/ref/time/UPI/vpa-or-handle/remark
  // e.g. "UPI/646800733256/142622/UPI/paytmqr6uh5afptys/"
  {
    name: 'UPI_SLASH_REF_TIME_VPA',
    pattern: /^UPI\/(\d+)\/(\d{4,6})\/UPI\/([^/]+)\/?(.*)$/i,
    extract(match): ParsedNarration {
      return {
        format: 'UPI_SLASH_REF_TIME_VPA',
        ref: match[1],
        counterpartyVPA: match[3].trim(),
        remark: match[4]?.trim() || undefined,
      };
    },
  },

  // UPI-name-vpa-remark, without explicit CR/DR/ref
  // e.g. "UPI-MALAGAM HEMANG RAM P-8639998407@JUPI"
  {
    name: 'UPI_DASH_NAME_VPA',
    pattern: /^UPI-(.+?)-([^-\s]+@?[A-Z0-9._-]*)(?:-(.*))?$/i,
    extract(match): ParsedNarration {
      return {
        format: 'UPI_DASH_NAME_VPA',
        counterpartyName: match[1].trim().replace(/\s{2,}/g, ' '),
        counterpartyVPA: match[2].trim(),
        remark: match[3]?.trim() || undefined,
      };
    },
  },

  // ── NEFT dash ─────────────────────────────────────────────────────────────
  // e.g. "NEFT CR-SBIN322147057322-EMPLOYEE SALARY-HDFC-..."
  {
    name: 'NEFT_DASH',
    pattern: /^NEFT\s*(CR|DR)-([A-Z0-9]+)-(.+)$/i,
    extract(match, raw): ParsedNarration {
      const parts = match[3].split('-').map((part) => part.trim()).filter(Boolean);
      const possibleBankHandle = parts[1];
      const hasBankHandle = !!possibleBankHandle && /^[A-Z]{3,6}$/i.test(possibleBankHandle);

      return {
        format: 'NEFT_DASH',
        direction: match[1].toUpperCase(),
        ref: match[2],
        counterpartyName: (parts[0] || raw).trim().replace(/\s{2,}/g, ' '),
        bankHandle: hasBankHandle ? possibleBankHandle.toUpperCase() : undefined,
        counterpartyVPA: hasBankHandle ? parts.slice(2).join('-') || undefined : undefined,
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
  // CMS / ACH / NACH slash transfer
  // e.g. "CMS/ CMS5679346428/META INFOTECH PRIVATE LIMITED"
  {
    name: 'STRUCTURED_TRANSFER_SLASH',
    pattern: /^(CMS|ACH|NACH)\/\s*([A-Z0-9]+)\/\s*(.+)$/i,
    extract(match): ParsedNarration {
      return {
        format: 'STRUCTURED_TRANSFER_SLASH',
        ref: match[2].trim(),
        counterpartyName: match[3].trim().replace(/\s{2,}/g, ' '),
      };
    },
  },

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

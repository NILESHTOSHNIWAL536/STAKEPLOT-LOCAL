import { parseNarration } from '../utils/narration/parseNarration';

describe('parseNarration', () => {

  // ── UPI dash (most common format) ──────────────────────────────────────────

  describe('UPI_DASH', () => {
    it('parses domain-context P2P example', () => {
      const result = parseNarration(
        'UPI-DR-352383653756-NEERATI  VAMSHI-CNRB-30792200091581-Payment from PhonePe',
      );
      expect(result).not.toBeNull();
      expect(result!.format).toBe('UPI_DASH');
      expect(result!.direction).toBe('DR');
      expect(result!.ref).toBe('352383653756');
      expect(result!.counterpartyName).toBe('NEERATI VAMSHI'); // double-space collapsed
      expect(result!.bankHandle).toBe('CNRB');
      expect(result!.counterpartyVPA).toBe('30792200091581');
      expect(result!.remark).toBe('Payment from PhonePe');
    });

    it('parses domain-context P2M merchant example', () => {
      const result = parseNarration(
        'UPI-DR-163427235956-TINGLE BUDS F  B PRIVATE LIMITED-YESB-002261100000025-Payment from PhonePe',
      );
      expect(result).not.toBeNull();
      expect(result!.format).toBe('UPI_DASH');
      expect(result!.direction).toBe('DR');
      expect(result!.counterpartyName).toBe('TINGLE BUDS F B PRIVATE LIMITED');
      expect(result!.bankHandle).toBe('YESB');
      expect(result!.counterpartyVPA).toBe('002261100000025');
    });

    it('parses CR direction', () => {
      const result = parseNarration('UPI-CR-123456-FRIEND NAME-ICIC-friend@icici-Payment from PhonePe');
      expect(result!.direction).toBe('CR');
      expect(result!.counterpartyName).toBe('FRIEND NAME');
    });

    it('handles missing remark gracefully', () => {
      const result = parseNarration('UPI-DR-999-MERCHANT NAME-HDFC-merchant@hdfc');
      expect(result).not.toBeNull();
      expect(result!.remark).toBeUndefined();
    });
  });

  // ── NEFT slash ─────────────────────────────────────────────────────────────

  describe('NEFT_SLASH', () => {
    it('parses domain-context salary example', () => {
      const result = parseNarration('NEFT/SBIN322147057322/EMPLOYEE SALARY');
      expect(result).not.toBeNull();
      expect(result!.format).toBe('NEFT_SLASH');
      expect(result!.ref).toBe('SBIN322147057322');
      expect(result!.counterpartyName).toBe('EMPLOYEE SALARY');
    });
  });

  describe('NEFT_DASH', () => {
    it('parses NEFT-CR dash format', () => {
      const result = parseNarration('NEFT CR-SBIN322147057322-ACME CORP-HDFC-xyz');
      expect(result).not.toBeNull();
      expect(result!.format).toBe('NEFT_DASH');
      expect(result!.direction).toBe('CR');
      expect(result!.counterpartyName).toBe('ACME CORP');
    });
  });

  // ── UPI slash variants ─────────────────────────────────────────────────────

  describe('UPI_SLASH', () => {
    it('parses standard UPI slash format', () => {
      const result = parseNarration('UPI/352383/CR/SWIGGY/ICIC/swiggy@icici/Food order');
      expect(result).not.toBeNull();
      expect(result!.format).toBe('UPI_SLASH');
      expect(result!.direction).toBe('CR');
      expect(result!.counterpartyName).toBe('SWIGGY');
      expect(result!.counterpartyVPA).toBe('swiggy@icici');
    });
  });

  describe('UPI_SLASH_AR', () => {
    it('parses UPIAR (Axis/AU bank) format', () => {
      const result = parseNarration('UPIAR/352383/CR/PHONEPE MERCHANT/AXIS/merchant@ybl/remark');
      expect(result).not.toBeNull();
      expect(result!.format).toBe('UPI_SLASH_AR');
      expect(result!.counterpartyName).toBe('PHONEPE MERCHANT');
    });

    it('parses UPIAB variant', () => {
      const result = parseNarration('UPIAB/123456/DR/AMAZON/SBIN/amazon@upi/');
      expect(result).not.toBeNull();
      expect(result!.format).toBe('UPI_SLASH_AR');
    });
  });

  // ── IMPS ───────────────────────────────────────────────────────────────────

  describe('IMPS_SLASH', () => {
    it('parses IMPS slash format', () => {
      const result = parseNarration('IMPS/352383653756/MERCHANT NAME/ICIC/');
      expect(result).not.toBeNull();
      expect(result!.format).toBe('IMPS_SLASH');
      expect(result!.ref).toBe('352383653756');
      expect(result!.counterpartyName).toBe('MERCHANT NAME');
      expect(result!.bankHandle).toBe('ICIC');
    });
  });

  // ── RTGS / NACH ────────────────────────────────────────────────────────────

  describe('RTGS_NACH', () => {
    it('parses RTGS format', () => {
      const result = parseNarration('RTGS-SBIN0001234-LARGE CORP LTD');
      expect(result).not.toBeNull();
      expect(result!.format).toBe('RTGS');
      expect(result!.counterpartyName).toBe('LARGE CORP LTD');
    });

    it('parses NACH format', () => {
      const result = parseNarration('NACH/00000123/EMI LENDER');
      expect(result).not.toBeNull();
      expect(result!.format).toBe('NACH');
      expect(result!.counterpartyName).toBe('EMI LENDER');
    });
  });

  // ── Edge cases ─────────────────────────────────────────────────────────────

  describe('edge cases', () => {
    it('returns null for unrecognised format', () => {
      expect(parseNarration('SOME COMPLETELY UNKNOWN FORMAT')).toBeNull();
    });

    it('returns null for null input', () => {
      expect(parseNarration(null)).toBeNull();
    });

    it('returns null for empty string', () => {
      expect(parseNarration('')).toBeNull();
    });

    it('handles case-insensitive matching', () => {
      const result = parseNarration('upi-dr-123456-friend name-icic-vpa@icici');
      expect(result).not.toBeNull();
      expect(result!.direction).toBe('DR');
    });

    it('collapses multiple internal spaces in counterpartyName', () => {
      const result = parseNarration('UPI-DR-123-FIRST  LAST-CNRB-vpa@cnrb');
      expect(result!.counterpartyName).toBe('FIRST LAST');
    });

    it('handles truncated narration without remark segment', () => {
      const result = parseNarration('UPI-DR-123-MERCHANT-HDFC-vpa@hdfc');
      expect(result).not.toBeNull();
      expect(result!.remark).toBeUndefined();
    });
  });
});

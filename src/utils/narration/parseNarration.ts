import { ParsedNarration } from './types';
import { NARRATION_PARSERS } from './parsers';

/**
 * Attempts to parse a raw bank narration string into structured fields.
 *
 * Tries each registered parser in order; returns the first successful result.
 * Returns null if no parser matches — callers must handle this gracefully and
 * fall back to operating on the raw narration string.
 */
export function parseNarration(narration: string | null | undefined): ParsedNarration | null {
  if (!narration || typeof narration !== 'string') return null;

  for (const parser of NARRATION_PARSERS) {
    const match = narration.match(parser.pattern);
    if (match) {
      try {
        return parser.extract(match, narration);
      } catch {
        // Malformed capture groups — move on to the next parser
        continue;
      }
    }
  }

  return null;
}

export { ParsedNarration };

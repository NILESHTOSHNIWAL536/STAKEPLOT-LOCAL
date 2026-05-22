export function extractNarrationPattern(narration: string | null | undefined): string | null | undefined {
  if (!narration || typeof narration !== 'string') {
    return narration;
  }

  // Case 1: Slash-separated pattern
  if (narration.includes('/')) {
    const parts = narration.split('/');
    return parts.length >= 5 ? `${parts[3]}/${parts[4]}` : narration;
  }

  // Case 2: Hyphen-separated pattern
  if (narration.includes('-')) {
    const parts = narration.split('-');
    return parts.length >= 4 ? `${parts[3]}-${parts[4]}` : narration;
  }

  return narration;
}

export default extractNarrationPattern;

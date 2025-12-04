function extractNarrationPattern(narration) {
    if (!narration || typeof narration !== 'string') return narration;
  
    if (narration.includes('/')) {
      const parts = narration.split('/');
      return parts.length >= 5 ? `${parts[3]}/${parts[4]}` : narration;
    } else if (narration.includes('-')) {
      const parts = narration.split('-');
      return parts.length >= 4 ? `${parts[3]}-${parts[4]}` : narration;
    }
  
    return narration;
  }
  
  module.exports = extractNarrationPattern;
  
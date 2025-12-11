export function calculatePercentageChange(current: number, previous: number): string {
  if (previous === 0 && current === 0) return "same as last month";

  // When no previous value existed but current value is more (expense increased)
  if (previous === 0) return "-100% vs last month";

  // Flipped logic as in your updated function
  const change = ((previous - current) / previous) * 100;
  const rounded = Math.round(change);

  if (rounded === 0) return "same as last month";

  return `${rounded > 0 ? "+" : ""}${rounded}% vs last month`;
}

export default calculatePercentageChange;

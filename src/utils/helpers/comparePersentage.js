// function calculatePercentageChange2(current, previous) {
//   if (previous === 0 && current === 0) return "same as last month";
//   if (previous === 0) return "+100% vs last month";
//   const change = ((current - previous) / previous) * 100;
//   const rounded = Math.round(change);
//   if (rounded === 0) return "same as last month";
//   return `${rounded > 0 ? "+" : ""}${rounded}% vs last month`;
// }

function calculatePercentageChange(current, previous) {
  if (previous === 0 && current === 0) return "same as last month";
  if (previous === 0) return "-100% vs last month"; // More expense when none existed

  const change = ((previous - current) / previous) * 100; // Flipped logic
  const rounded = Math.round(change);

  if (rounded === 0) return "same as last month";
  return `${rounded > 0 ? "+" : ""}${rounded}% vs last month`;
}

module.exports = calculatePercentageChange;

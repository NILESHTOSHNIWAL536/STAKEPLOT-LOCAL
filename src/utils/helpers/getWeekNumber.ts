export function getWeekNumber(date: Date): number {
  const startOfYear = new Date(date.getFullYear(), 0, 1);
  const pastDaysOfYear = (date.getTime() - startOfYear.getTime()) / 86400000; // ms → days

  // Calculate the week number
  return Math.ceil((pastDaysOfYear + startOfYear.getDay() + 1) / 7);
}


export function getNinetyDaysAgo(dateRange: number): string {
  const date = new Date();
  date.setDate(date.getDate() - dateRange);
  return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`;
}

export function getNHoursAgo(hours = 12): number {
  const date = new Date();
  date.setHours(date.getHours() - hours);
  return Math.floor(date.getTime() / 1000);
}

export default {
  getNinetyDaysAgo,
  getNHoursAgo,
};

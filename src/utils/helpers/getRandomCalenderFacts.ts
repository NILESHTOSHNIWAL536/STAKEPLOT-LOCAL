export function getRandomCalendarFact(): string {
  const today = new Date();
  const year = today.getFullYear();
  const month = today.getMonth(); // 0-indexed

  // Get the last day of the month
  const lastDayOfMonth = new Date(year, month + 1, 0);
  const daysLeft = (lastDayOfMonth.getTime() - today.getTime()) / (1000 * 60 * 60 * 24);
  const roundedDaysLeft = Math.ceil(daysLeft);

  // Count Sundays left in the month
  let sundaysLeft = 0;
  for (let d = new Date(today); d <= lastDayOfMonth; d.setDate(d.getDate() + 1)) {
    if (d.getDay() === 0) {
      sundaysLeft++;
    }
  }

  const facts: string[] = [
    `Only ${sundaysLeft} Sunday${sundaysLeft !== 1 ? 's' : ''} left this month.`,
    `Last ${roundedDaysLeft} day${roundedDaysLeft !== 1 ? 's' : ''} left in this month.`,
    `${sundaysLeft} more Sunday${sundaysLeft !== 1 ? 's' : ''} to go this month.`,
    `Just ${roundedDaysLeft} day${roundedDaysLeft !== 1 ? 's' : ''} remaining in this month.`,
  ];

  return facts[Math.floor(Math.random() * facts.length)];
}

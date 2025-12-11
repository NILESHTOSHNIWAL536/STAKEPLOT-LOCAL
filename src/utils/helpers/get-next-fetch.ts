function getNextFetch(): string {
  const now = new Date();

  // Get day of week (0 = Sunday, ..., 5 = Friday)
  const dayOfWeek = now.getDay();

  // Calculate days until next Friday
  let daysUntilFriday = (5 - dayOfWeek + 7) % 7;
  if (daysUntilFriday === 0) daysUntilFriday = 7;

  // Create next Friday date and set time to 8:00 AM
  const nextFriday = new Date(now);
  nextFriday.setDate(now.getDate() + daysUntilFriday);
  nextFriday.setHours(8, 0, 0, 0);

  return nextFriday.toISOString();
}

function getNextMonthFetch(): string {
  const now = new Date();

  // Get the first day of the next month
  const year = now.getFullYear();
  const month = now.getMonth() + 1;

  const firstOfNextMonth = new Date(year, month, 1);

  // Find first Friday of next month
  const dayOfWeek = firstOfNextMonth.getDay();
  const daysUntilFriday = (5 - dayOfWeek + 7) % 7;

  const firstFriday = new Date(firstOfNextMonth);
  firstFriday.setDate(firstOfNextMonth.getDate() + daysUntilFriday);
  firstFriday.setHours(8, 0, 0, 0);

  return firstFriday.toISOString();
}

export { getNextFetch, getNextMonthFetch };

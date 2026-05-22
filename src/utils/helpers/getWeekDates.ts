export function getStartDateOfISOWeek(week: number, year: number): Date {
  // Start at the first day of the target ISO week
  const simple = new Date(year, 0, 1 + (week - 1) * 7);

  // JS: Sunday = 0, Monday = 1, ..., Saturday = 6
  const dayOfWeek = simple.getDay();

  const ISOWeekStart = new Date(simple);

  if (dayOfWeek <= 4) {
    // Move backward to Monday
    ISOWeekStart.setDate(simple.getDate() - dayOfWeek + 1);
  } else {
    // Move forward to next Monday
    ISOWeekStart.setDate(simple.getDate() + (8 - dayOfWeek));
  }

  return ISOWeekStart;
}

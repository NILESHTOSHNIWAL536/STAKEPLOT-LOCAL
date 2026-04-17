import moment from 'moment-timezone';

// WARNING: Do not use moment directly in business logic; prefer helpers here.
export const DEFAULT_TZ = 'Asia/Kolkata';

export function getStartOfDay(date: Date, tz: string = DEFAULT_TZ): Date {
  return moment(date).tz(tz).startOf('day').utc().toDate();
}

export function getEndOfDay(date: Date, tz: string = DEFAULT_TZ): Date {
  return moment(date).tz(tz).endOf('day').utc().toDate();
}

export function getLastNDaysRange(n: number, date: Date, tz: string = DEFAULT_TZ) {
  const end = getEndOfDay(date, tz);
  const start = moment(end).tz(tz).subtract(n - 1, 'days').startOf('day').utc().toDate();
  return { start, end };
}

export function getLast7DaysRange(date: Date, tz: string = DEFAULT_TZ) {
  return getLastNDaysRange(7, date, tz);
}

export function getLast70DaysRange(date: Date, tz: string = DEFAULT_TZ) {
  return getLastNDaysRange(70, date, tz);
}

export function getMonthToDateRatio(date: Date, tz: string = DEFAULT_TZ): number {
  const m = moment(date).tz(tz);
  return m.date() / m.daysInMonth();
}

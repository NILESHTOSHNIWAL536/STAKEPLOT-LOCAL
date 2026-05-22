import moment from 'moment-timezone';

const DEFAULT_TZ = 'Asia/Kolkata';

// -----------------------------
// Types
// -----------------------------
export type RangeType = 'month' | 'week' | 'custom' | 'year';

export interface DateRange {
  startDate: Date;
  endDate: Date;
  groupBy: 'day' | 'month';
}

export interface AggregatedRecord {
  _id: { date: string };
  debit: number;
  credit: number;
}

export interface FillResult {
  result: Record<string, { debit: number; credit: number }>;
  minAmount: number;
  maxAmount: number;
  totalDebit: number;
  totalCredit: number;
}

// -----------------------------
// Main: Get date range for month, week, custom, year
// All boundaries are IST-aligned and returned as UTC Dates so that
// MongoDB queries (which store timestamps in UTC) are correct for Indian users.
// -----------------------------
export const getDateRange = (type: RangeType, value: string): DateRange => {
  let startDate: Date;
  let endDate: Date;
  let groupBy: 'day' | 'month' = 'day';

  if (type === 'month') {
    // value = "YYYY-MM"
    const m = moment.tz(value, 'YYYY-MM', DEFAULT_TZ);
    startDate = m.clone().startOf('month').utc().toDate();
    endDate   = m.clone().endOf('month').utc().toDate();
  } else if (type === 'week') {
    // value = "YYYY-WNN" (ISO week)
    const m = moment.tz(value, 'GGGG-[W]WW', DEFAULT_TZ);
    startDate = m.clone().startOf('isoWeek').utc().toDate();
    endDate   = m.clone().endOf('isoWeek').utc().toDate();
  } else if (type === 'custom') {
    // value = "YYYY-MM-DD,YYYY-MM-DD"
    const [start, end] = value.split(',');
    startDate = moment.tz(start.trim(), DEFAULT_TZ).startOf('day').utc().toDate();
    endDate   = moment.tz(end.trim(),   DEFAULT_TZ).endOf('day').utc().toDate();
  } else if (type === 'year') {
    // value = "YYYY"
    const m = moment.tz(value, 'YYYY', DEFAULT_TZ);
    startDate = m.clone().startOf('year').utc().toDate();
    endDate   = m.clone().endOf('year').utc().toDate();
    groupBy = 'month';
  } else {
    throw new Error('Invalid type parameter');
  }

  return { startDate, endDate, groupBy };
};

// -----------------------------
// Initialize result object for given range
// -----------------------------
export const initializeResults = (type: RangeType, startDate: Date, endDate: Date, monthNames: string[]): Record<string, { debit: number; credit: number }> => {
  const result: Record<string, { debit: number; credit: number }> = {};

  if (type === 'year') {
    for (let i = 0; i < 12; i++) {
      result[monthNames[i]] = { debit: 0, credit: 0 };
    }
  } else {
    const cursor = new Date(startDate);

    while (cursor <= endDate) {
      const dateKey = cursor.toISOString().split('T')[0];
      result[dateKey] = { debit: 0, credit: 0 };
      cursor.setDate(cursor.getDate() + 1);
    }
  }

  return result;
};

// -----------------------------
// Fill result with aggregated debit & credit data
// -----------------------------
export const fillTransactionData = (response: AggregatedRecord[], result: Record<string, { debit: number; credit: number }>, type: RangeType, monthNames: string[]): FillResult => {
  let minAmount = 0;
  let maxAmount = 0;
  let totalDebit = 0;
  let totalCredit = 0;

  response.forEach(({ _id, debit, credit }) => {
    if (type === 'year') {
      const [, month] = _id.date.split('-');
      const monthIndex = parseInt(month, 10) - 1;
      const monthKey = monthNames[monthIndex];

      if (monthKey) {
        result[monthKey] = { debit, credit };
      }
    } else {
      const dateKey = _id.date;
      if (result[dateKey]) {
        result[dateKey] = { debit, credit };
      }
    }

    minAmount = Math.min(minAmount, debit, credit);
    maxAmount = Math.max(maxAmount, debit, credit);

    totalDebit += debit;
    totalCredit += credit;
  });

  return { result, minAmount, maxAmount, totalDebit, totalCredit };
};

// -----------------------------
export default {
  getDateRange,
  initializeResults,
  fillTransactionData,
};

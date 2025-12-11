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
// Helper: Get start date of ISO week
// -----------------------------
export const getStartDateOfISOWeek = (weekNum: number, year: number): Date => {
  const simple = new Date(year, 0, 1 + (weekNum - 1) * 7);
  const dayOfWeek = simple.getDay();
  const ISOweekStart = new Date(simple);

  if (dayOfWeek <= 4) {
    ISOweekStart.setDate(simple.getDate() - simple.getDay() + 1);
  } else {
    ISOweekStart.setDate(simple.getDate() + 8 - simple.getDay());
  }

  return ISOweekStart;
};

// -----------------------------
// Main: Get date range for month, week, custom, year
// -----------------------------
export const getDateRange = (type: RangeType, value: string): DateRange => {
  let startDate: Date;
  let endDate: Date;
  let groupBy: 'day' | 'month' = 'day';

  if (type === 'month') {
    const [year, month] = value.split('-');
    const y = parseInt(year, 10);
    const m = parseInt(month, 10) - 1;

    startDate = new Date(Date.UTC(y, m, 1, 0, 0, 0, 0));
    endDate = new Date(Date.UTC(y, m + 1, 0, 23, 59, 59, 999));
  } else if (type === 'week') {
    const [yearStr, weekStr] = value.split('-W');
    const year = parseInt(yearStr, 10);
    const weekNum = parseInt(weekStr, 10);

    startDate = getStartDateOfISOWeek(weekNum, year);
    startDate = new Date(Date.UTC(startDate.getUTCFullYear(), startDate.getUTCMonth(), startDate.getUTCDate(), 0, 0, 0, 0));

    endDate = new Date(startDate);
    endDate.setUTCDate(endDate.getUTCDate() + 6);
    endDate.setUTCHours(23, 59, 59, 999);
  } else if (type === 'custom') {
    const [start, end] = value.split(',');
    startDate = new Date(start);
    endDate = new Date(end);

    startDate.setUTCHours(0, 0, 0, 0);
    endDate.setUTCHours(23, 59, 59, 999);
  } else if (type === 'year') {
    const y = parseInt(value, 10);

    startDate = new Date(Date.UTC(y, 0, 1, 0, 0, 0, 0));
    endDate = new Date(Date.UTC(y, 11, 31, 23, 59, 59, 999));

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

import moment from 'moment-timezone';

const DEFAULT_TZ = 'Asia/Kolkata';

export function getCurrentWeekRange(): {
  currentWeekStart: Date;
  currentWeekEnd: Date;
} {
  const now = moment().tz(DEFAULT_TZ);
  return {
    currentWeekStart: now.clone().startOf('isoWeek').utc().toDate(),
    currentWeekEnd: now.clone().endOf('isoWeek').utc().toDate(),
  };
}

export function getLastWeekRange(): {
  lastWeekStart: Date;
  lastWeekEnd: Date;
} {
  const now = moment().tz(DEFAULT_TZ);
  return {
    lastWeekStart: now.clone().subtract(1, 'week').startOf('isoWeek').utc().toDate(),
    lastWeekEnd: now.clone().subtract(1, 'week').endOf('isoWeek').utc().toDate(),
  };
}

export function getCurrentMonthRange(): {
  currentMonthStart: Date;
  currentMonthEnd: Date;
} {
  const now = moment().tz(DEFAULT_TZ);
  return {
    currentMonthStart: now.clone().startOf('month').utc().toDate(),
    currentMonthEnd: now.clone().endOf('month').utc().toDate(),
  };
}

export function getLastMonthRange(): {
  lastMonthStart: Date;
  lastMonthEnd: Date;
} {
  const now = moment().tz(DEFAULT_TZ);
  return {
    lastMonthStart: now.clone().subtract(1, 'month').startOf('month').utc().toDate(),
    lastMonthEnd: now.clone().subtract(1, 'month').endOf('month').utc().toDate(),
  };
}

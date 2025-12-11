export function getCurrentWeekRange(): {
  currentWeekStart: Date;
  currentWeekEnd: Date;
} {
  const now = new Date();
  const day = now.getDay(); // Sunday = 0
  const diffToMonday = (day === 0 ? -6 : 1) - day;

  const monday = new Date(now);
  monday.setDate(now.getDate() + diffToMonday);
  monday.setHours(0, 0, 0, 0);

  const sunday = new Date(monday);
  sunday.setDate(monday.getDate() + 6);
  sunday.setHours(23, 59, 59, 999);

  return { currentWeekStart: monday, currentWeekEnd: sunday };
}

export function getLastWeekRange(): {
  lastWeekStart: Date;
  lastWeekEnd: Date;
} {
  const now = new Date();
  const day = now.getDay();
  const diffToMonday = (day === 0 ? -6 : 1) - day;

  const thisWeekMonday = new Date(now);
  thisWeekMonday.setDate(now.getDate() + diffToMonday);
  thisWeekMonday.setHours(0, 0, 0, 0);

  const lastWeekMonday = new Date(thisWeekMonday);
  lastWeekMonday.setDate(thisWeekMonday.getDate() - 7); // one full week earlier

  const lastWeekSunday = new Date(lastWeekMonday);
  lastWeekSunday.setDate(lastWeekMonday.getDate() + 6);
  lastWeekSunday.setHours(23, 59, 59, 999);

  return { lastWeekStart: lastWeekMonday, lastWeekEnd: lastWeekSunday };
}

export function getCurrentMonthRange(): {
  currentMonthStart: Date;
  currentMonthEnd: Date;
} {
  const now = new Date();
  const currentMonthStart = new Date(now.getFullYear(), now.getMonth(), 1);
  const currentMonthEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);

  return { currentMonthStart, currentMonthEnd };
}

export function getLastMonthRange(): {
  lastMonthStart: Date;
  lastMonthEnd: Date;
} {
  const now = new Date();
  const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59, 999);

  return { lastMonthStart, lastMonthEnd };
}

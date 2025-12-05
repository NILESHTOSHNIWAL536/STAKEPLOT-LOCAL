export type Frequency = 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'biannual';

export function fetchNextReminderAt(date: string | Date, frequency: Frequency): Date {
  const newDate = new Date(date);

  if (isNaN(newDate.getTime())) {
    throw new Error(`Invalid date: ${date}`);
  }

  switch (frequency) {
    case 'daily':
      newDate.setUTCDate(newDate.getUTCDate() + 1);
      break;
    case 'weekly':
      newDate.setUTCDate(newDate.getUTCDate() + 7);
      break;
    case 'monthly':
      newDate.setUTCMonth(newDate.getUTCMonth() + 1);
      break;
    case 'quarterly':
      newDate.setUTCMonth(newDate.getUTCMonth() + 3);
      break;
    case 'biannual':
      newDate.setUTCMonth(newDate.getUTCMonth() + 6);
      break;
    default:
      // TS ensures this is unreachable unless type widened
      throw new Error(`Unknown frequency: ${frequency}`);
  }

  return newDate;
}

export default fetchNextReminderAt;

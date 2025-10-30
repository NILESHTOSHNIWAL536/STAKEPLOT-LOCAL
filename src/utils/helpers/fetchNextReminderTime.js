function fetchNextReminderAt(date, frequency) {
  const newDate = new Date(date);

  switch (frequency)
  {
    case "daily":
      newDate.setUTCDate(newDate.getUTCDate() + 1);
      break;
    case "weekly":
      newDate.setUTCDate(newDate.getUTCDate() + 7);
      break;
    case "monthly":
      newDate.setUTCMonth(newDate.getUTCMonth() + 1);
      break;
    case "quarterly":
      newDate.setUTCMonth(newDate.getUTCMonth() + 3);
      break;
    case "biannual":
      newDate.setUTCMonth(newDate.getUTCMonth() + 6);
      break;
    default:
      throw new Error(`Unknown frequency: ${frequency}`);
  }

  return newDate;
}


module.exports = fetchNextReminderAt;
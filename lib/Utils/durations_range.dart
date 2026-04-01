String getIsoDateFromDuration(String duration) {
  final now = DateTime.now();

  if (duration == "3 Months") {
    return DateTime(now.year, now.month + 3, now.day).toIso8601String();
  } else if (duration == "6 Months") {
    return DateTime(now.year, now.month + 6, now.day).toIso8601String();
  } else if (duration == "1 Year") {
    return DateTime(now.year + 1, now.month, now.day).toIso8601String();
  }

  return now.toIso8601String(); // fallback
}
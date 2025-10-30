function getStartDateOfISOWeek(week, year) {
    const simple = new Date(year, 0, 1 + (week - 1) * 7); // Start at the beginning of the week
    const dayOfWeek = simple.getDay(); // ISO weeks start on Monday (0 = Sunday, 1 = Monday, ...)
    const ISOWeekStart = simple;
    if (dayOfWeek <= 4) {
        ISOWeekStart.setDate(simple.getDate() - simple.getDay() + 1); // Adjust to Monday
    } else {
        ISOWeekStart.setDate(simple.getDate() + 8 - simple.getDay()); // Adjust to next Monday
    }
    return ISOWeekStart;
}

module.exports = getStartDateOfISOWeek;
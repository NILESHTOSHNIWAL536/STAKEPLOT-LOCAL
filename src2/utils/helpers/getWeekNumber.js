function getWeekNumber(date) {
    const startOfYear = new Date(date.getFullYear(), 0, 1);
    const pastDaysOfYear = (date - startOfYear) / 86400000;

    // Calculate the week number
    return Math.ceil((pastDaysOfYear + startOfYear.getDay() + 1) / 7);
}

module.exports = getWeekNumber;
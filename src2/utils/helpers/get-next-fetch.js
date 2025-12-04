// function getNextFetch() {
//     const now = new Date();

//     // Get day of week (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
//     const dayOfWeek = now.getDay();

//     // Calculate days until next Monday
//     let daysUntilMonday = (8 - dayOfWeek) % 7;
//     if (daysUntilMonday === 0) daysUntilMonday = 7;

//     // Create next Monday date and set time to 9:00 AM
//     const nextMonday = new Date(now);
//     nextMonday.setDate(now.getDate() + daysUntilMonday);
//     nextMonday.setHours(9, 0, 0, 0); // Set to 9:00:00.000 AM

//     // Convert to ISO string
//     return nextMonday.toISOString();
// }

function getNextFetch() {
    const now = new Date();

    // Get day of week (0 = Sunday, 1 = Monday, ..., 5 = Friday, 6 = Saturday)
    const dayOfWeek = now.getDay();

    // Calculate days until next Friday
    let daysUntilFriday = (5 - dayOfWeek + 7) % 7;
    if (daysUntilFriday === 0) daysUntilFriday = 7;

    // Create next Friday date and set time to 8:00 AM
    const nextFriday = new Date(now);
    nextFriday.setDate(now.getDate() + daysUntilFriday);
    nextFriday.setHours(8, 0, 0, 0); // Set to 8:00:00.000 AM

    // Convert to ISO string
    return nextFriday.toISOString();
}

function getNextMonthFetch() {
    const now = new Date();

    // Get the first day of the next month
    const year = now.getFullYear();
    const month = now.getMonth() + 1; // JavaScript months are 0-indexed

    // Create a date object for the first day of the next month
    const firstOfNextMonth = new Date(year, month, 1);

    // Find the first Friday of the next month
    const dayOfWeek = firstOfNextMonth.getDay();
    const daysUntilFriday = (5 - dayOfWeek + 7) % 7;

    const firstFriday = new Date(firstOfNextMonth);
    firstFriday.setDate(firstOfNextMonth.getDate() + daysUntilFriday);
    firstFriday.setHours(8, 0, 0, 0); // Set to 8:00 AM

    return firstFriday.toISOString();
}



module.exports = {getNextFetch, getNextMonthFetch};

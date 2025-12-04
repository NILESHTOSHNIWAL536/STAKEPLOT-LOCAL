function getISTTimestamp() {
    const now = new Date();

    // Convert to IST (Indian Standard Time, UTC+5:30)
    const istOffset = 5.5 * 60 * 60 * 1000; // 5 hours 30 minutes in milliseconds
    const istTime = new Date(now.getTime() + istOffset);

    // Format as YYYY-MM-DDTHH:mm:ss.SSS+05:30
    const isoString = istTime.toISOString().slice(0, -1) + "+05:30";

    return isoString;
}

module.exports = getISTTimestamp;

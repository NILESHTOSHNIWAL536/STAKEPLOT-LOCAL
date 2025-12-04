function calculateBudgetDays(budget) {
    // Handle both possible formats for createdAt and endDate
    const createdAt = budget.createdAt.$date 
        ? new Date(budget.createdAt.$date) 
        : new Date(budget.createdAt);
    const endDate = budget.endDate.$date 
        ? new Date(budget.endDate.$date) 
        : new Date(budget.endDate);

    const currentDate = new Date();

    let totalDays = 0;

    switch (budget.budgetPeriod) {
        case "Weekly":
            totalDays = 7;
            break;
        case "Monthly":
            totalDays = (endDate - createdAt) / (1000 * 60 * 60 * 24);
            break;
        case "Yearly":
            totalDays = 365;
            break;
        default:
            throw new Error("Invalid budget period");
    }

    // Calculate elapsed days
    const elapsedDays = Math.min((currentDate - createdAt) / (1000 * 60 * 60 * 24), totalDays);

    return {
        totalDays: Math.round(totalDays),
        elapsedDays: Math.round(elapsedDays)
    };
}

module.exports = calculateBudgetDays;

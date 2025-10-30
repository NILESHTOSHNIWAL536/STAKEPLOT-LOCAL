
function generateWeeklySummary(transactions) {
  const spent = {};
  const dayMap = new Map(); // date -> amount
  const categoryTotals = {};
  let totalSpent = 0;
  let weekdayTotal = 0;
  let weekend = { travel: 0, food: 0, total: 0 };

  for (const txn of transactions) {
    const date = new Date(txn.transactionTimestamp);
    const dayKey = date.toISOString().split("T")[0];
    const dayOfWeek = date.getDay(); // 0 = Sunday, 6 = Saturday
    const amount = txn.amount;

    totalSpent += amount;

    // Update daily
    dayMap.set(dayKey, (dayMap.get(dayKey) || 0) + amount);

    // Update spent (category-wise)
    let cat = txn.category;
    let sub = txn.subcategory;

    // Treat subcategories "zomato", "swiggy" as categories
    if (["zomato", "swiggy"].includes(sub?.toLowerCase())) {
      cat = sub.toLowerCase();
    }

    spent[cat] = (spent[cat] || 0) + amount;
    categoryTotals[cat] = (categoryTotals[cat] || 0) + amount;

    // Weekend vs Weekday
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      if (cat === "travel") weekend.travel += amount;
      if (cat === "food") weekend.food += amount;
      weekend.total += amount;
    } else {
      weekdayTotal += amount;
    }
  }

  const daily = Array.from(dayMap.entries()).map(([date, spent]) => ({
    date,
    spent,
  }));
  const expenses = Object.entries(categoryTotals)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([category, amount]) => ({ amount, category }));

  return {
    weekly: {
      spent,
      totalSpent,
      daily,
      weekend,
      weekday: { total: weekdayTotal },
      expenses,
    },
  };
}

function lastWeekTotalSpent(transactions) {
  const lastWeekDebitTransactions = transactions.filter((txn) =>txn.type === 'DEBIT');
  return lastWeekDebitTransactions.reduce((sum, txn) => sum + txn.amount, 0);
}

function generateMonthlySummary(transactions) {
  const summary = {
    currentMonth: {
      spent: {
        total: 0,
        food: {
          amount: 0,
          breakdown: {}
        }
      },
      spentCategories: {},
      totalIncome: 0,
      daily: [],
      spentSubCategories: {
        impulsive: 0
      }
    }
  };

  // Impulsive spending categories (can be adjusted based on requirements)
  const impulsiveCategories = ['Snacks', 'Shopping', 'Personal Care', 'Entertainment'];
  // Grocery-related subcategories for food breakdown
  const grocerySubcategories = ['Fruits', 'Vegetables', 'Dairy'];

  const diningCategories = ["Restaurant", "Cafe", "Pizza", "Dairy", "Tea", "Chai",
            "canteen", "Bistro", "Mcdonalds", "kfc", "subway", "dominos", "Dhaba",
            "Chicken", "Italia", "bawarchi", "cafe", "Tiffin", "meals", "Vegetables",
            "udupi", "coffee", "eats", "Frankie", "kirana", "Store", "General Store",
            "rasoi", "Burger King", "Foods", "juice", "Ration", "Mithai", "Biryani", "Pizza", "Burger", "Chinese", "Sweet Shop", "Street Food", "Fast Food", "Canteen", "Mess", "Tea Stall", "Coffee Shop", "hotel","cater","restau","catering","Taco Bell", "BAKERS", "FOODS", "Veggie", "PISTA HOUSE", "Shah Gouse", "mutton", "mehfil", "tiffins"]

  // Track daily spending
  const dailySpent = {};

  transactions.forEach(transaction => {
    const amount = transaction.amount;
    const date = new Date(transaction.transactionTimestamp).toISOString().split('T')[0];
    const category = transaction.category || 'Untagged';
    const subcategory = transaction.subcategory || '';

    // Handle income (CREDIT transactions)
    if (transaction.type === 'CREDIT') {
      summary.currentMonth.totalIncome += amount;
      return;
    }

    // Handle expenses (DEBIT transactions)
    if (transaction.type === 'DEBIT') {
      // Update total spent
      summary.currentMonth.spent.total += amount;

      // Update daily spending
      if (!dailySpent[date]) {
        dailySpent[date] = 0;
      }
      dailySpent[date] += amount;

      // Handle food delivery services
      if (['zomato', 'swiggy'].includes(subcategory.toLowerCase())) {
        if (!summary.currentMonth.spent.foodDelivery) {
          summary.currentMonth.spent.foodDelivery = 0;
        }
        summary.currentMonth.spent.foodDelivery += amount;
      }

      // New case: diningOut category
      if (diningCategories.includes(subcategory)) {
        if (!summary.currentMonth.spent.diningOut) {
          summary.currentMonth.spent.diningOut = 0;
        }
        summary.currentMonth.spent.diningOut += amount;
      }

      // Update main categories in spent
      if (category.toLowerCase().includes('grocer') || category.toLowerCase().includes('food')) {
        // Handle food/groceries
        summary.currentMonth.spent.food.amount += amount;
        
        // Initialize subcategory in breakdown if not present
        const breakdownKey = grocerySubcategories.includes(subcategory) ? subcategory.toLowerCase() : 'others';
        if (!summary.currentMonth.spent.food.breakdown[breakdownKey]) {
          summary.currentMonth.spent.food.breakdown[breakdownKey] = 0;
        }
        summary.currentMonth.spent.food.breakdown[breakdownKey] += amount;
      } else {
        // Initialize category in spent if not present
        const categoryKey = category.toLowerCase().replace(/\s+/g, '_');
        if (!summary.currentMonth.spent[categoryKey]) {
          summary.currentMonth.spent[categoryKey] = 0;
        }
        summary.currentMonth.spent[categoryKey] += amount;
      }

      // Update spentCategories
      if (!summary.currentMonth.spentCategories[category]) {
        summary.currentMonth.spentCategories[category] = 0;
      }
      summary.currentMonth.spentCategories[category] += amount;

      // Update impulsive spending
      if (impulsiveCategories.includes(category) || impulsiveCategories.includes(subcategory)) {
        summary.currentMonth.spentSubCategories.impulsive += amount;
      }
    }
  });

  // Format daily spending
  summary.currentMonth.daily = Object.entries(dailySpent)
    .map(([date, spent]) => ({
      date,
      spent
    }))
    .sort((a, b) => new Date(a.date) - new Date(b.date));

  return summary;
}

function generatePreviousMonthSummary(transactions) {
  const summary = {
    previousMonth: {
      spent: {
        total: 0
      },
      spentSubCategories: {
        impulsive: 0
      }
    }
  };

  // Impulsive spending categories (configurable)
  const impulsiveCategories = ['Snacks', 'Shopping', 'Personal Care', 'Entertainment'];

  transactions.forEach(transaction => {
    // Only process DEBIT transactions
    if (transaction.type !== 'DEBIT') {
      return;
    }

    const amount = transaction.amount;
    const category = transaction.category || 'Untagged';
    const subcategory = transaction.subcategory || '';

    // Update total spent
    summary.previousMonth.spent.total += amount;

    // Update category spending
    const categoryKey = category.toLowerCase().replace(/\s+/g, '_');
    if (!summary.previousMonth.spent[categoryKey]) {
      summary.previousMonth.spent[categoryKey] = 0;
    }
    summary.previousMonth.spent[categoryKey] += amount;

    // Update impulsive spending
    if (impulsiveCategories.includes(category) || impulsiveCategories.includes(subcategory)) {
      summary.previousMonth.spentSubCategories.impulsive += amount;
    }
  });

  return summary;
}


module.exports = {generateWeeklySummary, lastWeekTotalSpent, generateMonthlySummary, generatePreviousMonthSummary};
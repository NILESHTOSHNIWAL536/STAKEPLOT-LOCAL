const mongoose = require('mongoose');
const { ObjectId } = mongoose.Types;
const { User, HeadsUp } = require('../../models/index');
const logger = require('./logger');
const { GetCustomDatesTransactions } = require('../../respositories/index');
const { generateWeeklySummary, lastWeekTotalSpent, generateMonthlySummary, generatePreviousMonthSummary } = require('../helpers/headsUpSummaries');
const { getCurrentWeekRange, getLastWeekRange, getCurrentMonthtRange, getLastMonthRange } = require('../helpers/getCurrentWeekRange');
const formatINR = require('../helpers/formatINR');


const getCustomDatesTransactions = new GetCustomDatesTransactions();

// Function that analyzes expense data and returns insights
function getInsights(data) {
  const insights = [];
  // Insight 1: Weekly expense categories check
  const weeklySnack = data?.weekly?.spent?.snack || 0;
  const weeklyPersonalCare = data?.weekly?.spent?.personalCare || 0;
  const weeklyCommerce = data?.weekly?.spent?.commerce || 0;
  const monthlyTotal = data?.currentMonth?.spent?.total || 1;
  const currentDate = new Date();
  const currentDay = currentDate.getDate();
  const currentMonth = currentDate.getMonth();
  const currentYear = currentDate.getFullYear();

  const lastDayOfMonth = new Date(currentYear, currentMonth + 1, 0).getDate();

  // Only based on date
  if (currentDay > lastDayOfMonth - 7) {
    insights.push('Month-end is here! Plan your budget carefully 🚦');
  }

  if (weeklySnack > 0.08 * monthlyTotal) {
    insights.push(`Arre, you spent ${formatINR(weeklySnack)} on snacks this week – that's a lot of munching! Be careful, your budget might cry! 😮`);
  }
  if (weeklyPersonalCare > 0.2 * monthlyTotal) {
    insights.push(`Your ${formatINR(weeklyPersonalCare)} Personalcare spree this week? That's basically a VIP ticket to Splurge City! 🛍️`);
  }
  if (weeklyCommerce > 0.01 * monthlyTotal) {
    insights.push(`You spent over ${formatINR(weeklyCommerce)} on commerce this week – that's a mini-vacation fund 😅`);
  }

  // Insight 2: Travel expenses dropped
  const currentTravel = data?.currentMonth?.spent?.travel || 0;
  const previousTravel = data?.previousMonth?.spent?.travel || 0;
  if (previousTravel && currentTravel < previousTravel * 0.6) {
    insights.push('Travel expenses dropped by 40% this month – working from home, eh?');
  }

  // Insight 3: Food delivery doubled
  const currentFoodDelivery = data?.currentMonth?.spent?.foodDelivery || 0;
  const previousFoodDelivery = data?.previousMonth?.spent?.foodDelivery || 0;
  if (previousFoodDelivery && currentFoodDelivery >= previousFoodDelivery * 2) {
    insights.push('Your food delivery budget has doubled since last month 😬');
  }

  // Insight 4: Entertainment > 15% of income
  const entertainment = data?.currentMonth?.spent?.entertainment || 0;
  const totalIncome = data?.currentMonth?.totalIncome || 1;
  if (entertainment > totalIncome * 0.15) {
    insights.push(`${formatINR(entertainment)} on entertainment – treat yourself, but maybe slow down next week?`);
  }

  // Insight 5: Week-on-week saving
  const lastWeekTotal = data?.lastWeek?.totalSpent || 0;
  const currentWeekTotal = data?.weekly?.totalSpent || 0;
  if (currentWeekTotal < lastWeekTotal) {
    insights.push(`You saved ${formatINR(lastWeekTotal - currentWeekTotal)} compared to last week – that’s impressive! One step at a time..`);
  }

  // Insight 6: Chai budget
  const previousChaiBudget = data?.previousMonth?.spent?.chai || 0;
  if (previousChaiBudget > 400) {
    insights.push(`Monthly chai budget = ${formatINR(previousChaiBudget)} ☕ – desi priorities on point.`);
  }

  // Insight 7: Top spending category
  const categories = data.currentMonth.spentCategories;
  if (categories) {
    let topCategory = '';
    let topAmount = 0;
    for (const category in categories) {
      if (category != 'Untagged' && categories[category] > topAmount) {
        topAmount = categories[category];
        topCategory = category;
      }
    }
    if (topCategory) {
      const formattedCategory = topCategory.replace(/([A-Z])/g, ' $1').replace(/^./, (str) => str.toUpperCase());
      insights.push(`Top category this month: ${formattedCategory} 🛍️`);
    }
  }

  // Insight 8: Zomato & Swiggy = 0
  const zomato = data?.weekly?.spent?.zomato || 0;
  const swiggy = data?.weekly?.spent?.swiggy || 0;
  const username = data?.user?.username || 'chef';
  if (zomato === 0 && swiggy === 0) {
    insights.push(`₹0 spent on Zomato and Swiggy this week – chef ${username} in the house? 👨‍🍳`);
  } else {
    insights.push(`You spent ${formatINR(zomato + swiggy)} on Zomato and Swiggy this week – chef ${username} in the house? 👨‍🍳`);
  }

  // Insight 9: No-spend days
  const daily = data?.weekly?.daily;
  if (Array.isArray(daily)) {
    const noSpendDays = daily.filter((day) => day?.spent === 0).length;
    if (noSpendDays >= 3) {
      insights.push(`${noSpendDays}/7 no-spend days this week – keep that streak alive!`);
    }
  }

  // Insight 10: Impulsive buying
  const currImpulsive = data?.currentMonth?.spentSubCategories?.impulsive || 0;
  const prevImpulsive = data?.previousMonth?.spentSubCategories?.impulsive || 0;
  if (currImpulsive > prevImpulsive) {
    insights.push(
      `Oye, warning! You’ve gone overboard by ${formatINR(Math.round(currImpulsive - prevImpulsive))} this month – Put a brake on those random purchases to protect your pocket! 😓`
    );
  }

  // Insight 11: Most expensive day
  const currentDaily = data?.currentMonth?.daily;
  if (Array.isArray(currentDaily)) {
    let mostExpensiveDay = null;
    currentDaily.forEach((day) => {
      if (!mostExpensiveDay || (day?.spent || 0) > mostExpensiveDay.spent) {
        mostExpensiveDay = day;
      }
    });
    if (mostExpensiveDay) {
      insights.push(`Most expensive day this month: ${mostExpensiveDay.date} – you went all out 😅`);
    }
  }

  // Insight 12: Weekend travel
  const weekendTravel = data?.weekly?.weekend?.travel || 0;
  const prevMonthTravel = data?.previousMonth?.spent?.travel || 0;
  if (weekendTravel > 0.5 * prevMonthTravel) {
    insights.push(`${formatINR(weekendTravel)} on Travel this weekend – could’ve been a staycation 🚕`);
  }

  // Insight 13: Logging streak
  if (Array.isArray(daily) && daily.length === 7) {
    insights.push('You logged in daily for 7 days in a row – streak superstar! 🌟');
  }

  // Insight 14: Highest single weekly spend
  const weeklyExpenses = data?.weekly?.expenses;
  if (Array.isArray(weeklyExpenses) && weeklyExpenses.length > 0) {
    const highestExpense = weeklyExpenses.reduce((prev, curr) => (curr?.amount > (prev?.amount || 0) ? curr : prev), { amount: 0 });
    insights.push(`Highest single spend this week: ${formatINR(highestExpense.amount)} on ${highestExpense.category}`);
  }

  // Insight 15: Healthy groceries
  const groceries = data?.currentMonth?.spent?.groceries;
  if (groceries?.amount) {
    const breakdown = groceries?.breakdown || {};
    const healthyTotal = (breakdown.fruits || 0) + (breakdown.vegetables || 0) + (breakdown.dairy || 0);
    if (healthyTotal / groceries.amount >= 0.15) {
      insights.push(`You spent ${formatINR(groceries.amount)} on groceries – home chef unlocked 🧑‍🍳`);
    }
  }

  // Insight 16: Subscription % check
  const subscription = data?.currentMonth?.spent?.subscription || 0;
  if (subscription && monthlyTotal) {
    const subPercent = (subscription / monthlyTotal) * 100;
    if (subPercent >= 8) {
      insights.push('Subscription costs make up 8% of your monthly spending 📺');
    }
  }

  // Insight 17: Weekend vs weekday spending
  const weekendTotal = data?.weekly?.weekend?.total || 0;
  const weekdayTotal = data?.weekly?.weekday?.total || 1;
  if (weekendTotal > weekdayTotal * 2) {
    insights.push('Your weekend spends are 2x your weekday spends – weekend warrior!');
  }

  // Insight 18: Overspent compared to last month
  const currMonthTotal = data?.currentMonth?.spent?.total || 0;
  const prevMonthTotal = data?.previousMonth?.spent?.total || 0;
  if (currMonthTotal > prevMonthTotal) {
    insights.push(`You have overspent by ${formatINR(Math.round(currMonthTotal - prevMonthTotal))} compared to last month’s limit – stay sharp and win the month 💰`);
  }

  // Insight 19: Dining out cost
  const diningOut = data?.currentMonth?.spent?.diningOut;
  if (diningOut) {
    insights.push(`Monthly dining out cost: ${formatINR(diningOut)} – any thoughts to reduce that?`);
  }

  // Extra Insight: High utility bills
  const Bills = data?.currentMonth?.spent?.Bills;
  if (Bills > 3000) {
    insights.push(`Your utility bills are high this month: ${formatINR(Bills)} – it might be worth reviewing your usage or plans.`);
  }

  // Extra: Dining out vs groceries
  const grocerySpend = data?.currentMonth?.spent?.groceries?.amount || 0;
  if (diningOut && grocerySpend) {
    const dineOutRatio = diningOut / (diningOut + grocerySpend);
    if (dineOutRatio > 0.3) {
      insights.push('More than half of your food spending is on dining out. Consider cooking at home more often to save money.');
    }
  }

  // New Insight 12: Online shopping crossing 25% of monthly credit
  if (data?.currentMonth?.spentCategories) {
    const onlineShoppingSpent = data?.currentMonth?.spent?.shopping || 0;
    if (onlineShoppingSpent > 0.25 * data?.currentMonth?.totalIncome) {
      insights.push('Shopping crossed 25% of your credits  🛒 – time to wishlist before checkout?');
    }
  }

  return insights;
}

async function headsUpMessages(userId) {
  const newUserId = new ObjectId(userId);
  const user = await User.findOne({ _id: newUserId });

  const { currentWeekStart, currentWeekEnd } = getCurrentWeekRange();
  const { lastWeekStart, lastWeekEnd } = getLastWeekRange();

  const { currentMonthStart, currentMonthEnd } = getCurrentMonthtRange();
  const { lastMonthStart, lastMonthEnd } = getLastMonthRange();

  // 1. Weekly transactions
  const currentWeektransactions = await getCustomDatesTransactions.getCustomDatesTransactions(newUserId, currentWeekStart, currentWeekEnd);
  const lastWeekTransactions = await getCustomDatesTransactions.getCustomDatesTransactions(newUserId, lastWeekStart, lastWeekEnd);

  // 2. Get weekly summary
  const currentWeekData = generateWeeklySummary(currentWeektransactions);
  const lastWeekTotal = lastWeekTotalSpent(lastWeekTransactions);

  // 3. Monthly transactions
  const currentMonthTransactions = await getCustomDatesTransactions.getCustomDatesTransactions(newUserId, currentMonthStart, currentMonthEnd);
  const lastMonthTransactions = await getCustomDatesTransactions.getCustomDatesTransactions(newUserId, lastMonthStart, lastMonthEnd);

  // 4. Get monthly summary
  const currentMonthSummary = generateMonthlySummary(currentMonthTransactions);
  const lastMonthSummary = generatePreviousMonthSummary(lastMonthTransactions);

  const sampleData = {
    user: { username: user.name },
    weekly: currentWeekData.weekly,
    lastWeek: { totalSpent: lastWeekTotal },
    currentMonth: currentMonthSummary.currentMonth,
    previousMonth: lastMonthSummary.previousMonth,
  };

  // logger.debug("sampleData for headsUp: ", JSON.stringify(sampleData));
  const insights = getInsights(sampleData);

  // logger.debug("insights of headsUp: ", JSON.stringify(insights));

  // update/insert the insights into the database
  try {
    var data = await HeadsUp.updateOne({ userId: newUserId }, { $set: { insights: insights } }, { upsert: true });
  } catch (err) {
    logger.error(`Error fetching headsUp data: ${err}`);
  }
}

module.exports = headsUpMessages;

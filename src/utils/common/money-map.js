const {getCurrentWeekRange, getCurrentMonthtRange, getLastMonthRange} = require("../helpers/getCurrentWeekRange");
const getCustomDatesTransactions = require("../../repositories/autoTransactions-repository/get-custom-transactions");
const { getMonthlySummaryForMoneyMap, getWeeklySummaryForMoneyMap } = require("../helpers/moneyMapSummaries");
const mongoose = require("mongoose");
const { MoneyMap } = require("../../models/index");
const formatINR = require("../helpers/formatINR");
const logger = require("../../utils/common/logger");
const getRandomCalendarFact = require("../../utils/helpers/getRandomCalenderFacts");

// const userSpendingData = {
//   currentMonth: {
//     totalSpent: 19500,
//     spent: {
//       snacks: 2810,
//       entertainment: 4200,
//     },
//     //   budget: {
//     //     entertainment: 5000
//     //   }
//   },
//   currentWeek: {
//     totalSpent: 8700,
//     spent: {
//       coffee: 750,
//       restaurants: 1200,
//       dhaba: 500,
//       pub: 700,
//     },
//     weekdaySpent: 3200,
//     weekendSpent: 5200,
//     orders: {
//       swiggy: 2,
//       zomato: 1,
//       eatsure: 1,
//     },
//   },
//   previousDays: [
//     { totalSpent: 2800 }, // yesterday
//     { totalSpent: 1800 }, // day before
//     { totalSpent: 1600 }, // two days before
//   ],
//   subscriptions: [
//     {
//       name: "Netflix",
//       amount: 499,
//       nextRenewalDate: new Date(Date.now() + 6 * 24 * 60 * 60 * 1000), // 6 days later
//     },
//     {
//       name: "Spotify",
//       amount: 119,
//       nextRenewalDate: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000), // 10 days later
//     },
//   ],
//   // budget: 20000,
//   income: 20000,
// };

function moneymap(data) {
  const insights = [];
  const welcomeMessages = [];
  const today = new Date();
  const isMidMonth = today.getDate() > 15;

  const get = (obj, path, fallback = 0) =>
    path.reduce(
      (acc, key) => (acc?.[key] !== undefined ? acc[key] : undefined),
      obj
    ) ?? fallback;

  const currentMonth = data?.currentMonth || {};
  const currentWeek = data?.currentWeek || {};
  const previousDays = data?.previousDays || [];
  const subscriptions = data?.subscriptions || [];
  // const budget = data?.budget ?? 0;
  const income = data?.income ?? 1;
  const prevIncome = data?.previousMonth?.income; 

  const snacksMonthly = get(currentMonth, ["spent", "snacks"], 0);
  // const funBudget = get(currentMonth, ["budget", "entertainment"], 0);
  // const funSpent = get(currentMonth, ["spent", "entertainment"], 0);
  const yesterday = previousDays[0]?.totalSpent ?? 0;
  const twoDaysAgo = previousDays[1]?.totalSpent ?? 0;
  const threeDaysAgo = previousDays[2]?.totalSpent ?? 0;

  const coffeeSpent = get(currentWeek, ["spent", "coffee"], 0);
   const weekTotal = get(currentWeek, ["totalSpent"], 1); // Avoid division by 0
  const weekdaySpending = get(currentWeek, ["weekdaySpent"], 0);
  const weekendSpending = get(currentWeek, ["weekendSpent"], 0);

  const diningOut =
    get(currentWeek, ["spent", "restaurants"], 0) +
    get(currentWeek, ["spent", "dhaba"], 0) +
    get(currentWeek, ["spent", "pub"], 0);

  const swiggyOrders = get(currentWeek, ["orders", "swiggy"], 0);
  const zomatoOrders = get(currentWeek, ["orders", "zomato"], 0);
  const eatsureOrders = get(currentWeek, ["orders", "eatsure"], 0);


  const swiggyOrdersCount = data.swiggyOrder.count;
  const zomatoOrdersCount = data.zomatoOrder.count;
  const totalTransactions = data.transactionsCount

  // const remainingBudget = budget - currentMonth.totalSpent;


  // welcome messages for the header
  welcomeMessages.push(`${totalTransactions} transactions this week.`);
  welcomeMessages.push(getRandomCalendarFact());
  welcomeMessages.push(`💸 You've spent ${formatINR(weekTotal)} this week.`);
  if (swiggyOrdersCount + zomatoOrdersCount <= 1) {
    welcomeMessages.push("🍽️ Almost no food orders – good control!");
  }



  // Extra insight
  // const todays = new Date();
  // const daysInMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate();
  // const dayOfMonth = todays.getDate();
  // const dailySpendingRate = currentMonth?.totalSpent / dayOfMonth;
  // const projectedSpending = dailySpendingRate * daysInMonth;
  
  // if (projectedSpending > budget) {
  //   const excess = projectedSpending - budget;
  //   insights.push(`At your current spending rate, you might exceed your budget by ${formatINR(excess.toFixed(0))} this month.`);
  // }

  if (today.getDate() <= 5) {
    insights.push(`Welcome to a new month! Let's make it a great one for your Pocket. 🚀`);
    if (subscriptions.length > 0) {
      const subscriptionNames = subscriptions.map(sub => sub.name).join(', ');
      const totalSubscriptions = subscriptions.reduce((sum, sub) => sum + sub.amount, 0);
      insights.push(`Don't forget about your subscriptions: ${subscriptionNames}. They total ₹${totalSubscriptions} this month.`);
    } else {
      insights.push(`You have no subscriptions this month. Great job managing recurring expenses!`);
    }
    // insights.push(`Your income is ${formatINR(income)}. Make sure your budget of ₹${budget} aligns with your financial goals.`);

    const savingsTarget = prevIncome * 0.1;
    insights.push(`Aim to save at least 10% of your income, which is ₹${formatINR(savingsTarget.toFixed(0))} of last month.`);
    const previousMonth = data?.previousMonth || 0;
    const spentCategories = Object.keys(previousMonth?.spent);
    const topTwoCategories = spentCategories.slice(0, 2);
    insights.push(`Look for ways to save this month. Can you reduce spending on ${topTwoCategories[0]} or ${topTwoCategories[1]}?`);
  }

  // 1. Snacks > ₹2500 after mid-month
  if (isMidMonth && snacksMonthly > 2500) {
    insights.push(
      `Whoa! ${formatINR(snacksMonthly)} on snacks this month? Your tummy might be happy, wallet not so much 😅`
    );
  }

  // 2. Fun budget 80% used
  // if (funSpent > funBudget * 0.8 && funBudget > 0) {
  //   insights.push(`Mid-month check: 80% of your fun budget gone already! 🎢`);
  // }

  // 3. Yesterday spent > two previous days
  if (yesterday > twoDaysAgo && yesterday > threeDaysAgo) {
    insights.push(`Looks like you’ve been swiping that card a bit too fast 🫣`);
  }

  // 4. Subscription active
  subscriptions.forEach((sub) => {
    if (sub.amount && sub.name) {
      insights.push(
        `Enjoying the ${sub.name} subscription so far? Still charging ${formatINR(sub.amount)}/month!`
      );
    }
  });

  // 5. Coffee spend > 8% of total weekly spend
  if (coffeeSpent / weekTotal > 0.08) {
    insights.push(
      `${formatINR(coffeeSpent)} on coffee this week – time for some home brews? ☕`
    );
  }

  // 6. Auto-renew alert
  const upcoming = subscriptions.filter((sub) => {
    const renewDate = new Date(sub.nextRenewalDate);
    const diff = (renewDate - today) / (1000 * 60 * 60 * 24);
    return diff > 0 && diff <= 7;
  });

  if (upcoming.length > 0) {
    insights.push(
      `Subscription alert: ${upcoming.length} renewals coming up next week!`
    );
  }

  // 7. Remaining budget only ₹500
  // if (remainingBudget <= 500 && budget > 0) {
  //   insights.push(
  //     `You’ve entered the danger zone – only ${formatINR(remainingBudget)} left in your monthly budget 😬`
  //   );
  //}

  // 8. Weekend spending > 150% of weekdays
  if (weekendSpending > 1.5 * weekdaySpending) {
    insights.push(
      `Your weekend spending is going wild – check yourself before you wreck yourself 🎉`
    );
  }

  // 9. Snacks > 12% of income
  if (snacksMonthly / income > 0.12) {
    insights.push(
      `If snacks were crypto, you’d be a millionaire. ${formatINR(snacksMonthly)} spent already 😅`
    );
  }

  // 10. Overspent budget
  // if (remainingBudget <= 0) {
  //   insights.push(`You’ve used up your budget cushion. Tread carefully now 🧘`);
  // }

  // 11. Big weekday spend alert
  if (yesterday / weekdaySpending > 0.35 && weekdaySpending > 0) {
    insights.push(`Is the weekend starting early? Spending spree alert 🚨`);
  }

  // 12. Dining out > 40% of weekly spend
  if (diningOut / weekTotal > 0.4) {
    insights.push(
      `${formatINR(diningOut)} on dining out this week? Maybe meal prep next time 🍱`
    );
  }

  // 13. More than 3 food deliveries in 2 days
  const totalFoodDeliveries = swiggyOrders + zomatoOrders + eatsureOrders;
  if (totalFoodDeliveries > 3) {
    insights.push(
      `Alert: ${totalFoodDeliveries} food deliveries in 2 days? Just checking 😬`
    );
  }

  const recentSpends = previousDays.slice(0, 2); 
  let countLargeTransactions = 0;

  recentSpends.forEach(day => {
     const spent = day.totalSpent || 0;
     // Assume this total includes multiple categories – split estimation
     // For simplicity, assume every ₹500+ counts as 1 spend instance (improvable if itemized data exists)
     if (spent >= 500) {
       countLargeTransactions++;
     }
   });
   if (countLargeTransactions > 3) {
     insights.push(`Alert: More than 3 individual transactions greater than ₹500 in the past 2 days. Keep an eye on your spending!`);
   }
   // 15. Platform loyalty insight
   const totalOrders = swiggyOrdersCount + zomatoOrdersCount;
   if (totalOrders > 0 && swiggyOrdersCount / totalOrders >= 0.8) {
     insights.push(`You're Team Swiggy – ${Math.round((swiggyOrdersCount / totalOrders) * 100)}% of your orders come from there 🛵`);
   }
   else if (totalOrders > 0 && zomatoOrdersCount / totalOrders >= 0.8) {
     insights.push(`You're Team Zomato – ${Math.round((zomatoOrdersCount / totalOrders) * 100)}% of your orders come from there 🍔`);
   }  else {
     insights.push(`No food delivery orders this week? Time to explore the kitchen! 🍽️`);
   }

  return { insights, welcomeMessages };
}

async function moneyMapMessages(newUserId) {
  const userId = new mongoose.Types.ObjectId(newUserId);
  // const userId = new ObjectId("67eff7ff91509235e7c790ee");

  // 1. Get transactions for the current month, week dates
  const { currentMonthEnd } = getCurrentMonthtRange();
  const { lastMonthStart } = getLastMonthRange();
  const { currentWeekStart, currentWeekEnd } = getCurrentWeekRange();  
  
  // 2. get transactions for the current month and week
  const currentMonthTransactions = await getCustomDatesTransactions(userId, lastMonthStart, currentMonthEnd);
  const currentWeekTransactions = await getCustomDatesTransactions(userId, currentWeekStart, currentWeekEnd);

  // 3. pass month and week transactions to moneymap function
  const getMonthlySummary = await getMonthlySummaryForMoneyMap(currentMonthTransactions);
  const getWeeklySummary = await getWeeklySummaryForMoneyMap(currentWeekTransactions);

  // logger.debug(`getMonthlySummary: ${getMonthlySummary}`);
  // logger.debug("getWeeklySummary: ", getWeeklySummary);

  const moneyMapData = {
    currentMonth: getMonthlySummary,
    previousMonth: getMonthlySummary.previousMonth,
    currentWeek: getWeeklySummary,
    previousDays: getMonthlySummary.previousDays,
    subscriptions: getMonthlySummary.subscriptions,
    income: getMonthlySummary.income,
    swiggyOrder: getMonthlySummary.swiggyOrder,
    zomatoOrder: getMonthlySummary.zomatoOrder,
    transactionsCount: getWeeklySummary.count
  };

  const {insights, welcomeMessages} = moneymap(moneyMapData);
 
 try {
    await MoneyMap.updateOne({ userId: userId }, {$set: {
      insights: insights,
      welcomeMessages: welcomeMessages,
      },
    }, { upsert: true });
  } catch (err) {
    logger.error(`Error fetching headsUp data: ${err}`);
  }
}

module.exports = moneyMapMessages;
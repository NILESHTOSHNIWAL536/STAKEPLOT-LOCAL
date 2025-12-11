// -------------------------------------------
// Types
// -------------------------------------------
export interface BudgetMap {
  [category: string]: number;
}

export interface SubcategoryBreakdown {
  name: string;
  amount: number;
}

export interface SpendingsMap {
  [category: string]: number | SubcategoryBreakdown[];
}

export type Insight = string;

// -------------------------------------------
// Category-specific tips
// -------------------------------------------
function getCategoryTip(category: string, excess: number, daysLeft: number): string {
  const tips: Record<string, string[]> = {
    Food: [`Try meal prepping to save ₹${Math.round(excess / 2)} over the next ${daysLeft} days.`, 'Skip takeout twice this week to get back on track.'],
    Transport: ['Carpool once to offset ₹50 daily.', 'Walk short trips to reduce costs.'],
    Entertainment: [`Opt for free events—₹${excess} could fund a bigger goal!`, 'Cut one outing to reset your budget.'],
  };

  const categoryTips = tips[category];
  if (!categoryTips) return `Review your ${category} habits to save ₹${excess}.`;

  return categoryTips[Math.floor(Math.random() * categoryTips.length)];
}

// -------------------------------------------
// Motivational message helper
// -------------------------------------------
function getMotivationalQuote(exceeded: number, within: number, total: number): string {
  if (exceeded === 0) return "Perfect! You're a budgeting pro!";
  if (within / total > 0.75) return "Strong performance! Tweak a bit and you'll nail it.";
  return 'Every step counts—keep pushing to master your budget!';
}

// -------------------------------------------
// Main Function
// -------------------------------------------
export function generateBudgetInsights(budget: BudgetMap, spendings: SpendingsMap, totalDays: number, daysElapsed: number): Insight[] {
  const insights: Insight[] = [];

  const categories = Object.keys(budget);

  let totalBudget = 0;
  let totalSpent = 0;

  const exceededCategories: Array<{
    category: string;
    excess: number;
    subcategories: string;
  }> = [];

  const withinBudgetCategories: Array<{
    category: string;
    remaining: number;
  }> = [];

  // ----------------------------
  // Category-wise analysis
  // ----------------------------
  categories.forEach((category) => {
    const budgetLimit = budget[category];
    const spentAmount = (spendings[category] as number) || 0;

    totalBudget += budgetLimit;
    totalSpent += spentAmount;

    if (spentAmount > budgetLimit) {
      const excess = Math.round(spentAmount - budgetLimit);

      const breakdown = spendings[`${category}_breakdown`] as SubcategoryBreakdown[] | undefined;
      const topSubcats = breakdown
        ? breakdown
            .sort((a, b) => b.amount - a.amount)
            .slice(0, 2)
            .map((s) => s.name)
        : [];

      exceededCategories.push({
        category,
        excess,
        subcategories: topSubcats.length > 0 ? topSubcats.join(' and ') : 'unspecified areas',
      });
    } else {
      const remaining = budgetLimit - spentAmount;
      withinBudgetCategories.push({ category, remaining });
    }
  });

  // ----------------------------
  // Spend rate analysis
  // ----------------------------
  const daysLeft = totalDays - daysElapsed;
  const spendingRate = daysElapsed > 0 ? totalSpent / daysElapsed : 0;
  const expectedRate = totalBudget / totalDays;
  const projectedTotal = spendingRate * totalDays;

  insights.push(`With ${daysLeft} days left in your ${totalDays}-day budget, here's how you're doing:`);

  if (spendingRate > expectedRate) {
    const excessProjection = Math.round(projectedTotal - totalBudget);
    insights.push(
      `You're spending faster than planned (₹${Math.round(spendingRate)}/day vs. ₹${Math.round(expectedRate)}/day). At this rate, you'll exceed by ₹${excessProjection}.`
    );
  } else if (spendingRate < expectedRate) {
    insights.push(`You're pacing well at ₹${Math.round(spendingRate)}/day—below your target of ₹${Math.round(expectedRate)}/day. Keep it up!`);
  } else {
    insights.push(`You're right on track, spending ₹${Math.round(spendingRate)}/day as planned.`);
  }

  // ----------------------------
  // Exceeded category analysis
  // ----------------------------
  if (exceededCategories.length > 0) {
    insights.push(`You have exceeded your budget in ${exceededCategories.length} out of ${categories.length} categories:`);

    exceededCategories.forEach(({ category, excess, subcategories }) => {
      const percentOver = ((excess / budget[category]) * 100).toFixed(1);
      const tip = getCategoryTip(category, excess, daysLeft);

      insights.push(`- ${category}: Over by ₹${excess} (${percentOver}%)${subcategories ? `, especially on ${subcategories}` : ''}. ${tip}`);
    });
  }

  // ----------------------------
  // Within-budget categories
  // ----------------------------
  if (withinBudgetCategories.length > 0 && daysLeft / totalDays < 0.25) {
    insights.push(`You are within budget in ${withinBudgetCategories.length} out of ${categories.length} categories:`);

    withinBudgetCategories.forEach(({ category, remaining }) => {
      const percentLeft = ((remaining / budget[category]) * 100).toFixed(1);
      if (Number(percentLeft) > 50) {
        insights.push(`- ${category}: ₹${remaining} left (${percentLeft}%). With few days left, consider saving this amount or reallocating it.`);
      } else {
        insights.push(`- ${category}: ₹${remaining} left. Keep up the good work!`);
      }
    });
  } else if (withinBudgetCategories.length > 0) {
    insights.push(`You are within budget in ${withinBudgetCategories.length} out of ${categories.length} categories. Great job!`);
  }

  // ----------------------------
  // Overall budget status
  // ----------------------------
  if (totalSpent > totalBudget) {
    const excess = Math.round(totalSpent - totalBudget);
    const savePerDay = daysLeft > 0 ? Math.ceil(excess / daysLeft) : 0;

    insights.push(`Overall, you have exceeded your total budget by ₹${excess}.`);

    if (daysLeft > 0) {
      insights.push(`To get back on track, aim to save ₹${savePerDay} each day for the next ${daysLeft} days.`);
    } else {
      insights.push(`Since the budget period is over, reflect on areas to improve next time.`);
    }
  } else if (totalSpent < totalBudget) {
    const remaining = Math.round(totalBudget - totalSpent);
    insights.push(`Overall, you are ₹${remaining} under your total budget. Excellent work! Consider allocating this to savings or a future goal.`);
  } else {
    insights.push('Overall, you have spent exactly your total budget.');

    if (exceededCategories.length === 0) {
      insights.push('And you stayed within all category budgets. Perfect!');
    } else {
      insights.push('However, you exceeded in some categories while saving in others. Aim for balance next time.');
    }
  }

  // ----------------------------
  // Random tip & motivational closing
  // ----------------------------
  const generalTips = [
    'Track your expenses daily to stay on top of your budget.',
    'Adjust your budget if you consistently overspend in certain categories.',
    'Small savings add up—look for ways to reduce non-essential spending.',
    'Use cash for discretionary purchases to make spending feel more tangible.',
    'Set aside time each week to review your budget and make adjustments.',
  ];

  insights.push(generalTips[Math.floor(Math.random() * generalTips.length)]);

  insights.push(getMotivationalQuote(exceededCategories.length, withinBudgetCategories.length, categories.length));

  return insights;
}

export default generateBudgetInsights;

// ============================================================
//  budget_assets.dart
//  ➜ Central registry for all images & category metadata.
//    Replace every 'assets/...' path with your real asset paths.
// ============================================================

// ---------- Illustration images used on creation steps ----------
const Map<String, String> budgetStepImages = {
  'addName':     'assets/budget/name.svg',     // woman writing on board
  'addAmount':   'assets/budget/amount.svg',   // man with calculator
  'selectDuration': 'assets/budget/durations.svg',  // woman with hourglass
  'addCategories':  'assets/budget/categorie.svgpub',// man arranging cards
};

// ---------- Illustration images used on list / detail screens ----------
const Map<String, String> budgetListImages = {
  'groceries': 'assets/images/budget/groceries.png',   // basket illustration
  'trip':      'assets/images/budget/trip.png',        // car / travel illustration
  'food':      'assets/images/budget/food_bowl.png',   // bowl / food illustration
  'vacation':  'assets/images/budget/vacation.png',    // suitcase travellers
  'default':   'assets/images/budget/default.png',
};

// ---------- Duration options ----------
const List<Map<String, dynamic>> budgetDurationOptions = [
  {'label': '14 days', 'value': 14},
  {'label': '30 days', 'value': 30},
  {'label': '45 days', 'value': 45},
  {'label': '60 days', 'value': 60},
];

// ---------- Category definitions ----------
// icon  → replace with real asset path (png / svg)
// color → hex string used for icon background tint
const List<Map<String, dynamic>> budgetCategories = [
  {
    'name':  'Food',
    'icon':  'assets/icons/categories/food.png',
    'color': '0xFF6B9BD2',
    'budgetPeriodKey': 'food',
  },
  {
    'name':  'Shopping',
    'icon':  'assets/icons/categories/shopping.png',
    'color': '0xFF9B8EC4',
    'budgetPeriodKey': 'shopping',
  },
  {
    'name':  'Travel',
    'icon':  'assets/icons/categories/travel.png',
    'color': '0xFF6BC4A6',
    'budgetPeriodKey': 'travel',
  },
  {
    'name':  'Health',
    'icon':  'assets/icons/categories/health.png',
    'color': '0xFFE07B7B',
    'budgetPeriodKey': 'health',
  },
  {
    'name':  'Events',
    'icon':  'assets/icons/categories/events.png',
    'color': '0xFFE0C06B',
    'budgetPeriodKey': 'events',
  },
  {
    'name':  'Personal Care',
    'icon':  'assets/icons/categories/personal_care.png',
    'color': '0xFFE09B6B',
    'budgetPeriodKey': 'personalCare',
  },
  {
    'name':  'Services',
    'icon':  'assets/icons/categories/services.png',
    'color': '0xFF7BA8E0',
    'budgetPeriodKey': 'services',
  },
  {
    'name':  "EMI's",
    'icon':  'assets/icons/categories/emi.png',
    'color': '0xFF9BE07B',
    'budgetPeriodKey': 'emi',
  },
  {
    'name':  'Groceries',
    'icon':  'assets/icons/categories/groceries.png',
    'color': '0xFF6BC4A6',
    'budgetPeriodKey': 'groceries',
  },
  {
    'name':  'Bills',
    'icon':  'assets/icons/categories/bills.png',
    'color': '0xFFD4A6E0',
    'budgetPeriodKey': 'bills',
  },
  {
    'name':  'Entertainment',
    'icon':  'assets/icons/categories/entertainment.png',
    'color': '0xFFE0D46B',
    'budgetPeriodKey': 'entertainment',
  },
  {
    'name':  'Education',
    'icon':  'assets/icons/categories/education.png',
    'color': '0xFF6B9BE0',
    'budgetPeriodKey': 'education',
  },
];

// ---------- Dummy budgets list (used while real API is wired) ----------
final List<Map<String, dynamic>> dummyBudgetList = [
  {
    '_id':          'b001',
    'name':         'Groceries Budget',
    'amount':       78251,
    'spent':        29735,
    'percentage':   38,
    'daysLeft':     14,
    'budgetPeriod': 'monthly',
    'createdAt':    '2025-03-01T00:00:00.000Z',
    'endDate':      '2025-03-31T00:00:00.000Z',
    'illustration': 'groceries',
    'categoryBudgets': [
      {'category': 'Food',     'amount': 20000, 'spent': 12000},
      {'category': 'Shopping', 'amount': 30000, 'spent': 10000},
      {'category': 'Travel',   'amount': 28251, 'spent': 7735},
    ],
  },
  {
    '_id':          'b002',
    'name':         'Trip Budget',
    'amount':       78251,
    'spent':        29735,
    'percentage':   38,
    'daysLeft':     14,
    'budgetPeriod': 'weekly',
    'createdAt':    '2025-03-01T00:00:00.000Z',
    'endDate':      '2025-03-07T00:00:00.000Z',
    'illustration': 'trip',
    'categoryBudgets': [
      {'category': 'Travel', 'amount': 50000, 'spent': 20000},
      {'category': 'Food',   'amount': 28251, 'spent': 9735},
    ],
  },
  {
    '_id':          'b003',
    'name':         'Food',
    'amount':       78251,
    'spent':        29735,
    'percentage':   38,
    'daysLeft':     14,
    'budgetPeriod': 'monthly',
    'createdAt':    '2025-03-01T00:00:00.000Z',
    'endDate':      '2025-03-31T00:00:00.000Z',
    'illustration': 'food',
    'categoryBudgets': [
      {'category': 'Food',    'amount': 50000, 'spent': 25000},
      {'category': 'Snacks',  'amount': 28251, 'spent': 4735},
    ],
  },
];

// ---------- Dummy weekly chart data ----------
final List<Map<String, dynamic>> dummyWeeklyChart = [
  {'day': 'Mon', 'amount': 3200.0},
  {'day': 'Tue', 'amount': 1800.0},
  {'day': 'Wed', 'amount': 7800.0},
  {'day': 'Thu', 'amount': 4500.0},
  {'day': 'Fri', 'amount': 6200.0},
  {'day': 'Sat', 'amount': 2900.0},
  {'day': 'Sun', 'amount': 1500.0},
];

module.exports = {
  User: require("./user-model"),

  // Models related to storing user's profile, fipRecords, summaries, transactions
  Account: require("./transactions-automation/account"),
  Bank: require("./transactions-automation/bank"),
  Profile: require("./transactions-automation/profile"),
  Summary: require("./transactions-automation/summary"),
  Transaction: require("./transactions-automation/transaction"),
  PendingTransaction: require("./pending-transactionmodel"),
  GroupedTransaction: require("./transactions-automation/grouped-transactions"),
  Finvu: require("./transactions-automation/finvu"),
  ConsentHandleId: require("./transactions-automation/consent-handle_model"),

  // TransactionRule
  TransactionRule: require("./transactions-automation/transactionRule"),

  PredictedCategories: require("./predicted-categories"),


  // Session for login/logout
  Session: require("./session-model"),

  // Models related to heads up and reminders
  HeadsUp: require("./messages/headsUp-model"),
  MoneyMap: require("./messages/moneymap-model"),


  CustomCategory: require("./transactions-automation/CustomCategory"),
  FailedTransaction: require("./transactions-automation/failedBankDetails"),

  // RecurringPayment model
  RecurringPayment: require('./transactions-automation/recurring-payment'),
  
  //user score activity
  FipsMetric : require("./fips-metric"),

  sendingNotification: require("./deviceNotifications"),
  UserActivity: require("./user-activity"),
  Notification: require("./notification-model"),
};

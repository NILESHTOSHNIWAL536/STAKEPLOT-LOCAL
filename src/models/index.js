module.exports = {
  User: require("./user-model"),
  Otp: require("./otp-model"),
  Icons: require("./icons-model"),
  Notification: require("./notification-model"),
  Split: require("./split-model"),

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

  //models related to posting content
  // Post: require("./post-model"),
  PostReport: require("./report-model"),
  Reply: require("./reply-model"),
  Upvote: require("./upvote-model"),
  Downvote: require("./downvote-model"),
  Comment: require("./comment-model"),
  Poll: require("./poll-model"),
  Chat: require("./chat-model"),
  sendingNotification: require("./deviceNotifications"),

  // Models related to debts, budgets, bills
  Debt: require("./debt-model"),
  Budget: require("./budget-model"),
  Bill: require("./bill-model"),


  // Session for login/logout
  Session: require("./session-model"),
  BankLogo: require("./transactions-automation/bank-logo"),

  // Models related to heads up and reminders
  HeadsUp: require("./messages/headsUp-model"),
  MoneyMap: require("./messages/moneymap-model"),

  //account delete model
  AccountDeletion: require("./account-deletion"),
  UserDeviceInfo: require("./user-device-modal"),
  UserDeviceInfoSummary: require("./device-info-summary"),
  CustomCategory: require("./transactions-automation/CustomCategory"),
  FailedTransaction: require("./transactions-automation/failedBankDetails"),

  // Notification tracker for lends/split
  notificationTracker: require("./notification-tracker/notification-tracker"),

  // New configured models
  WritePost: require("./posts/write-post"),
  PollPost: require("./posts/poll-post"),
  ImagePost: require("./posts/image-post"),
  ExploriaPost: require("./posts/exploria-post"),
  PostBase: require("./posts/post-base"),
  DeleteUser: require("./deleteUser-model"),

  // RecurringPayment model
  RecurringPayment: require('./transactions-automation/recurring-payment'),

  DeleteUser: require("./deleteUser-model"),
  
  //user score activity
  UserActivity : require("./user-activity"),
  FipsMetric : require("./fips-metric"),
  GoogleToken : require("./googleAuth"),
};

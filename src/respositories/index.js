module.exports = {

  TransactionRepository: require('./transaction-repository'),
  NotificationRepository: require('./notification-repository'),
  
  // UserProfileRepository: require("./autoTransactions-repositroy/userProfile"),
  AutoTransactionRepository: require('./autoTransactions-repository/transaction'),
  SummaryRepository: require("./autoTransactions-repositroy/summaries"),
  AccountRepository: require('./autoTransactions-repository/account'),
  FipRepository: require('./autoTransactions-repository/bank'),
  ProfileRespository: require('./autoTransactions-repository/profile'),
  SummaryRepository: require('./autoTransactions-repository/summary'),
  TransactionRepository: require("./autoTransactions-repositroy/transaction"),

};

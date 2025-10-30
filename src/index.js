module.exports = {

  TransactionRepository: require('./transaction-repository'),

  // Repositories related to posting content in the application
  PostRepository: require('./post-repository'),
  ReplyRepository: require('./reply-repository'),
  UpvoteRepository: require('./upvote-repository'),
  DownvoteRepository: require('./downvote-repository'),
  CommentRepository: require('./comment-repository'),

  // Repositories related to setting up user profile, fipRecords, Summaries, BankTransaction
  // UserProfileRepository: require("./autoTransactions-repositroy/userProfile"),
  AutoTransactionRepository: require('./autoTransactions-repository/transaction'),
  // SummaryRepository: require("./autoTransactions-repositroy/summaries"),
  AccountRepository: require('./autoTransactions-repository/account'),
  FipRepository: require('./autoTransactions-repository/bank'),
  ProfileRespository: require('./autoTransactions-repository/profile'),
  SummaryRepository: require('./autoTransactions-repository/summary'),


  // Repositories related to polls, chats
  PollRepository: require('./poll-repository'),
  ChatRepository: require('./chat-repository'),

  // Repositories related to debts, budgets, bills
  DebtRepository: require('./debt-repository'),
  BudgetRepository: require('./budget-repository'),
  BillRepository: require('./bill-repository'),
  SplitRepository: require('./split-repository'),

};

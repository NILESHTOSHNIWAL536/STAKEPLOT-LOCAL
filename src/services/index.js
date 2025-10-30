module.exports = {
  UserService: require('./user-service'),
  authService: require('./auth-service'),
  TransactionService: require('./transaction-service'),
  OtpService: require('./otp-service'),
  EncryptionService: require('./Encryption/encryption-service'),

  // Services related to posting content on the application
  PostService: require('./post-service'),
  ReplyService: require('./reply-service'),
  UpvoteService: require('./upvote-service'),
  DownvoteService: require('./downvote-service'),
  CommentService: require('./comment-service'),
  PollService: require('./poll-service'),
  ChatService: require('./chat-service'),
  CreditCardService: require('./credit-card-bank-service'),
  // EmailServiceHelper:require("./emailService"),
  // Services related to debts, budgets, bills
  DebtService: require('./debt-service'),
  BudgetService: require('./budget-service'),
  BillService: require('./bill-service'),
  SplitService: require('./split-service'),
  BankService: require('./bank-service'),
//   authService: require('./email-sync/email-token-auth'),
  pushNotificationService: require('./notification-service'),
};

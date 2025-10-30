
module.exports = {
  UserController: require("./user-controller"),
  TransactionController: require("./transaction-controller"),
  OtpController: require("./otp-controller"),
  CupertinoController: require("./cupertino-controller"),
  SplitController: require("./split-controller"),
  ReminderController: require("./reminder-controller"),
  RewardController: require("./reward-controller"),

  //Controllers related to posting content on the application
  PostController: require("./post-controller"),
  ReplyController: require("./reply-controller"),
  UpvoteController: require("./upvote-controller"),
  DownvoteController: require("./downvote-controller"),
  CommentController: require("./comment-controller"),
  PollController: require("./poll-controller"),
  ChatController: require("./chat-controller"),
  pushNotificationController: require("./notifications-controller"),

  //Controllers related to debts, budgets, bills
  DebtController: require("./debt-controller"),
  BudgetController: require("./budget-controller"),
  BillController: require("./bill-controller"),
  FinvuController: require("./finvu-controller"),
  constantController: require("./constant-controller"),
  DeviceController: require("./deviceInfo-controller"),
  CustomCategoryController: require("../controllers/transaction-automation/customCategoryController"),
};

import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

import '../routes/route_constant.dart';

class HomepageStringsDart {
  static final HomepageStringsDart _instance = HomepageStringsDart._internal();

  factory HomepageStringsDart() => _instance;

  HomepageStringsDart._internal();

  // Next fetch button labels
  String fetchingInProgress = "Hang tight! We're fetching the latest info for you.";
  String nextFetchLabel = "Next fetch on:";
  String noBankLinked = "Please link your bank account to fetch data.";
  String lastFetchLabel = "Last Fetch";
  String nextFetchTitle = "Next Fetch";
  String fetchCountTitle = "Fetch Count";
  String fetchLimitReached = "You have reached the maximum fetch limit.";
  String fetchPrompt = "Would you like to fetch again?";
  String fetchNowButton = "Yes, Fetch now";
  String notNowButton = "Not Now";
  String fetchingDuration = "Hang tight! Fetching will take ~10 minutes.";
  String notScheduled = "Not scheduled";
   List lockPatterns =  [
    "( ◐ o ◑ )",
    
    "(¬‿¬)",
    " (-‿◦)",
    
  ];

// Number picker screen
  String accountNumberLabel = "Acc No : ";
  String availableBalanceLabel = "Available balance";
  String setPinButton = "Set Pin";
  String resetCupertinoPin = "Reset Pin";
  String setLockTitle = "Set lock";
  String confirmButton = "Confirm";

   // Field labels from FinancePage and expanded page chart
  String spendingAndCashFlow = "Spending and cash flow";
  String lastWeek = "Last week";
  String thisMonth = "This month";
  String bankSpendings = "Bank Spendings";
  String month = "Month";
  String custom = "Custom";
  String noSpendingsAvailable = "No spendings available";
  String datePrefix = "Date: ";
  String creditedPrefix = "Credited: ";
  String debitedPrefix = "Debited: ";
  String detailedChartView = "Detailed Chart View";

// manual transaction
  String manualTransaction = "Manual Transaction";
  String cashIn = "Cash in";
  String cashOut = "Cash out";
  String manualTransactions = "Manual Transactions";
  String successfullyAdded = "Successfully Added";
  String enterAmount = "Enter amount";
  String selectCategory = "Select Category";
  String billSplit = "Bill Split";
  String lendMoney = "Lend money";
  String addButton = "Add";
  

  //spending categories
  String spendingsOnCategories = "Spendings on categories";
  String moreButton = "More";
  String allCategories = "All Categories";
  String noCategories = "No Spendings Available";


  //Finora;
  String finora = "FINORA";

 //headsup 
 String yourHighlights = "Your Highlights";
  String insightsError = "Failed to load insights. Please try again.";
  String moneyMapError = "Failed to load Money Map insights. Please try again.";
  String noHeadsUpInsights = "No Heads up insights available";
  String noMoneyMapInsights = "No Money Map insights available";
  String headsUp = "Heads up";
  String moneyMap = "Money Map";
  String retryButton = "Retry";

 // New strings from TransactionHistoryScreen
  String historyTitle = "Transactions";
  String selectTnx = "Select Transaction";
  String myStatement = "My Statement";
  String searchTransactions = "Search transactions";
  String tnxtodayview = "Today View";
  String allTnx = "All";
  String collectionscreate = "Collections";
  String noBankAccountLinked = "No Bank Account Linked Please link your bank account to download the statement.";

  // New strings from TransactionHistory
  String noTransactions = "No Transactions";
  String downloadStatement = "Download Statement";
  String thirtyDays = "30 days";
  String sixtyDays = "60 days";
  String sixMonths = "6 months";
  String dateFallback = "Date";

  // New strings from InsightsTransactionHistory (historyTransactions)
  String reviewLabel = "Review";
  String hideTransactionPrompt = "Do you want to hide this transaction?";
  String unhideTransactionPrompt = "Do you want to unhide this transaction?";
  String noButton = "No";
  String yesButton = "Yes";
  String hideTooltip = "Hide";
  String splitWithFriendsTooltip = "Split with Friends";
  String tagTooltip = "Tag";

   // New strings from NewFriendsUi
  String selectPeople = "Select people";
  String myFriends = "My friends";
  String searchLabel = "Search";
  String noFriendsAvailable = "No friends available";
  String selectAtLeastOneFriend = "Please select at least one friend";
  String provideLendDetails = "Please provide lend details";

  // New strings from AmountEntryModal
  String enterAmounts = "Enter Amounts";
  String currentTotal = "Current Total: ₹%s";
  String leftover = "Leftover: ₹%s";
  String settleLeftoverPrompt = "Click to split the leftover amount equally among all";
  String settleButton = "Settle";
  String invalidAmountError = "Invalid amount entered!";
  String noMembersSelectedError = "No members selected!";
  String authError = "Authentication error!";
  String splitAmountSent = "Split amount sent to users!";

  // New strings from LendDetailsModal
  String lendDetails = "Lend Details";
  String amountLabel = "Amount";
  String toLabel = "To";
  String messageLabel = "Message *";
  String dueDateLabel = "Due Date *";
  String selectDueDate = "Select a due date";
  String enterMessageError = "Please enter a message.";
  String selectDueDateError = "Please select a due date.";
  String messageHint = "e.g., Lunch at Cafe";
  String connectBankButton = "Connect Bank Account";
  String madeWithLove = "Made in India with ❤️";
  String creditcardSigninData = "We only fetch your bank credit card emails, nothing else. Your all other conversations stay completely private. Signing in just helps us pull those credit-related mails and neatly organize them here, so you can track your spends easily. Plus, we store only your credit card email data in encrypted form for security , and we don't save any other data.";
  Future<bool> fetchConstants() async {
    try {
      final response = await getDataApiCall(ConstantRoutes.homepage);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        data = data['data'] ?? {};
        creditcardSigninData = data['creditcardSigninData'] ?? creditcardSigninData;
        madeWithLove = data['madeWithLove'] ?? madeWithLove;
        fetchingInProgress = data['fetchingInProgress'] ?? fetchingInProgress;
        nextFetchLabel = data['nextFetchLabel'] ?? nextFetchLabel;
        lastFetchLabel = data['lastFetchLabel'] ?? lastFetchLabel;
        nextFetchTitle = data['nextFetchTitle'] ?? nextFetchTitle;
        fetchCountTitle = data['fetchCountTitle'] ?? fetchCountTitle;
        fetchLimitReached = data['fetchLimitReached'] ?? fetchLimitReached;
        fetchPrompt = data['fetchPrompt'] ?? fetchPrompt;
        fetchNowButton = data['fetchNowButton'] ?? fetchNowButton;
        notNowButton = data['notNowButton'] ?? notNowButton;
        fetchingDuration = data['fetchingDuration'] ?? fetchingDuration;
        notScheduled = data['notScheduled'] ?? notScheduled;
        noBankLinked = data['noBankLinked'] ?? noBankLinked;
        connectBankButton = data['connectBankButton'] ?? connectBankButton;
        lockPatterns =( data['lockPatterns']!=null && data['lockPatterns'] is List) ? data['lockPatterns'] : lockPatterns;
        
// number picker
accountNumberLabel = data['accountNumberLabel'] ?? accountNumberLabel;
         availableBalanceLabel = data['availableBalanceLabel'] ?? availableBalanceLabel;
        setPinButton = data['setPinButton'] ?? setPinButton;
        resetCupertinoPin = data['resetCupertinoPin'] ?? resetCupertinoPin;
        setLockTitle = data['setLock'] ?? setLockTitle;
        confirmButton = data['confirmButton'] ?? confirmButton;
// Finance page
         spendingAndCashFlow = data['spendingAndCashFlow'] ?? spendingAndCashFlow;
        lastWeek = data['lastWeek'] ?? lastWeek;
        thisMonth = data['thisMonth'] ?? thisMonth;
        bankSpendings = data['bankSpendings'] ?? bankSpendings;
        month = data['month'] ?? month;
        custom = data['custom'] ?? custom;
        noSpendingsAvailable = data['noSpendingsAvailable'] ?? noSpendingsAvailable;
        datePrefix = data['datePrefix'] ?? datePrefix;
        creditedPrefix = data['creditedPrefix'] ?? creditedPrefix;
        debitedPrefix = data['debitedPrefix'] ?? debitedPrefix;
        detailedChartView=data['detailedChartView'] ?? detailedChartView;

//manual transaction
        manualTransaction = data['manualTransaction'] ?? manualTransaction;
        cashIn = data['cashIn'] ?? cashIn;
        cashOut = data['cashOut'] ?? cashOut;
        manualTransactions = data['manualTransactions'] ?? manualTransactions;
        successfullyAdded = data['successfullyAdded'] ?? successfullyAdded;
        enterAmount = data['enterAmount'] ?? enterAmount;
        selectCategory = data['selectCategory'] ?? selectCategory;
        billSplit = data['billSplit'] ?? billSplit;
        lendMoney = data['lendMoney'] ?? lendMoney;
        addButton = data['addButton'] ?? addButton;
        

        //finora
        finora = data['finora'] ?? finora;


        // New strings from DoughnutChartExample
        spendingsOnCategories = data['spendingsOnCategories'] ?? spendingsOnCategories;
        moreButton = data['moreButton'] ?? moreButton;
        allCategories = data['allCategories'] ?? allCategories;
         noCategories = data['noCategories'] ?? noCategories;

        // New strings from InsightsScreen
        yourHighlights = data['yourHighlights'] ?? yourHighlights;
        insightsError = data['insightsError'] ?? insightsError;
        moneyMapError = data['moneyMapError'] ?? moneyMapError;
        noHeadsUpInsights = data['noHeadsUpInsights'] ?? noHeadsUpInsights;
        noMoneyMapInsights = data['noMoneyMapInsights'] ?? noMoneyMapInsights;
        headsUp = data['headsUp'] ?? headsUp;
        moneyMap = data['moneyMap'] ?? moneyMap;
        retryButton = data['retryButton'] ?? retryButton;

          // New strings from TransactionHistoryScreen
        historyTitle = data['historyTitle'] ?? historyTitle;
        selectTnx = data['selectTnx'] ?? selectTnx;
        myStatement = data['myStatement'] ?? myStatement;
        searchTransactions = data['searchTransactions'] ?? searchTransactions;
        tnxtodayview = data['tnxtodayview'] ?? tnxtodayview;
        allTnx = data['allTnx'] ?? allTnx;
        collectionscreate = data['collectionscreate'] ?? collectionscreate;
        noBankAccountLinked = data['noBankAccountLinked'] ?? noBankAccountLinked;

        // New strings from TransactionHistory
        noTransactions = data['noTransactions'] ?? noTransactions;
        downloadStatement = data['downloadStatement'] ?? downloadStatement;
        thirtyDays = data['thirtyDays'] ?? thirtyDays;
        sixtyDays = data['sixtyDays'] ?? sixtyDays;
        sixMonths = data['sixMonths'] ?? sixMonths;
        dateFallback = data['dateFallback'] ?? dateFallback;

        // New strings from InsightsTransactionHistory
        reviewLabel = data['reviewLabel'] ?? reviewLabel;
        hideTransactionPrompt = data['hideTransactionPrompt'] ?? hideTransactionPrompt;
        noButton = data['noButton'] ?? noButton;
        yesButton = data['yesButton'] ?? yesButton;
        hideTooltip = data['hideTooltip'] ?? hideTooltip;
        splitWithFriendsTooltip = data['splitWithFriendsTooltip'] ?? splitWithFriendsTooltip;
        tagTooltip = data['tagTooltip'] ?? tagTooltip;

          // New strings from NewFriendsUi
        selectPeople = data['selectPeople'] ?? selectPeople;
        myFriends = data['myFriends'] ?? myFriends;
        searchLabel = data['searchLabel'] ?? searchLabel;
        noFriendsAvailable = data['noFriendsAvailable'] ?? noFriendsAvailable;
        selectAtLeastOneFriend = data['selectAtLeastOneFriend'] ?? selectAtLeastOneFriend;
        provideLendDetails = data['provideLendDetails'] ?? provideLendDetails;

        // New strings from AmountEntryModal
        enterAmounts = data['enterAmounts'] ?? enterAmounts;
        currentTotal = data['currentTotal'] ?? currentTotal;
        leftover = data['leftover'] ?? leftover;
        settleLeftoverPrompt = data['settleLeftoverPrompt'] ?? settleLeftoverPrompt;
        settleButton = data['settleButton'] ?? settleButton;
        invalidAmountError = data['invalidAmountError'] ?? invalidAmountError;
        noMembersSelectedError = data['noMembersSelectedError'] ?? noMembersSelectedError;
        authError = data['authError'] ?? authError;
        splitAmountSent = data['splitAmountSent'] ?? splitAmountSent;

        // New strings from LendDetailsModal
        lendDetails = data['lendDetails'] ?? lendDetails;
        amountLabel = data['amountLabel'] ?? amountLabel;
        toLabel = data['toLabel'] ?? toLabel;
        messageLabel = data['messageLabel'] ?? messageLabel;
        dueDateLabel = data['dueDateLabel'] ?? dueDateLabel;
        selectDueDate = data['selectDueDate'] ?? selectDueDate;
        enterMessageError = data['enterMessageError'] ?? enterMessageError;
        selectDueDateError = data['selectDueDateError'] ?? selectDueDateError;
        messageHint = data['messageHint'] ?? messageHint;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  


}
import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class PlotFinanceStaticData {
  static final PlotFinanceStaticData _instance = PlotFinanceStaticData._internal();

  factory PlotFinanceStaticData() => _instance;

  PlotFinanceStaticData._internal();

  // PlotFinance
  String calculatorsTitle = "Calculators";

  // FinanceWidgets
  String addBudget = "Add Budget";
  String addDebt = "Add Debt";
  String foodieFunds = "FoodieFunds";
  String toReceive = "To Receive";
  String toPay = "To Pay";
  String pendingItems = "{count} pending";

  // CardBuilders - Debt Card
  String amountLabel = "Amount";
  String debtPrefix = "Debt: ";

  // CardBuilders - Budget Card
  String unnamedBudget = "Unnamed Budget";
  String unknownPeriod = "Unknown Period";
  String budgetPrefix = "Budget: ";
  String spentPrefix = "Spent: ";
  String percentageSpent = "{percentage}% Spent";

  // CardBuilders - Calculator Tile
  String creditCardPayoff = "Credit Card Payoff";
  String emiCalculator = "EMI";
  String rentVsBuy = "Rent vs Buy";
  String savingsGoal = "Savings goal";
  String autoLoan = "Auto loan";
  String tripCost = "Trip cost";
  String calculatorSubtitle = "Calculator";
  String spent = "spent";
  String remaining = "Remaining";


  // CreateDebtScreen - Form Fields
  String createDebtTitle = "Create Debt";
  String enterDebtName = "Enter Debt Name";
  String selectLoanType = "Select Loan Type";
  String enterDebtAmount = "Enter Debt Amount";
  String enterInterestRate = "Enter Interest Rate";
  String enterDurationMonths = "Enter Duration (Months)";
  String selectDate = "Select Date";
  String validateName = "Please enter a valid debt name";
  String validateLoanType = "Please select a loan type";
  String validateAmount = "Please enter an amount";
  String validateNumeric = "Please enter a valid number";
  String validateInterest = "Please enter an interest rate";
  String enterDuration = "Enter Duration (months)";
  String validateDuration = "Please enter duration";
  String validateDate = "Please select a date";

  // CreateDebtScreen - Loan Types
  String loanType = "Personal Loan";
  String homeLoan = "Home Loan";
  String loanAgainstProperty = "Loan Against Property (LAP)";
  String vehicleLoan = "Vehicle Loan";
  String creditCardLoan = "Credit-Card Loan";
  String goldLoan = "Gold Loan";
  String mortgageLoan = "Mortgage Loan";
  String educationLoan = "Education Loan";
  String businessLoan = "Business Loan";
  String studentLoan = "Student Loan";
  String otherLoan = "Other Loan";

  // CreateDebtScreen - Button and SnackBar
  String continueButton = "Continue";
  String debtCreatedSuccess = "Debt created successfully!";

  // DebtDetailsScreen
  String deleteDebtTitle = "Delete Debt";
  String deleteDebtPrompt = "Are you sure you want to delete this debt?";
  String cancelButton = "Cancel";
  String deleteButton = "Delete";
  String loanTypeLabel = "Loan Type";
  String interestLabel = "Interest";
  String durationLabel = "Duration";
  String dateLabel = "Date";

    // MyBudgetScreen - AppBar and Dialog
  String deleteBudgetTitle = "Delete Budget";
  String deleteBudgetPrompt = "Are you sure you want to delete this budget?";
  String budgetDeletedSuccess = "Budget deleted successfully";
  String budgetDeletedFailed = "Failed to delete budget";

  // MyBudgetScreen - UI Elements
  String budgetTitle="My Budget";
  String daysRemaining = "Days remaining: {days} days";
  String budgetAmountLabel = "Budget amount";
  String amountSpentLabel = "Amount spent";
  String overSpentLabel = "Over spent";
  String noSpendingData = "No spending data available";
  String budgetSpendingTitle = "Budget Spending";
  String insightsTitle = "Insights";
  String noInsightsAvailable = "No insights available";

  // BudgetSearch - UI Elements
  String chooseCategoryTitle = "Choose category(s)";
  String curatedCategoriesText = "After analyzing your expenses,\nwe have curated some categories for you!";
  String searchCategoryHint = "Search for category";
  String noCategoriesFound = "No categories found";

  // BudgetOverView - UI Elements
  String budgetOverviewTitle = "Budget Overview";
  String totalAmountLabel = "Total Amount";
  String estimationLabel = "Estimation";
  String addBudgetButton = "Add Budget";
  String enterAmountHint = "Enter amount";
  String amountExceedsBudget = "Amount exceeds budget";
  String amountExceedsTotalBudget = "Amount exceeds the total budget!";

  // Budget - UI Elements
  String budgetPlannerTitle = "Budget Planner";
  String budgetPlannerDescription = "Plan and manage your budget effectively";
  String nameLabel = "Name";
  String enterBudgetNameHint = "Enter budget name";
  String amountLabelBudget = "Amount";
  String enterAmountHintBudget = "Enter amount";
  String durationLabel2 = "Duration";
  String weeklyPeriod = "Weekly";
  String monthlyPeriod = "Monthly";
  String yearlyPeriod = "Yearly";
  String validateAllFields = "Please Enter All Fields";

    String foodieFundsTitle = "FoodieFunds";

  // VegNonVegCalculator - Input Labels
  String vegLabel = "Veg";
  String nonVegLabel = "Non veg";
  String alcoholLabel = "Alcohol";
  String searchHint = "Search";

  // VegNonVegCalculator - Button Labels
  String billSplitButton = "Bill Split";
  String notifyButton = "Notify";
  String calculateButton = "Calculate";

  // VegNonVegCalculator - UI Elements
  String noFriendsAvailable = "No friends available";

  Future<bool> fetchConstants() async {
    try {
      final response = await getDataApiCall("$url/constant/plotfinance");
      printData(response);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        data = data['data'] ?? {};

        // PlotFinance
        calculatorsTitle = data['calculatorsTitle'] ?? calculatorsTitle;

        // FinanceWidgets
        addBudget = data['addBudget'] ?? addBudget;
        addDebt = data['addDebt'] ?? addDebt;
        foodieFunds = data['foodieFunds'] ?? foodieFunds;
        toReceive = data['toReceive'] ?? toReceive;
        toPay = data['toPay'] ?? toPay;
        pendingItems = data['pendingItems'] ?? pendingItems;

        // CardBuilders - Debt Card
        amountLabel = data['amountLabel'] ?? amountLabel;
        debtPrefix = data['debtPrefix'] ?? debtPrefix;

        // CardBuilders - Budget Card
        unnamedBudget = data['unnamedBudget'] ?? unnamedBudget;
        unknownPeriod = data['unknownPeriod'] ?? unknownPeriod;
        budgetPrefix = data['budgetPrefix'] ?? budgetPrefix;
        spentPrefix = data['spentPrefix'] ?? spentPrefix;
        percentageSpent = data['percentageSpent'] ?? percentageSpent;

        // CardBuilders - Calculator Tile
        creditCardPayoff = data['creditCardPayoff'] ?? creditCardPayoff;
        emiCalculator = data['emiCalculator'] ?? emiCalculator;
        rentVsBuy = data['rentVsBuy'] ?? rentVsBuy;
        savingsGoal = data['savingsGoal'] ?? savingsGoal;
        autoLoan = data['autoLoan'] ?? autoLoan;
        tripCost = data['tripCost'] ?? tripCost;
        calculatorSubtitle = data['calculatorSubtitle'] ?? calculatorSubtitle;
        spent = data['spent'] ?? spent;
        remaining = data['remaining'] ?? remaining;

        // CreateDebtScreen - Form Fields
        createDebtTitle = data['createDebtTitle'] ?? createDebtTitle;
        enterDebtName = data['enterDebtName'] ?? enterDebtName;
        selectLoanType = data['selectLoanType'] ?? selectLoanType;
        enterDebtAmount = data['enterDebtAmount'] ?? enterDebtAmount;
        enterInterestRate = data['enterInterestRate'] ?? enterInterestRate;
        enterDurationMonths = data['enterDurationMonths'] ?? enterDurationMonths;
        selectDate = data['selectDate'] ?? selectDate;
        validateName = data['validateName'] ?? validateName;
        validateLoanType = data['validateLoanType'] ?? validateLoanType;
        validateAmount = data['validateAmount'] ?? validateAmount;
        validateNumeric = data['validateNumeric'] ?? validateNumeric;
        validateInterest = data['validateInterest'] ?? validateInterest;
        enterDuration = data['enterDuration'] ?? enterDuration;
        validateDuration = data['validateDuration'] ?? validateDuration;
        validateDate = data['validateDate'] ?? validateDate;

        // CreateDebtScreen - Loan Types
        loanType = data['loanType'] ?? loanType;
        homeLoan = data['homeLoan'] ?? homeLoan;
        loanAgainstProperty = data['loanAgainstProperty'] ?? loanAgainstProperty;
        vehicleLoan = data['vehicleLoan'] ?? vehicleLoan;
        creditCardLoan = data['creditCardLoan'] ?? creditCardLoan;
        goldLoan = data['goldLoan'] ?? goldLoan;
        mortgageLoan = data['mortgageLoan'] ?? mortgageLoan;
        educationLoan = data['educationLoan'] ?? educationLoan;
        businessLoan = data['businessLoan'] ?? businessLoan;
        studentLoan = data['studentLoan'] ?? studentLoan;
        otherLoan = data['otherLoan'] ?? otherLoan;

        // CreateDebtScreen - Button and SnackBar
        continueButton = data['continueButton'] ?? continueButton;
        debtCreatedSuccess = data['debtCreatedSuccess'] ?? debtCreatedSuccess;

        // DebtDetailsScreen
        deleteDebtTitle = data['deleteDebtTitle'] ?? deleteDebtTitle;
        deleteDebtPrompt = data['deleteDebtPrompt'] ?? deleteDebtPrompt;
        cancelButton = data['cancelButton'] ?? cancelButton;
        deleteButton = data['deleteButton'] ?? deleteButton;
        loanTypeLabel = data['loanTypeLabel'] ?? loanTypeLabel;
        interestLabel = data['interestLabel'] ?? interestLabel;
        durationLabel = data['durationLabel'] ?? durationLabel;
        dateLabel = data['dateLabel'] ?? dateLabel;
 // MyBudgetScreen
  budgetTitle = data['budgetTitle'] ?? budgetTitle;
        deleteBudgetTitle = data['deleteBudgetTitle'] ?? deleteBudgetTitle;
        deleteBudgetPrompt = data['deleteBudgetPrompt'] ?? deleteBudgetPrompt;
        budgetDeletedSuccess = data['budgetDeletedSuccess'] ?? budgetDeletedSuccess;
        budgetDeletedFailed = data['budgetDeletedFailed'] ?? budgetDeletedFailed;
        daysRemaining = data['daysRemaining'] ?? daysRemaining;
        budgetAmountLabel = data['budgetAmountLabel'] ?? budgetAmountLabel;
        amountSpentLabel = data['amountSpentLabel'] ?? amountSpentLabel;
        overSpentLabel = data['overSpentLabel'] ?? overSpentLabel;
        noSpendingData = data['noSpendingData'] ?? noSpendingData;
        budgetSpendingTitle = data['budgetSpendingTitle'] ?? budgetSpendingTitle;
        insightsTitle = data['insightsTitle'] ?? insightsTitle;
        noInsightsAvailable = data['noInsightsAvailable'] ?? noInsightsAvailable;

        // BudgetSearch
        chooseCategoryTitle = data['chooseCategoryTitle'] ?? chooseCategoryTitle;
        curatedCategoriesText = data['curatedCategoriesText'] ?? curatedCategoriesText;
        searchCategoryHint = data['searchCategoryHint'] ?? searchCategoryHint;
        noCategoriesFound = data['noCategoriesFound'] ?? noCategoriesFound;

        // BudgetOverView
        budgetOverviewTitle = data['budgetOverviewTitle'] ?? budgetOverviewTitle;
        totalAmountLabel = data['totalAmountLabel'] ?? totalAmountLabel;
        estimationLabel = data['estimationLabel'] ?? estimationLabel;
        addBudgetButton = data['addBudgetButton'] ?? addBudgetButton;
        enterAmountHint = data['enterAmountHint'] ?? enterAmountHint;
        amountExceedsBudget = data['amountExceedsBudget'] ?? amountExceedsBudget;
        amountExceedsTotalBudget = data['amountExceedsTotalBudget'] ?? amountExceedsTotalBudget;

        // Budget
        budgetPlannerTitle = data['budgetPlannerTitle'] ?? budgetPlannerTitle;
        budgetPlannerDescription = data['budgetPlannerDescription'] ?? budgetPlannerDescription;
        nameLabel = data['nameLabel'] ?? nameLabel;
        enterBudgetNameHint = data['enterBudgetNameHint'] ?? enterBudgetNameHint;
        amountLabelBudget = data['amountLabelBudget'] ?? amountLabelBudget;
        enterAmountHintBudget = data['enterAmountHintBudget'] ?? enterAmountHintBudget;
        durationLabel2 = data['durationLabel2'] ?? durationLabel2;
        weeklyPeriod = data['weeklyPeriod'] ?? weeklyPeriod;
        monthlyPeriod = data['monthlyPeriod'] ?? monthlyPeriod;
        yearlyPeriod = data['yearlyPeriod'] ?? yearlyPeriod;
        validateAllFields = data['validateAllFields'] ?? validateAllFields;

         foodieFundsTitle = data['foodieFundsTitle'] ?? foodieFundsTitle;
        vegLabel = data['veg'] ?? vegLabel;
        nonVegLabel = data['nonVegLabel'] ?? nonVegLabel;
        alcoholLabel = data['alcoholLabel'] ?? alcoholLabel;
        searchHint = data['searchHint'] ?? searchHint;
        billSplitButton = data['billSplitButton'] ?? billSplitButton;
        notifyButton = data['notifyButton'] ?? notifyButton;
        calculateButton = data['calculateButton'] ?? calculateButton;
        noFriendsAvailable = data['noFriendsAvailable'] ?? noFriendsAvailable;
       
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
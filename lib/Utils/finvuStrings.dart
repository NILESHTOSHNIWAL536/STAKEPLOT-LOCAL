import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

import '../routes/route_constant.dart';

class FinvuStrings {
  // 1. Static instance
  static final FinvuStrings _instance = FinvuStrings._internal();

  // 2. Private constructor
  FinvuStrings._internal();

  // 3. Factory constructor
  factory FinvuStrings() => _instance;

  // ✅ Field labels (for ShareAccountLogin)
  String transformMoneyHabits = "Transform your money habits";
  String withStakeplot = "with stakeplot";
  String financialSuccessJourney =
      "Fuel Your Dreams.Fuel Your Wallet:Your Journey To Financial Success Starts Here";
  String startNow = "Start now";
  String connectBankAccounts = "Connect your bank accounts using AA services";
  String whatAreAccountAggregators = "What are Account Aggregators?";
  String accountAggregatorsDescription =
      "Account Aggregators are RBI-authorized institutions that securely collect and share your financial information with us.";
  String secureQuickSharing = "Secure & Quick Sharing";
  String viaRbiAuthorised = "via RBI-authorised Account Aggregator Services";
  String budgeting = "Budgeting";
  String management = "Management";
  String growth = "Growth";
  String community = "Community";

  // ✅ Field labels (for MobileNumber and snippets)
  String linkedAccount = "Linked Account";
  String enterText = "Enter text";
  String verifyAndLink = "Verify And Link";
  String otpVerification = "OTP Verification";
  String finvuOtpMessage = "Finvu will send an OTP to your mobile number.";
  String enter10DigitNumber = "Enter 10 digit Number";
  String continueButton = "Continue";
  String termsAndConditionsAgreement =
      "By clicking continue, you agree to Finvu's ";
  String termsAndConditions = "Terms & Conditions";
  String registerWithFinvu = "Register with Finvu to start sharing";
  String enterOtpSentTo = "Enter the OTP sent to"; // Used with phone number
  String verify = "Verify";
  String incorrectOtp = "Incorrect OTP entered";
  String didntReceiveOtp = "Didn't you receive the OTP?  ";
  String resendOtp = "Resend OTP";
  String resendInSeconds = "Resend in"; // Used with countdown

  // ✅ Field labels (for showSkipModal2)
  String skipModalTitle =
      "Are you sure you want to stop the process of linking your account(s) with Finvu?";
  String cancel = "Cancel";
  String yes = "Yes";

  // ✅ Validation/Error Messages
  String enterValidMobile = "Please enter a valid 10-digit mobile number.";
  String errorGeneratingOtp = "Error generating OTP. Please try again.";
  String enterOtpLength = "Please enter a valid OTP.";

  // ✅ Field labels (from new snippets)
  String selectAccountsToShare = "Select accounts to share";
  String authorise = "Authorise";
  String bankAccountsShared = "Bank Accounts are shared"; // Used with count
  String fetchAccountTransactions = "We will fetch this account transactions";
  String bankAccounts = "Bank Accounts";
  String accountsDiscovered = "accounts discovered"; // Used with count
  String selectAtLeastOneAccount = "Select at least 1 Account to share from";
  String securelyAuthorize = "Securely authorize each selected account";
  String enterOtp = "Enter OTP";
  String shared = "Shared";
  String linked = "Linked";
  String linkNow = "Link Now";
  String checkNow = "check Now";
  String fetchBankTransactions = "Fetch Bank Transactions";
  String bankAccount = "Bank Account";
  String approveConsent = "Approve consent";
  String fetchData = "Fetch Data";
  String dataFetchedSuccessfully = "Data is Fetched successfully....";
  String waitingForBankResponse = "waiting for response from bank.....";
  String pickAtLeastOne = "Pick atleast one to proceed";
  String searchForBanks = "Search for banks";
  String poweredByRbi = "Powered by RBI-Regulated AA";

  // ✅ Field labels (from Access class)
  String givePermission = "Give Permission";
  String shareAccountsWithStakeplot = "To share your accounts with Stake for ";
  String smartFinanceInsights = "Smart finance management & insights.";
  String accountsSharedTitle = "Accounts Shared";
  String accountsSharedValue = "Account(s) are shared"; // Used with count
  String permissionValidity = "Permission Validity";
  String frequencyOfAccess = "Frequency of Access";
  String frequencyOfAccessSubText = "We can access your information one-time.";
  String viewMoreDetails = "View More Details";
  String approvalRequestedOn = "Approval Requested on";
  String purpose = "Purpose";
  String accountDetails = "Account Details";
  String profileSummaryTransactions = "Profile, Summary, Transactions";
  String dataLife = "Data life";
  String approvalExpiry = "Approval Expiry";
  String accountTypes = "Account Types";
  String pauseOrCancelSharing =
      "You can pause or cancel sharing anytime via your Finvu app.";
  String decline = "Decline";
  String areYouSure = "Are you sure?";
  String declineConfirmation = "Do you really want to decline?";
  String no = "No";
  String viewMore = "View More";
  String linkedBankAccount = "Linked Bank Account";

  // ✅ Validation/Error Messages
  
  String enterValidOtp = "Please enter a valid OTP";

  Future<bool> fetchConstants() async {
    try {
      final response = await getDataApiCall(ConstantRoutes.finvu);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        data = data['data'] ?? {};
        // ShareAccountLogin strings
        transformMoneyHabits = data['transformMoneyHabits'] ?? transformMoneyHabits;
        withStakeplot = data['withStakeplot'] ?? withStakeplot;
        financialSuccessJourney = data['financialSuccessJourney'] ?? financialSuccessJourney;
        startNow = data['startNow'] ?? startNow;
        connectBankAccounts = data['connectBankAccounts'] ?? connectBankAccounts;
        whatAreAccountAggregators = data['whatAreAccountAggregators'] ?? whatAreAccountAggregators;
        accountAggregatorsDescription =
            data['accountAggregatorsDescription'] ?? accountAggregatorsDescription;
        secureQuickSharing = data['secureQuickSharing'] ?? secureQuickSharing;
        viaRbiAuthorised = data['viaRbiAuthorised'] ?? viaRbiAuthorised;
        budgeting = data['budgeting'] ?? budgeting;
        management = data['management'] ?? management;
        growth = data['growth'] ?? growth;
        community = data['community'] ?? community;
        // MobileNumber and snippets strings
        linkedAccount = data['linkedAccount'] ?? linkedAccount;
        enterText = data['enterText'] ?? enterText;
        verifyAndLink = data['verifyAndLink'] ?? verifyAndLink;
        otpVerification = data['otpVerification'] ?? otpVerification;
        finvuOtpMessage = data['finvuOtpMessage'] ?? finvuOtpMessage;
        enter10DigitNumber = data['enter10DigitNumber'] ?? enter10DigitNumber;
        continueButton = data['continueButton'] ?? continueButton;
        termsAndConditionsAgreement = data['termsAndConditionsAgreement'] ?? termsAndConditionsAgreement;
        termsAndConditions = data['termsAndConditions'] ?? termsAndConditions;
        registerWithFinvu = data['registerWithFinvu'] ?? registerWithFinvu;
        enterOtpSentTo = data['enterOtpSentTo'] ?? enterOtpSentTo;
        verify = data['verify'] ?? verify;
        incorrectOtp = data['incorrectOtp'] ?? incorrectOtp;
        didntReceiveOtp = data['didntReceiveOtp'] ?? didntReceiveOtp;
        resendOtp = data['resendOtp'] ?? resendOtp;
        resendInSeconds = data['resendInSeconds'] ?? resendInSeconds;
        // showSkipModal2 strings
        skipModalTitle = data['skipModalTitle'] ?? skipModalTitle;
        cancel = data['cancel'] ?? cancel;
        yes = data['yes'] ?? yes;
        // Validation/Error Messages
        enterValidMobile = data['enterValidMobile'] ?? enterValidMobile;
        errorGeneratingOtp = data['errorGeneratingOtp'] ?? errorGeneratingOtp;
        enterOtpLength = data['enterOtpLength'] ?? enterOtpLength;
        // New snippets strings
        selectAccountsToShare = data['selectAccountsToShare'] ?? selectAccountsToShare;
        authorise = data['authorise'] ?? authorise;
        bankAccountsShared = data['bankAccountsShared'] ?? bankAccountsShared;
        fetchAccountTransactions = data['fetchAccountTransactions'] ?? fetchAccountTransactions;
        bankAccounts = data['bankAccounts'] ?? bankAccounts;
        accountsDiscovered = data['accountsDiscovered'] ?? accountsDiscovered;
        selectAtLeastOneAccount = data['selectAtLeastOneAccount'] ?? selectAtLeastOneAccount;
        securelyAuthorize = data['securelyAuthorize'] ?? securelyAuthorize;
        enterOtp = data['enterOtp'] ?? enterOtp;
        shared = data['shared'] ?? shared;
        linked = data['linked'] ?? linked;
        linkNow = data['linkNow'] ?? linkNow;
        checkNow = data['checkNow'] ?? checkNow;
        fetchBankTransactions = data['fetchBankTransactions'] ?? fetchBankTransactions;
        bankAccount = data['bankAccount'] ?? bankAccount;
        approveConsent = data['approveConsent'] ?? approveConsent;
        fetchData = data['fetchData'] ?? fetchData;
        dataFetchedSuccessfully = data['dataFetchedSuccessfully'] ?? dataFetchedSuccessfully;
        waitingForBankResponse = data['waitingForBankResponse'] ?? waitingForBankResponse;
        pickAtLeastOne = data['pickAtLeastOne'] ?? pickAtLeastOne;
        searchForBanks = data['searchForBanks'] ?? searchForBanks;
        poweredByRbi = data['poweredByRbi'] ?? poweredByRbi;
 // Access class strings
        givePermission = data['givePermission'] ?? givePermission;
        shareAccountsWithStakeplot = data['shareAccountsWithStakeplot'] ?? shareAccountsWithStakeplot;
        smartFinanceInsights = data['smartFinanceInsights'] ?? smartFinanceInsights;
        accountsSharedTitle = data['accountsSharedTitle'] ?? accountsSharedTitle;
        accountsSharedValue = data['accountsSharedValue'] ?? accountsSharedValue;
        permissionValidity = data['permissionValidity'] ?? permissionValidity;
        frequencyOfAccess = data['frequencyOfAccess'] ?? frequencyOfAccess;
        frequencyOfAccessSubText=data['frequencyOfAccessSubText'] ?? frequencyOfAccessSubText;
        viewMoreDetails = data['viewMoreDetails'] ?? viewMoreDetails;
        approvalRequestedOn = data['approvalRequestedOn'] ?? approvalRequestedOn;
        purpose = data['purpose'] ?? purpose;
        accountDetails = data['accountDetails'] ?? accountDetails;
        profileSummaryTransactions = data['profileSummaryTransactions'] ?? profileSummaryTransactions;
        dataLife = data['dataLife'] ?? dataLife;
        approvalExpiry = data['approvalExpiry'] ?? approvalExpiry;
        accountTypes = data['accountTypes'] ?? accountTypes;
        pauseOrCancelSharing = data['pauseOrCancelSharing'] ?? pauseOrCancelSharing;
        decline = data['decline'] ?? decline;
        areYouSure = data['areYouSure'] ?? areYouSure;
        declineConfirmation = data['declineConfirmation'] ?? declineConfirmation;
        no = data['no'] ?? no;
        viewMore = data['viewMore'] ?? viewMore;
        linkedBankAccount = data['linkedBankAccount'] ?? linkedBankAccount;

        // Validation/Error Messages
       
        enterValidOtp = data['enterValidOtp'] ?? enterValidOtp;

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
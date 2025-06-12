import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
class SnackbarData {
  static final SnackbarData _instance = SnackbarData._internal();

  SnackbarData._internal();

  factory SnackbarData() => _instance;

  // Snackbar Messages
  String remainder = "Reminder sent successfully!";
  String remainderError = "Error: Reminder not found.";
  String paymentsInit = "Payment request has been initiated!";
  String paymentsError = "Error: Payment not found.";
  String enterValidemail = "Please enter a valid email address.";
  String enterValidMobile = "Please enter valid mobile number";
  String errorGeneratingOtp = "Error while generating otp Ref / or internal issue";
  String enterOtpLength = "Please enter OTP of length 6";
  String pickOneBank = "Pick at least one bank to proceed";
  String accountAdded = "The account has been successfully added for linking.";
  String maxRetries = "Maximum Retries Exceeded. Please try again after sometime.";
  String enterValidOtp = "Enter valid otp";
  String bankLinkedSuccess = "Linked Bank account Successfully...";
  String consentApproveError = "An error occurred while approving the consent request.";
  String consentApproved = "Consent request approved successfully.";
  String consentDeclined = "Successfully decline the consent request.";
  String consentDisapproveError = "Unable to disapprove the request.";


String validAmountAndShares = "Please add a valid amount and ensure shares are selected.";
String noSharesCalculated = "No shares calculated yet. Please calculate the bill first.";
String userIdNotAvailable = "User ID is not available. Please try again.";
String userNameNotAvailable = "User name is not available. Please try again.";
String noFriendsToNotify = "No friends to notify. Please add friends to the split.";
String noValidSharesToNotify = "No valid shares to notify. Ensure amounts are calculated.";
String failedToSendNotification = "Failed to send notification to user";
String invalidShareAmount = "Invalid share amount for user";
String noNotificationsSent = "No notifications sent due to invalid data.";


  // Additional Messages
  String categoryAdded = "Category Added Successfully";
  String transactionAddFail = "Failed to add transaction!";
  String transactionSuccess = "Transaction has been successfully Added!";
  String addingFriend = "Adding user as a friend...!";
  String addFriendFail = "Unable to add friend!";
  String friendRejected = "Unfortunately, your friend request has been rejected.";
  String sendingRequest = "Sending friend request..";
  String requestAddFail = "Can't add request!";
  String requestRemoved = "Friend request has been successfully removed!";
  String requestRemoveFail = "Unable to remove request!";
  String friendRemoved = "Friend has been successfully removed Friend!";
  String noTransactionData = "No transaction data available";
  String pinSetFail00 = "Unable to set the PIN 00 except 00 try other!";
  String pinSetSuccess = "Your PIN has been set successfully!";
  String pinSetFail = "Unable to set the PIN!";
  String maxLimitSetFail = "Attempted to set a maximum limit, but it failed. Please Reset Pin.";
  String otpAccepted = "OTP Accepted!";
  String otpInvalid = "Invalid OTP!";
  String passwordChanged = "Password changed!";
  String passwordChangeFail = "Can't change!";
  String otpResent = "Resent Otp To Email Id!";
  String otpSendFail1 = "Can't send otp!";
  String otpResentSuccess = "OTP has been resent to your email!";
  String otpSendFail2 = "Unable to send OTP, Please try again";


   // Budget, Debt, Bills, Payments
  String budgetAdded = "You have successfully added a new budget!";
  String budgetAddFailed = "Failed to add the budget!";
  String budgetUpdated = "Your budget has been updated successfully!";
  String budgetUpdateFailed = "Unable to update the budget!";
  String processingBudgetDeletion = "Processing budget deletion...";
  String budgetDeletionError = "Error occurred while deleting the budget!";
  String budgetDeletionSuccess = "Budget deleted successfully";
String budgetAmountMismatch = "Total amount is not equal to the sum of all category-wise amounts.";


  String debtAdded = "Debt has been successfully added!";
  String debtAddFailed = "Failed to add the debt!";
  String debtCleared = "Debts have been cleared!";
  String debtClearError = "An error occurred while closing the debts!";
  String allDebtsCleared = "All debts for this month have been cleared!";
  String debterror = "can't clear debts!";
  String debtUpdateError = "An error occurred during the update!";

  String billAdded = "Bill has been successfully added!";
  String billAddFailed = "Unable to add the bill!";

  String paymentAdded = "Payment has been successfully added!";
  String paymentAddFailed = "Unable to add the payment!";
  String offReplays = "user restricted to messge";


  // posts
  String unableToAddReply = "Unable to add reply.";
  String deletedPost = "Deleted Post";
  String errorWhileDeletingPost = "Error while Deleting Post...";
  String imageUploadFailed = "Image upload failed";
  String postHidden = "The post has been hidden from you.";
  String reportedSuccessfully = "Reported successfully.";
  String errorWhileReporting = "An error occurred while reporting.";
  String errorCreatingPost = "Error creating post";
  String postSavedSuccessfully = "Post saved successfully.";
  String failedToSavePost = "Failed to save the post.";


  // updated onces
  String failedToFetchFoodieFundsDetails = 'Failed to fetch foodie funds details.';
  String userInfoUpdated = "User information has been updated successfully!";
  String errorUpdatingUserInfo = "An error occurred while updating user information!";
  String accountAddedSuccessfully = "The account has been added successfully!";
  String errorAddingAccount = "An error occurred while adding the account!";


  String serverError = "Server Error!";
  String invalidCredentials = 'Invalid credentials';
  String loginFailedTryAgain = 'Login failed, Try again';
  String sentOtpToEmail = "Sent Otp To Email Id!";
  String cantSendOtp = "can't send otp!";
  String cantLogoutUser = "can't logout user!";
  String sentOtpToEmailAlt = "Sent OTP To Email Id"; // Slightly different casing
  String emailIdNotValid = "Email Id Not Valid!";
  String selectCategoryAndSubcategory = "Please select a category and subcategory";
  String enterAllFields = "Enter all fields";


    String pleaseEnterMessage = "Please enter message";
  String pleaseEnterValidData = "Please enter valid data";
  String noFriendsAdded = "No friends have been added.";
  String postSentSuccessfully = "Post sent successfully!";
  String cantAdd = "Can't add!";
  String likedPost = "You liked this post!";
  String errorLikingPost = "Error while liking the post!";
  String dislikedPost = "You disliked this post!";
  String errorDislikingPost = "Error while disliking the post!";
  String emptyCommentNotAllowed = "You cannot add empty data. Please enter a comment.";
  String commentAddedSuccessfully = "Comment added successfully!";
  String unableToAddComment = "Unable to add comment. Please try again.";
  String commentLiked = "Comment liked!";
  String commentUnliked = "Comment unliked!";
  String errorLikingComment = "Error while liking the comment. Please try again.";
  String disliked = "DisLiked!";
  String errorDislikingComment = "Error while disliking the comment. Please try again.";
  String emptyReplyNotAllowed = "You cannot add an empty comment. Please enter a reply.";
  String biometric = "Biometric authentication is not available on this device.";
  String noNotifications = "No Notifications";
  String fetchingError = "Error fetching details";
  String deleteNotificationFailed="Failed to delete notification";
  String noBankForLinking="No Bank Account Linked Please link your bank account to download the statement.";
  String pickingError="Error picking image...";

String pleaseSelectDueDate = "Please select a due date.";
String pleaseEnterMessageAgain = "Please enter a message.";
String selectedTransactionsDeleted = "✔️ Your selected transactions have been deleted.";
String selectedTransactionsDeleteFailed = "❌ Unable to delete the selected transactions. Please try again.";
String selectOnlyOneFriendLend = "Please select only one friend for lending";
String addMembersToProceed = "Please add members to proceed!";
String invalidAmountEntered = "Invalid amount entered!";
String noMembersSelected = "No members selected!";
String splitAmountSuccess = "The split amount has been successfully sent to users!";
String splitAmountError = "An error occurred while trying to split the bill!";
String lendAmountSuccess = "Lend amount has been successfully sent to users!";
String lendAmountError = "An error occurred while trying to lend money!";
String errorSettlingDue = "Error settling due";
String transactionHiddenSuccess = "Transaction hidden Successfully";

String transactionHideFailed = "Failed to hide transaction";
String errorHidingTransaction = "Error hiding transaction";
String provideLendDetails = "Please provide lend details";
String selectAtLeastOneFriend = "Please select at least one friend";
String authenticationError = "Authentication error!";
String splitAmountSent = "Split amount sent to users!";
String splitError = "Can't split, error!";


String maxFiveImagesAllowed = "Maximum 5 images allowed";
String fillAllRequiredFields = "Please fill in all required fields";
String emptycategoryList = "Please select atleast one category to proceed";
String errorUploadingImage = "Error uploading image";
String failedToSubmitPost = "Failed to submit post...";
String errorSubmittingPost = "Error submitting post";
String debtCreatedSuccess = "Debt created successfully!";
String pickAtleastOneBank = "Pick atleast one bank to proceed";
String noAccountSelected = "No account was selected. Please add an account.";
String uploadError = "Please Upload Image";
String amountExceed = "Amount exceeds the total budget!";



  Future<bool> fetchConstants() async {
    try {
      final response = await getDataApiCall("${url}/constant/snackbar");
      printData(response);

      if (response.statusCode == 200) 
      {
        var data = jsonDecode(response.body);
        data = data['data'] ?? {};
        maxLimitSetFail = data['maxLimitSetFail'] ?? maxLimitSetFail;
        remainderError = data['remainderError'] ?? remainderError;
        remainder = data['remainder'] ?? remainder;
        paymentsInit = data['paymentsInit'] ?? paymentsInit;
        paymentsError = data['paymentsError'] ?? paymentsError;
        budgetDeletionSuccess = data['budgetDeletionSuccess'] ?? budgetDeletionSuccess;
        amountExceed = data['amountExceed'] ?? amountExceed;
        uploadError = data['uploadError'] ?? uploadError;
        pickingError = data['pickingError'] ?? pickingError;
        fetchingError = data['fetchingError'] ?? fetchingError;
        noBankForLinking = data['noBankForLinking'] ?? noBankForLinking;
        noBankForLinking = data['noBankForLinking'] ?? noBankForLinking;
        deleteNotificationFailed = data['deleteNotificationFailed'] ?? deleteNotificationFailed;
        biometric = data['biometric'] ?? biometric;
        noNotifications = data['noNotifications'] ?? noNotifications;
        enterValidemail = data['enterValidemail'] ?? enterValidemail;
        selectCategoryAndSubcategory = data['selectCategoryAndSubcategory'] ?? selectCategoryAndSubcategory;
        enterValidMobile = data['enterValidMobile'] ?? enterValidMobile;
        errorGeneratingOtp = data['errorGeneratingOtp'] ?? errorGeneratingOtp;
        enterOtpLength = data['enterOtpLength'] ?? enterOtpLength;
        pickOneBank = data['pickOneBank'] ?? pickOneBank;
        accountAdded = data['accountAdded'] ?? accountAdded;
        maxRetries = data['maxRetries'] ?? maxRetries;
        enterValidOtp = data['enterValidOtp'] ?? enterValidOtp;
        bankLinkedSuccess = data['bankLinkedSuccess'] ?? bankLinkedSuccess;
        consentApproveError = data['consentApproveError'] ?? consentApproveError;
        consentApproved = data['consentApproved'] ?? consentApproved;
        consentDeclined = data['consentDeclined'] ?? consentDeclined;
        consentDisapproveError = data['consentDisapproveError'] ?? consentDisapproveError;
        categoryAdded = data['categoryAdded'] ?? categoryAdded;
        transactionAddFail = data['transactionAddFail'] ?? transactionAddFail;
        transactionSuccess = data['transactionSuccess'] ?? transactionSuccess;
        addingFriend = data['addingFriend'] ?? addingFriend;
        addFriendFail = data['addFriendFail'] ?? addFriendFail;
        friendRejected = data['friendRejected'] ?? friendRejected;
        sendingRequest = data['sendingRequest'] ?? sendingRequest;
        requestAddFail = data['requestAddFail'] ?? requestAddFail;
        requestRemoved = data['requestRemoved'] ?? requestRemoved;
        requestRemoveFail = data['requestRemoveFail'] ?? requestRemoveFail;
        friendRemoved = data['friendRemoved'] ?? friendRemoved;
        noTransactionData = data['noTransactionData'] ?? noTransactionData;
        pinSetFail00 = data['pinSetFail00'] ?? pinSetFail00;
        pinSetSuccess = data['pinSetSuccess'] ?? pinSetSuccess;
        pinSetFail = data['pinSetFail'] ?? pinSetFail;
        otpAccepted = data['otpAccepted'] ?? otpAccepted;
        otpInvalid = data['otpInvalid'] ?? otpInvalid;
        passwordChanged = data['passwordChanged'] ?? passwordChanged;
        passwordChangeFail = data['passwordChangeFail'] ?? passwordChangeFail;
        otpResent = data['otpResent'] ?? otpResent;
        otpSendFail1 = data['otpSendFail1'] ?? otpSendFail1;
        otpResentSuccess = data['otpResentSuccess'] ?? otpResentSuccess;
        otpSendFail2 = data['otpSendFail2'] ?? otpSendFail2;
        offReplays = data['offReplays'] ?? offReplays;


        budgetAdded = data['budgetAdded'] ?? budgetAdded;
        budgetAddFailed = data['budgetAddFailed'] ?? budgetAddFailed;
        budgetUpdated = data['budgetUpdated'] ?? budgetUpdated;
        budgetUpdateFailed = data['budgetUpdateFailed'] ?? budgetUpdateFailed;
        processingBudgetDeletion = data['processingBudgetDeletion'] ?? processingBudgetDeletion;
        budgetDeletionError = data['budgetDeletionError'] ?? budgetDeletionError;
        budgetAmountMismatch = data['budgetAmountMismatch'] ?? budgetAmountMismatch;

        debtAdded = data['debtAdded'] ?? debtAdded;
        debtAddFailed = data['debtAddFailed'] ?? debtAddFailed;
        debtCleared = data['debtCleared'] ?? debtCleared;
        debtClearError = data['debtClearError'] ?? debtClearError;
        allDebtsCleared = data['allDebtsCleared'] ?? allDebtsCleared;
        debtUpdateError = data['debtUpdateError'] ?? debtUpdateError;

        billAdded = data['billAdded'] ?? billAdded;
        billAddFailed = data['billAddFailed'] ?? billAddFailed;

        paymentAdded = data['paymentAdded'] ?? paymentAdded;
        paymentAddFailed = data['paymentAddFailed'] ?? paymentAddFailed;
        debterror = data['debterror'] ?? debterror;


        unableToAddReply = data['unableToAddReply'] ?? unableToAddReply;
        deletedPost = data['deletedPost'] ?? deletedPost;
        errorWhileDeletingPost = data['errorWhileDeletingPost'] ?? errorWhileDeletingPost;
        imageUploadFailed = data['imageUploadFailed'] ?? imageUploadFailed;
        postHidden = data['postHidden'] ?? postHidden;
        reportedSuccessfully = data['reportedSuccessfully'] ?? reportedSuccessfully;
        errorWhileReporting = data['errorWhileReporting'] ?? errorWhileReporting;
        errorCreatingPost = data['errorCreatingPost'] ?? errorCreatingPost;
        postSavedSuccessfully = data['postSavedSuccessfully'] ?? postSavedSuccessfully;
        failedToSavePost = data['failedToSavePost'] ?? failedToSavePost;


        failedToFetchFoodieFundsDetails = data['failedToFetchFoodieFundsDetails'] ?? failedToFetchFoodieFundsDetails;
        userInfoUpdated = data['userInfoUpdated'] ?? userInfoUpdated;
        errorUpdatingUserInfo = data['errorUpdatingUserInfo'] ?? errorUpdatingUserInfo;
        accountAddedSuccessfully = data['accountAddedSuccessfully'] ?? accountAddedSuccessfully;
        errorAddingAccount = data['errorAddingAccount'] ?? errorAddingAccount;


        serverError = data['serverError'] ?? serverError;
        invalidCredentials = data['invalidCredentials'] ?? invalidCredentials;
        loginFailedTryAgain = data['loginFailedTryAgain'] ?? loginFailedTryAgain;
        sentOtpToEmail = data['sentOtpToEmail'] ?? sentOtpToEmail;
        cantSendOtp = data['cantSendOtp'] ?? cantSendOtp;
        cantLogoutUser = data['cantLogoutUser'] ?? cantLogoutUser;
        sentOtpToEmailAlt = data['sentOtpToEmailAlt'] ?? sentOtpToEmailAlt;
        enterAllFields = data['enterAllFields'] ?? enterAllFields;
        emailIdNotValid = data['emailIdNotValid'] ?? emailIdNotValid;


      pleaseEnterMessage = data['pleaseEnterMessage'] ?? pleaseEnterMessage;
      pleaseEnterValidData = data['pleaseEnterValidData'] ?? pleaseEnterValidData;
      noFriendsAdded = data['noFriendsAdded'] ?? noFriendsAdded;
      postSentSuccessfully = data['postSentSuccessfully'] ?? postSentSuccessfully;
      cantAdd = data['cantAdd'] ?? cantAdd;
      likedPost = data['likedPost'] ?? likedPost;
      errorLikingPost = data['errorLikingPost'] ?? errorLikingPost;
      dislikedPost = data['dislikedPost'] ?? dislikedPost;
      errorDislikingPost = data['errorDislikingPost'] ?? errorDislikingPost;
      emptyCommentNotAllowed = data['emptyCommentNotAllowed'] ?? emptyCommentNotAllowed;
      commentAddedSuccessfully = data['commentAddedSuccessfully'] ?? commentAddedSuccessfully;
      unableToAddComment = data['unableToAddComment'] ?? unableToAddComment;
      commentLiked = data['commentLiked'] ?? commentLiked;
      commentUnliked = data['commentUnliked'] ?? commentUnliked;
      errorLikingComment = data['errorLikingComment'] ?? errorLikingComment;
      disliked = data['disliked'] ?? disliked;
      errorDislikingComment = data['errorDislikingComment'] ?? errorDislikingComment;
      emptyReplyNotAllowed = data['emptyReplyNotAllowed'] ?? emptyReplyNotAllowed;


pleaseSelectDueDate = data['pleaseSelectDueDate'] ?? pleaseSelectDueDate;
pleaseEnterMessageAgain = data['pleaseEnterMessageAgain'] ?? pleaseEnterMessageAgain;
selectedTransactionsDeleted = data['selectedTransactionsDeleted'] ?? selectedTransactionsDeleted;
selectedTransactionsDeleteFailed = data['selectedTransactionsDeleteFailed'] ?? selectedTransactionsDeleteFailed;
selectOnlyOneFriendLend = data['selectOnlyOneFriendLend'] ?? selectOnlyOneFriendLend;
addMembersToProceed = data['addMembersToProceed'] ?? addMembersToProceed;
invalidAmountEntered = data['invalidAmountEntered'] ?? invalidAmountEntered;
noMembersSelected = data['noMembersSelected'] ?? noMembersSelected;
splitAmountSuccess = data['splitAmountSuccess'] ?? splitAmountSuccess;
splitAmountError = data['splitAmountError'] ?? splitAmountError;
lendAmountSuccess = data['lendAmountSuccess'] ?? lendAmountSuccess;
lendAmountError = data['lendAmountError'] ?? lendAmountError;
errorSettlingDue = data['errorSettlingDue'] ?? errorSettlingDue;
transactionHiddenSuccess = data['transactionHiddenSuccess'] ?? transactionHiddenSuccess;
transactionHideFailed = data['transactionHideFailed'] ?? transactionHideFailed;
errorHidingTransaction = data['errorHidingTransaction'] ?? errorHidingTransaction;
provideLendDetails = data['provideLendDetails'] ?? provideLendDetails;
selectAtLeastOneFriend = data['selectAtLeastOneFriend'] ?? selectAtLeastOneFriend;
authenticationError = data['authenticationError'] ?? authenticationError;
splitAmountSent = data['splitAmountSent'] ?? splitAmountSent;
splitError = data['splitError'] ?? splitError;

maxFiveImagesAllowed = data['maxFiveImagesAllowed'] ?? maxFiveImagesAllowed;
fillAllRequiredFields = data['fillAllRequiredFields'] ?? fillAllRequiredFields;
emptycategoryList = data['emptycategoryList'] ?? emptycategoryList; 
errorUploadingImage = data['errorUploadingImage'] ?? errorUploadingImage;
failedToSubmitPost = data['failedToSubmitPost'] ?? failedToSubmitPost;
errorSubmittingPost = data['errorSubmittingPost'] ?? errorSubmittingPost;
debtCreatedSuccess = data['debtCreatedSuccess'] ?? debtCreatedSuccess;
pickAtleastOneBank = data['pickAtleastOneBank'] ?? pickAtleastOneBank;
noAccountSelected = data['noAccountSelected'] ?? noAccountSelected;
validAmountAndShares = data['validAmountAndShares'] ?? validAmountAndShares;
noSharesCalculated = data['noSharesCalculated'] ?? noSharesCalculated;
userIdNotAvailable = data['userIdNotAvailable'] ?? userIdNotAvailable;
userNameNotAvailable = data['userNameNotAvailable'] ?? userNameNotAvailable;
noFriendsToNotify = data['noFriendsToNotify'] ?? noFriendsToNotify;




        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

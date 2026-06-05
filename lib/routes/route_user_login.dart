import 'index_route.dart';

class SendNotificationsRoutes {
  static final String _urlPath = API.mainBackendUrl + "/notify";
  static String addDeviceToNotify = "$_urlPath/addDeviceToNotify";
  static String SendNotificationsToDevice =
      "${API.mainBackendUrl}/reminders/sendNotifications/ToDevice";
  static String deviceScreenTime = "${API.mainBackendUrl}/deviceScreenTime";
}

class otpRoutes {
  static final String _urlPath = API.mainBackendUrl;
  static String sendOtp = "$_urlPath/otp/send";
  static String resendOtp = "$_urlPath/otp/resend-otp";
  static String verifyOtp = "$_urlPath/otp/verify-otp";
}

class AuthApiRoutes {
  static final String _urlPath = API.mainBackendUrl + "/auth";
  static final String _emailPath = API.EmailUrl;

  static String login = "$_urlPath/sign-in";
  static String verify = "$_urlPath/verify";
  static String forceLogin = "$_urlPath/force-login";
  static String appleAuth = "$_urlPath/apple-auth";
  static String googleAuth = "$_urlPath/google-auth";
  static String signUp = "$_urlPath/sign-up";
  static String logout = "$_urlPath/logout";
  static String validateName = "$_urlPath/validate-name";

  //generate-token Email part
  static String generateToken = "$_emailPath/generate-token";
  static String getUnLinkedCards = "$_emailPath/unLinked-cards";
  static String revokeAccessToken = "$_emailPath/remove-access";
  static String scrape = "$_emailPath/scrape";
  static String statementPassword = "$_emailPath/statement-password";
  static String pendingStatements = "$_emailPath/pending-statements";
  static String processPendingStatement = "$_emailPath/process-pending-statement";
  static String addbankMapping = "$_emailPath/add-bank-mapping";
  static String getCreditCardList = "$_emailPath/";
}

class ReferralRoutes {
  static final String _urlPath = "${API.BankApiUrl}/referral";

  static String shareCode = "$_urlPath/share-code";
  static String validate = "$_urlPath/validate";
  static String apply = "$_urlPath/apply";
  static String create = "$_urlPath/create";
}

class UserRoutes {
  static final String _urlPath = API.mainBackendUrl + "/user";
  static final String install = API.mainBackendUrl + "/install";
  static String update = "$_urlPath/";
  static String addInstallUser = "${install}/attribute";
  static String deleteUser = "$_urlPath/";
  static String getInfo = "$_urlPath/info";
  // static String getInfo = "${_urlPath}/info";
  static String updateFetchStatus = "$_urlPath/updateFetchStatus";
  static String logout = "$_urlPath/logout";
  static String addFriend = "$_urlPath/friend/add";
  static String findFriend = "$_urlPath/friend/find";
  static String removeFriend = "$_urlPath/friend/remove";
  static String rejectRequest = "$_urlPath/friend/rejectRequest/";
  static String sendRequest = "$_urlPath/friend/sendRequest/";
  static String unsendRequest = "$_urlPath/friend/unsendRequest/";
  static String acceptRequestStatus = "$_urlPath/friend/acceptRequestStatus/";
  static String maskedName = "$_urlPath/maskedName";
  static String newNotifications = "$_urlPath/newNotifications";
  static String updateCupertino = "$_urlPath/updateCupertino";
  static String cupertino = "$_urlPath/cupertino/";
  static String report = "$_urlPath/report";
  static String selectedBank = "$_urlPath/selectedBank/";
  static String myNotifications = "$_urlPath/myNotifications/";
  static String inflation = "$_urlPath/inflation/";
  static String deleteNotifications = "$_urlPath/deleteNotifications";
  static String updateprofile = "$_urlPath/updateprofile/";
  static String connections = "$_urlPath/connections";
  static String getMaskedUsers = "$_urlPath/getMaskedUsers";
}

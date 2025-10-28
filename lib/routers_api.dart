import 'backed_connections/apis_connect.dart';

class otpRoutes {
  static final String _urlPath = url;
  static String sendOtp = "$_urlPath/otp/send";
  static String resendOtp = "$_urlPath/otp/resend-otp";
  static String verifyOtp = "$_urlPath/otp/verify-otp";
}

class RouterApi {
  static final String _urlPath = url;
  static final String _emailPath = EmailUrl;

  static String login = "$_urlPath/auth/sign-in";
  static String verify = "$_urlPath/auth/verify";
  static String forceLogin = "$_urlPath/auth/force-login";
  static String appleAuth = "$_urlPath/auth/apple-auth";
  static String googleAuth = "$_urlPath/auth/google-auth";
  static String signUp = "$_urlPath/auth/sign-up";
  static String logout = "$_urlPath/auth/logout";

  //generate-token Email part
  static String generateToken = "$_emailPath/generate-token";
  static String getUnLinkedCards = "$_emailPath/get-unLinked-cards";
  static String revokeAccessToken = "$_emailPath/remove-access";
  static String scrape = "$_emailPath/scrape";
  static String getCreditCardList = "$_emailPath/";
}

class UserRoutes {
  static final String _urlPath = url;
  static String update = "$_urlPath/user/";
  static String getInfo = "$_urlPath/user/info";
  static String updateFetchStatus = "$_urlPath/user/updateFetchStatus";
  static String logout = "$_urlPath/user/logout";
  static String addFriend = "$_urlPath/user/friend/add";
  static String findFriend = "$_urlPath/user/friend/find";
  static String removeFriend = "$_urlPath/user/friend/remove";
  static String rejectRequest = "$_urlPath/user/friend/rejectRequest/";
  static String sendRequest = "$_urlPath/user/friend/sendRequest/";
  static String unsendRequest = "$_urlPath/user/friend/unsendRequest/";
  static String acceptRequestStatus =
      "$_urlPath/user/friend/acceptRequestStatus/";
  static String maskedName = "$_urlPath/user/maskedName";
  static String newNotifications = "$_urlPath/user/newNotifications";
  static String updateCupertino = "$_urlPath/user/updateCupertino";
  static String cupertino = "$_urlPath/user/cupertino/";
  static String report = "$_urlPath/user/report";
  static String selectedBank = "$_urlPath/user/selectedBank/";
  static String myNotifications = "$_urlPath/user/myNotifications/";
  static String inflation = "$_urlPath/user/inflation/";
  static String deleteNotifications = "$_urlPath/user/deleteNotifications/";
  static String updateprofile = "$_urlPath/user/updateprofile/";
  static String connections = "$_urlPath/user/connections";
  static String getMaskedUsers = "$_urlPath/user/getMaskedUsers";
}


class PostRoutes
{
  static final String _urlPath = url;
  static String post = "$_urlPath/post/";
  static String allPost = "$_urlPath/post/all/";
  static String save = "$_urlPath/post/save/";
  static String saved = "$_urlPath/post/saved/";
  static String userDiscussions = "$_urlPath/post/userDiscussions";
  static String myDiscussions = "$_urlPath/post/myDiscussions/";
  static String trending = "$_urlPath/post/trending/";
  static String feed = "$_urlPath/post/feed/";
}
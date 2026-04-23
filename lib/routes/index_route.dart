import '../backed_connections/googlesignin/credentials.dart';

class API {
  static final bool apis_flag = true;

  static final String urlWithLocallHost = apis_flag
      ? Credentials.LIVE_API
    : Credentials.LIVE_API_TEST; // main backend api
  static final String urlWithLocallHost2 = apis_flag ? Credentials.LIVE_API2
      : Credentials.LIVE_API_TEST2; // email sync api

  static final String urlWithLocallHost3 =!apis_flag ? Credentials.FINVU_LIVE : Credentials.FINVU_TEST; // bank api
  
  static final String mainBackendUrlLive = "${Credentials.LIVE_API}api/v1";
  static final String mainBackendUrl = "${urlWithLocallHost}api/v1";
  static final String EmailUrl = "${urlWithLocallHost}api/v1/email";
  static final String BankApiUrl = "${urlWithLocallHost}api/v1/bank";
}

class BackendApiEndPoints {
  static final String chat = "${API.mainBackendUrl}/chat";
  static final String constant = "${API.mainBackendUrl}/constant";
  static final String budget = "${API.mainBackendUrl}/budget";
  static final String finvu = "${API.BankApiUrl}/finvu";
  static final String post = "${API.mainBackendUrl}/post";
  static final String comment = "${API.mainBackendUrl}/comment";
  static final String reply = "${API.mainBackendUrl}/reply";
  static final String split = "${API.mainBackendUrl}/split";
  static final String poll = "${API.mainBackendUrl}/poll";
  static final String upvote = "${API.mainBackendUrl}/upvote";
  static final String downvote = "${API.mainBackendUrl}/downvote";
  static final String transactionauto = "${API.BankApiUrl}/transactionauto";
  static final String transaction = API.BankApiUrl + "/transaction";
  static final String notify = API.mainBackendUrl + "/notify";
  static final String auth = API.mainBackendUrl + "/auth";
  static final String user = API.mainBackendUrl + "/user";
  static final String reward = "${API.mainBackendUrl}/reward";
}

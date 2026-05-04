import 'dart:io';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../apis_connect.dart';
import 'credentials.dart';

class GoogleAuthToken {
  static String Android = Credentials.androidClientId;
  static String ios = Credentials.iosClientId;
  static String serverClientId = Credentials.serverClientId;

  static List<String> scopesEmails = [
    'email',
    'profile',
    "https://www.googleapis.com/auth/gmail.readonly",
  ];

  static List<String> scopes = [
    'email',
    'profile',
  ];

  static GoogleSignIn createGoogleSignIn({
    required bool isEmail,
    bool forceCodeForRefreshToken = false,
  }) {
    return GoogleSignIn(
      forceCodeForRefreshToken: true, // ✅ correct
      clientId: Platform.isIOS ? GoogleAuthToken.ios : null,
      serverClientId: GoogleAuthToken.serverClientId,
      scopes: isEmail ? GoogleAuthToken.scopesEmails : GoogleAuthToken.scopes,
    );
  }
  // static GoogleSignIn createGoogleSignIn({required bool isEmail}) {
  //   return GoogleSignIn(
  //     clientId:
  //         Platform.isAndroid ? GoogleAuthToken.Android : GoogleAuthToken.ios,
  //     serverClientId:
  //         GoogleAuthToken.serverClientId, // For iOS, optional for Android
  //     scopes: isEmail ? GoogleAuthToken.scopesEmails : GoogleAuthToken.scopes,
  //   );
  // }
}



//  "https://www.googleapis.com/auth/userinfo.email"
  // static GoogleSignIn googleToken=  GoogleSignIn(
  //   clientId: Platform.isAndroid ?GoogleAuthToken.Android : GoogleAuthToken.ios,
  //   serverClientId:GoogleAuthToken.serverClientId, // For iOS, optional for Android
  //   scopes: GoogleAuthToken.scopes,
  // );
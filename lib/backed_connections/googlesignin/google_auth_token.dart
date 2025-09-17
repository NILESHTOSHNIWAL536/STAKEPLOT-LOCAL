

import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthToken
{

   static String Android='907682114982-g9ke4hcp10mpfb53hnbejg5q4btjpsam.apps.googleusercontent.com';
   static String ios= "907682114982-3nr2b1vgipnq5348u4fieeemr74vmuol.apps.googleusercontent.com";
   static String serverClientId='907682114982-ja3qjtdj38f1p16q1hq9c868ga6sfn8b.apps.googleusercontent.com';
   static List<String> scopes=[
        'email',
        'profile',
        // "https://www.googleapis.com/auth/gmail.readonly",
        // "https://www.googleapis.com/auth/userinfo.email"
      ];

  static GoogleSignIn googleToken=  GoogleSignIn(
    clientId: Platform.isAndroid ?GoogleAuthToken.Android : GoogleAuthToken.ios,
    serverClientId:GoogleAuthToken.serverClientId, // For iOS, optional for Android
    scopes: GoogleAuthToken.scopes,
  );

}
import 'dart:io';

import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isAndroid ? '907682114982-g9ke4hcp10mpfb53hnbejg5q4btjpsam.apps.googleusercontent.com' : "907682114982-3nr2b1vgipnq5348u4fieeemr74vmuol.apps.googleusercontent.com",
    serverClientId:
        '907682114982-ja3qjtdj38f1p16q1hq9c868ga6sfn8b.apps.googleusercontent.com', // For iOS, optional for Android
    scopes: ['email', 'profile',],
  );
  Future<Map<String, dynamic>?> signInWithGoogle(context) async {
    try {
      // Trigger Google Sign-In
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      // Get authentication details
      final GoogleSignInAuthentication googleAuth =await googleUser.authentication;
      final String? idToken = googleAuth.idToken;     // final String? accessToken = googleAuth.accessToken;
      if (idToken != null) {
      final response = await http.post(Uri.parse('$url/user/google-auth'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        );
        if (response.statusCode == 200) {
          loginCalledData(response, context);
          return json.decode(response.body);
        } else {}
      } else {}
    } catch (e) {}
    return null;
  }
  // Apple Sign-In (new method)
    Future<Map<String, dynamic>?> signInWithApple(context) async {
      try {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName,
          ],
        );
        // Extract data
        final String? idToken = credential.identityToken;
        final String? authCode = credential.authorizationCode;
        final String? email = credential.email;
        final String? fullName = credential.givenName != null
            ? '${credential.givenName} ${credential.familyName ?? ''}'
            : null;
        final String? userId = credential.userIdentifier;
        if (idToken == null) {
          return null;
        }
        final response = await http.post(Uri.parse('$url/user/apple-auth'), 
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'idToken': idToken,
            'authorizationCode': authCode,
            'email': email,
            'fullName': fullName,
            'userId': userId,
          }),
        );
        if (response.statusCode == 200) {
          loginCalledData(response, context); // Reuse your login logic
          return json.decode(response.body);
        } else {
        }
      } catch (e) {
      }
      return null;
    }

}

import 'dart:io';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'google_auth_token.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleAuthToken.googleToken;

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
      if (idToken == null)return null; 

      final response = await http.post(Uri.parse('$url/user/google-auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

        final String? authCode = await googleUser.serverAuthCode;

        if (authCode != null) 
        {
            await http.post(
              Uri.parse('$url/user/google-gmail-auth'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'idToken':  authCode}),
            );
        }
        if (response.statusCode == 200)return json.decode(response.body);
    } catch (e)
     {
        print("Error --------------");
        print(e);

    }

    return null;
  }
  // Apple Sign-In (new method)
 Future<Map<String, dynamic>?> signInWithApple(context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      // Extract data
      final String? idToken = credential.identityToken;
      final String? authCode = credential.authorizationCode;
      String? email = credential.email;
      final String? fullName = credential.givenName != null
          ? '${credential.givenName} ${credential.familyName ?? ''}'
          : null;

      if (idToken == null) {
        return null;
      }
    
      final response = await http.post(
        Uri.parse('$url/user/apple-auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'authorizationCode': authCode,
          'email': email,
          'fullName': fullName,
        }),
      );

      if (response.statusCode == 400) {
        return null;
      }

      // Check response status
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
      }
    } catch (e) {
    }
    return null;
  }
}

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'google_auth_token.dart';

class AuthService {
   GoogleSignIn _googleSignIn = GoogleAuthToken.createGoogleSignIn(isEmail:false );

  Future<Map<String, dynamic>?> signInWithGoogle(context, {bool flag = true,bool isEmail=false}) async {
    try {
      // Trigger Google Sign-In
      if(isEmail)_googleSignIn = GoogleAuthToken.createGoogleSignIn(isEmail:isEmail);
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth
          .idToken; // final String? accessToken = googleAuth.accessToken;
      if (idToken == null) return null;

     //don't remove this code 
       final String? authCode = await googleUser.serverAuthCode;
        if (authCode != null)
        {
          final response =  await postDataApiCall(AuthApiRoutes.generateToken, 
          
                {'idToken':  authCode}
            );
             if(!flag)return {};
        }

      final response = await postDataApiCall(AuthApiRoutes.googleAuth, 
      
        {'idToken': idToken}
      );

      if (getFlagOfResponse(response)) return json.decode(response.body);
    } catch (e) {}

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
      final response = await postDataApiCall(AuthApiRoutes.appleAuth, 
      
          {
          'idToken': idToken,
          'authorizationCode': authCode,
          'email': email,
          'fullName': fullName,
        }
      );
      printData(response);
      if (response.statusCode == 400) {
        return null;
      }

      // Check response status
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {}
    } catch (e) {
      
    }
    return null;
  }
}

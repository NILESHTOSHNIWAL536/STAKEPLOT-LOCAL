// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
// import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// import 'google_auth_token.dart';

// class AuthService {
//    GoogleSignIn _googleSignIn = GoogleAuthToken.createGoogleSignIn(isEmail:false );

//   Future<Map<String, dynamic>?> signInWithGoogle(context, {bool flag = true,bool isEmail=false}) async {
//     try {
//       // Trigger Google Sign-In
//       if(isEmail)_googleSignIn = GoogleAuthToken.createGoogleSignIn(isEmail:isEmail);
//       await _googleSignIn.signOut();
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         return null;
//       }
//       // Get authentication details
//       final GoogleSignInAuthentication googleAuth =await googleUser.authentication;
//       final String? idToken = googleAuth.idToken; // final String? accessToken = googleAuth.accessToken;
//       if (idToken == null) return null;

//      //don't remove this code
//         final String? authCode = await googleUser.serverAuthCode;
//         if (authCode != null)
//         {
//           final response =  await postDataApiCall(AuthApiRoutes.generateToken, {'idToken':  authCode});
//           if(!flag)return {};
//         }

//       final response = await postDataApiCall(AuthApiRoutes.googleAuth,

//         {'idToken': idToken}
//       );

//       if (getFlagOfResponse(response)) return json.decode(response.body);
//     } catch (e) {}

//     return null;
//   }

//   // Apple Sign-In (new method)
//   Future<Map<String, dynamic>?> signInWithApple(context) async {
//     try {
//       final credential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//       );
//       // Extract data
//       final String? idToken = credential.identityToken;
//       final String? authCode = credential.authorizationCode;
//       String? email = credential.email;
//       final String? fullName = credential.givenName != null
//           ? '${credential.givenName} ${credential.familyName ?? ''}'
//           : null;

//       if (idToken == null) {
//         return null;
//       }
//       final response = await postDataApiCall(AuthApiRoutes.appleAuth,

//           {
//           'idToken': idToken,
//           'authorizationCode': authCode,
//           'email': email,
//           'fullName': fullName,
//         }
//       );
//       if (response.statusCode == 400) {
//         return null;
//       }

//       // Check response status
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {}
//     } catch (e) {

//     }
//     return null;
//   }
// }

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'google_auth_token.dart';

class AuthService {
  // ── Keep a single instance per sign-in mode to avoid re-init overhead ──
  static GoogleSignIn? _emailSignIn;
  static GoogleSignIn? _basicSignIn;

  GoogleSignIn _getSignIn({required bool isEmail}) {
    if (isEmail) {
      _emailSignIn ??= GoogleAuthToken.createGoogleSignIn(isEmail: true);
      return _emailSignIn!;
    } else {
      _basicSignIn ??= GoogleAuthToken.createGoogleSignIn(isEmail: false);
      return _basicSignIn!;
    }
  }

  Future<Map<String, dynamic>?> signInWithGoogle(
    context, {
    bool flag = true,
    bool isEmail = false,
  }) async {
    try {
      final googleSignIn = _getSignIn(isEmail: isEmail);

      // Only sign out if already signed in — avoids a redundant round-trip
      final currentUser = await googleSignIn.signInSilently();
      if (currentUser != null) await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      // Fetch auth token and server auth code IN PARALLEL
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? authCode = googleUser.serverAuthCode;

      if (idToken == null) return null;

      // Fire token generation and main auth concurrently when possible
      if (authCode != null) {
        // Run generateToken in background — don't await unless flag demands it
        final tokenFuture = postDataApiCall(
          AuthApiRoutes.generateToken,
          {'idToken': authCode},
        );

        if (!flag) {
          // Wait for token only (email-scoped flow), skip main auth
          await tokenFuture;
          return {};
        }

        // For the main flow, fire both calls in parallel
        final results = await Future.wait([
          tokenFuture,
          postDataApiCall(AuthApiRoutes.googleAuth, {'idToken': idToken}),
        ]);

        final authResponse = results[1];
        if (getFlagOfResponse(authResponse)) {
          return json.decode(authResponse.body);
        }
        return null;
      }

      // No serverAuthCode — single call path
      if (!flag) return {};
      final response = await postDataApiCall(
        AuthApiRoutes.googleAuth,
        {'idToken': idToken},
      );
      if (getFlagOfResponse(response)) return json.decode(response.body);
    } catch (e) {
      // Log in production; keep UI unblocked
      appLog('signInWithGoogle error: $e');
    }
    return null;
  }

  // ── Apple Sign-In ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> signInWithApple(context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? idToken = credential.identityToken;
      final String? authCode = credential.authorizationCode;
      final String? email = credential.email;
      final String? fullName = credential.givenName != null
          ? '${credential.givenName} ${credential.familyName ?? ''}'.trim()
          : null;

      if (idToken == null) return null;

      final response = await postDataApiCall(
        AuthApiRoutes.appleAuth,
        {
          'idToken': idToken,
          'authorizationCode': authCode,
          'email': email,
          'fullName': fullName,
        },
      );

      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      appLog('signInWithApple error: $e');
    }
    return null;
  }
}

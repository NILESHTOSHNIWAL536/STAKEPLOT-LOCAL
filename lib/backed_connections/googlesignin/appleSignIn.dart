
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// class AppleSignIN {
 
//     Future<Map<String, dynamic>?> signInWithApple(context) async {
//       try {
//         final credential = await SignInWithApple.getAppleIDCredential(
//           scopes: [
//             AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName,
//           ],
//         );
//         // Extract data
//         final String? idToken = credential.identityToken;
//         final String? authCode = credential.authorizationCode;
//         final String? email = credential.email;
//         final String? fullName = credential.givenName != null
//             ? '${credential.givenName} ${credential.familyName ?? ''}'
//             : null;
//         final String? userId = credential.userIdentifier;
//         if (idToken == null) {
//           return null;
//         }
//         final response = await http.post(Uri.parse('$url/user/apple-auth'), 
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'idToken': idToken,
//             'authorizationCode': authCode,
//             'email': email,
//             'fullName': fullName,
//             'userId': userId,
//           }),
//         );
//         if (response.statusCode == 200) {
//           loginCalledData(response, context); // Reuse your login logic
//           return json.decode(response.body);
//         } else {
//         }
//       } catch (e) {
//       }
//       return null;
//     }

// }


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../auth_service/login_apis.dart';

class AppleSignIN {
  Future<Map<String, dynamic>?> signInWithApple(BuildContext context) async {
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
          ? '${credential.givenName} ${credential.familyName ?? ''}'
          : null;
      final String? userId = credential.userIdentifier;

      // 🛑 Step 1: Validate Email Immediately
      if (email == null || email.endsWith('privaterelay.appleid.com')) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Email Required"),
            content: Text(
              "This Apple ID did not provide a valid email. Please use a different Apple ID or sign in manually.",
            ),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
        return null; // Stop the sign-in flow
      }

      if (idToken == null) {
        return null;
      }

      // ✅ Step 2: Continue with backend API
      final response = await http.post(
        Uri.parse('$url/user/apple-auth'),
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
       LoginService.loginCalledData(response, context);
        return json.decode(response.body);
      } else {
      }
    } catch (e) {
    }

    return null;
  }
}

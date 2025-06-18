import 'dart:io';

import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isAndroid
        ? '907682114982-g9ke4hcp10mpfb53hnbejg5q4btjpsam.apps.googleusercontent.com'
        : "907682114982-3nr2b1vgipnq5348u4fieeemr74vmuol.apps.googleusercontent.com",
    serverClientId:
        '907682114982-ja3qjtdj38f1p16q1hq9c868ga6sfn8b.apps.googleusercontent.com', // For iOS, optional for Android
    scopes: [
      'email',
      'profile',
    ],
  );

  Future<Map<String, dynamic>?> signInWithGoogle(context) async {
    try {
      // Trigger Google Sign-In
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      print("google user : $googleUser");
      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      // final String? accessToken = googleAuth.accessToken;
      print("google userid : $idToken");
      if (idToken != null) {
        final response = await http.post(
          Uri.parse('$url/user/google-auth'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        );

        if (response.statusCode == 200) {
          print("google userid body : ${response.body}");
          
          loginCalledData(response, context);
          return json.decode(response.body);
        } else {}
      } else {}
    } catch (e) {}
    return null;
  }
}

import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '442849932576-2qqrgh9mdpi0r5cdkt2nvfln0ogaqepn.apps.googleusercontent.com',
    serverClientId:'442849932576-9pjdtqgiedibia1apagj12nbi22mgb56.apps.googleusercontent.com', // For iOS, optional for Android
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
        print('Sign-in canceled');
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      // final String? accessToken = googleAuth.accessToken;

      if (idToken != null) {
        final response = await http.post(
          Uri.parse('http://192.168.1.10:5000/api/v1/user/google-auth'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        );

        if (response.statusCode == 200) {
          loginCalledData(response, context);
          return json.decode(response.body);
        }
        ;
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
    }
    return null;
  }
}

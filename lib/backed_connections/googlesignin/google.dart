
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '442849932576-9pjdtqgiedibia1apagj12nbi22mgb56.apps.googleusercontent.com', // For iOS, optional for Android
     scopes: ['email', 'profile', ],
  );

  Future<void> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Sign-in canceled');
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      // final String? accessToken = googleAuth.accessToken;

      if (idToken != null) {
        // Send ID token to your Node.js backend
        final response = await http.post(
          Uri.parse('http://192.168.1.10:5000/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken, }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('Backend response: $data');
          // Handle the response (e.g., store JWT, navigate to home screen)
        } else {
          print('Backend error: ${response.body}');
        }
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
    }
  }
}







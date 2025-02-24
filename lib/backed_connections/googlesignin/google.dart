// import 'package:flutter_application_code_stakeplot/signInOut/googleSignIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    try {
      // 1️⃣ Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled login

      // 2️⃣ Get authentication credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3️⃣ Sign in with Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) return;

      // 4️⃣ Get ID Token from Firebase
      final String? idToken = await user.getIdToken();

      if (idToken == null) return;

      // 5️⃣ Send ID Token to Backend for Verification
      final response = await http.post(
        Uri.parse("${url}/auth/verify-google-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jwtToken = data["token"]; // Receive JWT from backend

        print("JWT Token: $jwtToken"); // Store this for API calls
      } else {
        print("Authentication failed: ${response.body}");
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
    }
  }
}
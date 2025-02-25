// // import 'package:flutter_application_code_stakeplot/signInOut/googleSignIn.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class AuthService {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<void> signInWithGoogle() async {
//     try {
//       // 1️⃣ Trigger Google Sign-In
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return; // User canceled login

//       // 2️⃣ Get authentication credentials
//       final GoogleSignInAuthentication googleAuth =await googleUser.authentication;

//       // 3️⃣ Sign in with Firebase
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final UserCredential userCredential =
//           await _auth.signInWithCredential(credential);

//       final User? user = userCredential.user;
//       if (user == null) return;

//       // 4️⃣ Get ID Token from Firebase
//       final String? idToken = await user.getIdToken();

//       if (idToken == null) return;

//       // 5️⃣ Send ID Token to Backend for Verification
//       final response = await http.post(
//         Uri.parse("${url}/auth/verify-google-token"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"token": idToken}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final jwtToken = data["token"]; // Receive JWT from backend

//         print("JWT Token: $jwtToken"); // Store this for API calls
//       } else {
//         print("Authentication failed: ${response.body}");
//       }
//     } catch (e) {
//       print("Error during Google Sign-In: $e");
//     }
//   }
// }



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleAuthService { 
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(clientId: "563513206414-b1ceophl7jl4b1d83ivkiniqub3lr26o.apps.googleusercontent.com");

  Future<User?> signInWithGoogle() async {
     GoogleSignInAccount? googleUser;
    try {
      print(0);
      try{
        googleUser = await googleSignIn.signIn();
      }catch(e){
          print(e);
      }
      if (googleUser == null) return null; // User canceled sign-in
       print(1);
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
       print(2);

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
     

      await FirebaseAuth.instance.signInWithCredential(credential);
      print(FirebaseAuth.instance.currentUser);

      return null;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }



  void sigin(credential)async{
     final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
       print(4);
      if (user != null) {
        final idToken = await user.getIdToken();
        
        // Send the ID token to your Node.js backend
        final response = await http.post(
          Uri.parse('${url}/auth/verify-google-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        );

        if (response.statusCode == 200) {
          print("User authenticated with backend successfully!");
        } else {
          print("Failed to authenticate with backend");
        }
      }
  }

  Future<void> signOut() async
  {
    await googleSignIn.signOut();
    await _auth.signOut();
  }

}
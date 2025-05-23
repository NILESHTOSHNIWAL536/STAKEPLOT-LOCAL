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
import 'package:flutter/material.dart';
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


Future<void> handleSignInGoogle(BuildContext context) async {
  const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  String serverClientId =
      "191971007715-768tpapqjlkvcj4grgfi66md6fh3a89m.apps.googleusercontent.com";
  String mobile =
      "637011980078-s9kioj0kh6pkqebbf20h6fk45ufujsbg.apps.googleusercontent.com";
  String web =
      "637011980078-snckpvhmqpcog8jejihnr8ioonvf1n22.apps.googleusercontent.com";
  // String serverClientId =
  //     "637011980078-s9kioj0kh6pkqebbf20h6fk45ufujsbg.apps.googleusercontent.com";

  // GoogleSignIn _googleSignIn = GoogleSignIn(serverClientId:serverClientId,);

  try {
    // var googleUser = await _googleSignIn.signIn();

    // if (googleUser != null) {
    // final GoogleSignInAuthentication googleAuth =
    //     await googleUser.authentication;

    // final SharedPreferences _pref = await SharedPreferences.getInstance();
    // //  _pref.setString("accessToken", "Bearer "+accessToken);
    // _pref.setString("accessToken", "Google "+googleAuth.accessToken.toString());

    // Navigator.pushNamed(context, '/home');

    // You can use the ID Token to authenticate with your backend
    // } else {

    // }
  } catch (error) {}
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class GoogleAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     // serverClientId: "563513206414-b1ceophl7jl4b1d83ivkiniqub3lr26o.apps.googleusercontent.com",
//      serverClientId:  "442849932576-3pgo4ulesmgf3d0urk0s1m6gbam9s606.apps.googleusercontent.com",
//     scopes: ['email'],
//   );

//   Future<User?> signInWithGoogle(BuildContext context) async {
//     try {
//       // 1. Trigger Google Sign-In
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         return null; // User canceled sign-in
//       }

//       // 2. Get Google authentication credentials
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       // 3. Create Firebase credential
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//         accessToken: googleAuth.accessToken,
//       );

//       // 4. Sign in with Firebase
//       final UserCredential userCredential = await _auth.signInWithCredential(credential);
//       final User? user = userCredential.user;

//       if (user == null) {
//         return null;
//       }

//       // 5. Get Firebase ID token
//       final String? idToken = await user.getIdToken();
//       if (idToken == null) {
//         return null;
//       }

//       // 6. Send ID token to backend for verification
//        String backendUrl = '${url}/auth/verify-google-token'; // Replace with your backend URL
//       final response = await http.post(
//         Uri.parse(backendUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'idToken': idToken}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final jwtToken = data['token']; // Store JWT for API calls
//         print('JWT Token: $jwtToken');
//         return user;
//       } else {
//         print('Backend authentication failed: ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Error during Google Sign-In: $e');
//       return null;
//     }
//   }

//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
// }
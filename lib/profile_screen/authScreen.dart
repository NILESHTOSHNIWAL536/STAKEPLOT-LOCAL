import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page.dart';
import 'package:flutter_application_code_stakeplot/signInOut/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatelessWidget
{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkUserLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
         {
          return const Center(child: CircularProgressIndicator());
        }

        final shouldShowHome = snapshot.data!;
        return shouldShowHome ? HomePage() : Signin(); // Not named route
      },
    );
  }

}

  Future<bool> checkUserLoggedIn() async
  {
      final SharedPreferences _pref = await SharedPreferences.getInstance();
      bool isLoggedIn = _pref.containsKey("accessToken");
      return isLoggedIn ;
  }


  Future<Widget> checkAuthAndNavigate() async
  {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    final bool isLoggedIn = _pref.containsKey("accessToken");
    return isLoggedIn ? HomePage() : Signin();
  }
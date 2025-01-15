import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Profile/friends.dart';
import 'package:flutter_application_code_stakeplot/Profile/notifications.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/customNoti.dart';
import 'package:flutter_application_code_stakeplot/signInOut/signin.dart';
import 'package:flutter_application_code_stakeplot/signInOut/signup.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';
import 'Home_Screen/home_page.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';


FinvuManager finvuManager = FinvuManager();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    @override
  void initState() {
    super.initState();
    initPlatformState();
     initFinvuManager();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
       initialRoute: '/', 
        routes: {  
      '/': (context) =>  Signin(),   
      '/signup': (context) => SignUp(),  
      '/home': (context) => HomePage(),  
      '/Notifications': (context) => Notifications(),  
      '/TribeSearch': (context) => TribeSearch(),  
      '/Friends': (context) => Friends(),    
      '/TribeChats': (context) => TribeChats(),     
    });
  }
}

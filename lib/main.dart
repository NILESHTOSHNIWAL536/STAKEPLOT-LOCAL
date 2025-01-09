import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Profile/friends.dart';
import 'package:flutter_application_code_stakeplot/Profile/notifications.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/customNoti.dart';
import 'package:flutter_application_code_stakeplot/signInOut/signin.dart';
import 'package:flutter_application_code_stakeplot/signInOut/signup.dart';
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
     _initFinvuManager();
  }

 Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _initFinvuManager() async {
     finvuManager.initialize(
        FinvuConfig(
          finvuEndpoint: 'wss://webvwdev.finvu.in/consentapi',
          certificatePins: [
            // "3RbasfbYK4UP0GTgGKLV9ggrHbdiwzNDJ4s73Mx8AQM=",
            // "bdrBhpj38ffhxpubzkINl0rG+UyossdhcBYj+Zx2fcc="
          ],
        ),
      );

    await finvuManager.connect(); 
    var isConnected = await finvuManager.isConnected();
    print(isConnected);
    if (!isConnected) {
        isConnected = await finvuManager.isConnected();
        print(isConnected); 
    }
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
  
    });
  }
}

import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/community_screen.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/Profile/friends.dart';
import 'package:flutter_application_code_stakeplot/Profile/notifications.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/animated/splashScreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controller.dart/userController.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Emi.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Rent_Buy.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Savings.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/TripCost.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/credit_card.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/veg_nonveg.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/firebase_options.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/authScreen.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/edit_details.dart';
import 'package:flutter_application_code_stakeplot/signInOut/forgot.dart';
import 'package:flutter_application_code_stakeplot/signInOut/signin.dart';
import 'package:flutter_application_code_stakeplot/signInOut/signup.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';
import 'package:get/get.dart';
import 'Home_Screen/home_page.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'onboarding_screens/onboarding_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


FinvuManager finvuManager = FinvuManager();
late IO.Socket mainPageWebSocket;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



void main()async {
  Get.put(UserController());
  checkFirebase();
   WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
 // runApp(const MyApp());
}


void checkFirebase() async {
   WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    

  mainPageWebSocket = IO.io(urlWithLocallHost,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNewConnection()
            .build());
    mainPageWebSocket.connect();

  } catch (e) {
    print('❌ Firebase setup error: $e');
  }
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
      // WidgetsBinding.instance.addPostFrameCallback((_){
      //   oneSignalAddClickListener(context);
      // });
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       navigatorKey: navigatorKey, 
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        // useMaterial3: true,
      ),
      
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', 
 
  routes:
    {  
      '/splash': (context) =>  SplashScreen(),   
      '/': (context) =>  Signin(),   
      '/signup': (context) => SignUp(),  
      '/home': (context) => HomePage(),  
      '/Notifications': (context) => Notifications(),  
      '/comment': (context) => Notifications(),  
      '/TribeSearch': (context) => TribeSearch(),  
      '/Friends': (context) => Friends(),    
      '/TribeChats': (context) => TribeChats(), 
      '/discover': (context) =>  DiscoverAccount(),     
      '/ShareAccountLogin': (context) =>  ShareAccountLogin(),     
      '/Budget': (context) =>  Budget(),     
      '/PlotFinance': (context) =>  PlotFinance(),     
    //  '/Debt': (context) =>  DebtCalculatorApp(),     
     // '/BudgetDisplay': (context) =>  BudgetDisplay(),  
      '/CreditCard':(context) => CreditCard() ,
      '/emi':(context) => Emi() ,
      '/rent_buy':(context) => RentBuy() ,
      '/Savings':(context) => Savings() ,
      '/autoLoan':(context) => AutoLoan() ,
      '/TripCost':(context) => TripCost() ,
      '/VegNonveg':(context) => VegNonVegCalculator(),
      '/FetchTransaction':(context) => FetchTransaction() ,
      '/ForgotPassword':(context) => ForgotPassword() ,
      '/OnboardingScreen':(context) => OnboardingScreen() ,
      '/editDetails':(context) => EditDetails() ,
      '/post':(context) => Community() ,
    
      
    });
  }
}

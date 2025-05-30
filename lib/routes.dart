import 'package:flutter_application_code_stakeplot/Community_Page/community_screen.dart';
import 'package:flutter_application_code_stakeplot/Profile/friends.dart';
import 'package:flutter_application_code_stakeplot/Profile/notifications.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/animated/splashScreen.dart';
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
import 'package:flutter_application_code_stakeplot/profile_screen/edit_details.dart';
import 'package:flutter_application_code_stakeplot/signInOut/forgot.dart';
import 'package:flutter_application_code_stakeplot/signInOut/signin.dart';
import 'package:flutter_application_code_stakeplot/signInOut/signup.dart';
import 'Home_Screen/home_page.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';
import 'onboarding_screens/onboarding_screen.dart';


var routes =
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
};
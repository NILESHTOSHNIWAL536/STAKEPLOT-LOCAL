import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/community_screen.dart';
import 'package:flutter_application_code_stakeplot/coupons/rewards_overview.dart';
import 'package:flutter_application_code_stakeplot/finSpace/InterestSelectionScreen.dart';
import 'package:flutter_application_code_stakeplot/Profile/friends.dart';
import 'package:flutter_application_code_stakeplot/Profile/notifications.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/app_init/splashScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Emi.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Rent_Buy.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/all_calculators.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/credit_card.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/currency_convert.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/loan_calculator.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/veg_nonveg.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/edit_details.dart';
import 'package:flutter_application_code_stakeplot/loginservices/login_screen.dart';
import 'package:flutter_application_code_stakeplot/signInOut/onboarding_user.dart';
import 'package:flutter_application_code_stakeplot/signInOut/referral_code_screen.dart';
import '../Home_Screen/home_screen_state/home_page.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';
import '../budget/budget_detail_screen.dart';
import '../budget/budget_list_screen.dart';
import '../budget/create_budget_screen.dart';
import '../email_sync/add_credit_card_bank.dart';
import '../finance_screen/finanace_dashboard/creditCard_slider.dart';
import '../finance_screen/finanace_dashboard/index_finances.dart';
import '../onboarding_screens/onboarding_screen.dart';

var routes = {
  '/splash': (context) => const SplashScreen(),
  '/': (context) => const LoginScreen(),
  '/home': (context) => HomePage(),
  '/Notifications': (context) => const Notifications(),
  '/comment': (context) => Notifications(),
  '/TribeSearch': (context) => TribeSearch(),
  '/post': (context) => const Community(),
  '/Friends': (context) => Friends(),
  '/TribeChats': (context) => const TribeChats(),
  '/discover': (context) => DiscoverAccount(),
  '/ShareAccountLogin': (context) => ShareAccountLogin(),
  '/Budget': (context) => const Budget(),
  '/debt': (context) => CreateDebtScreen(),
  '/CreditCard': (context) => const CreditCard(),
  '/emi': (context) => const Emi(),
  '/rent_buy': (context) => const RentBuy(),
  '/user_onboarding': (context) => const UserOnboarding(),
  '/referral_code': (context) => const ReferralCodeScreen(),
  '/VegNonveg': (context) => const VegNonVegCalculator(),
  '/FetchTransaction': (context) => const FetchTransaction(),
  '/OnboardingScreen': (context) => OnboardingScreen(),
  '/editDetails': (context) => const EditDetails(),
  '/interestScreen': (context) => const InterestSelectionScreen(),
  '/currencyConverterScreen': (context) => const CurrencyConverterScreen(),
  '/rewardsOverview': (context) => RewardsOverview(),
  '/LoanCalculatorUI': (context) => LoanCalculatorScreen(),
  '/FinanceDashboard': (context) => const FinanceDashboard(),
  '/creditCard': (context) => CardDueCarousel(),
  '/addcreditCard': (context) => AddCreditCardBankScreen(),
  '/AllCalculator': (context) => AllCalculatorScreen(),
  '/create': (context) => CreateBudgetScreen(),
  '/selectBank': (context) => AddCreditCardBankScreen(),
};

var colorcodes = const {
  "Food": Color(0xFFE74C3C), // Red
  "Shopping": Color(0xFF8E44AD), // Purple
  "Travel": Color(0xFF3498DB), // Blue
  "Health": Color(0xFF2ECC71), // Green
  "Subscriptions": Color(0xFFF1C40F), // Yellow
  "Entertainment": Color(0xFFE67E22), // Orange
  "Insurance": Color(0xFF1ABC9C), // Teal
  "Emi": Color(0xFFD35400), // Dark Orange
  "Investments": Color(0xFF9B59B6), // Dark Purple
  "Untagged": Color(0xFF34495E), // Dark Gray-Blue
  "Bills": Color(0xFF16A085), // Dark Teal
  "Events": Color(0xFF27AE60), // Green
  "Personal Care": Color(0xFF2980B9), // Dark Blue
  "Services": Color(0xFFC0392B), // Dark Red
  "Current": Color(0xFF7D3C98), // Violet
  "Children": Color(0xFFF39C12), // Bright Yellow
  "Pet Care": Color(0xFF52BE80), // Soft Green
  "Sports": Color(0xFF5DADE2), // Sky Blue
  "Alcohol": Color(0xFFCD6155), // Soft Red
  "Hobbies": Color(0xFFAF7AC5), // Light Purple
  "Education": Color(0xFF45B39D), // Turquoise
  "Commerce": Color(0xFFDC7633), // Copper Orange
  "snacks": Color(0xFF5D6D7E), // Muted Blue-Gray
  "UPI": Color(0xFF5D6D7E), // Muted Blue-Gray
};

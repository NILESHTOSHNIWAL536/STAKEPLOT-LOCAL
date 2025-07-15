import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

import 'Constants/font_manager.dart';
List<Color> color = [
  Colors.blue,
  Colors.redAccent,
  Colors.green,
  Colors.amber,
  const Color.fromARGB(255, 52, 137, 137)
];

class Colorcodes {
  static Color green = Colors.green.shade700;
  static Color budgetDarkGreen = const Color.fromRGBO(0, 208, 158, 1);
  static Color budgetLightGreen = const Color.fromRGBO(223, 247, 226, 1);
  static Color mainTheamColor = const Color.fromRGBO(249, 246, 238, 1);
  static Color appBarColor = const Color.fromRGBO(249, 246, 238, 1);
  static Color suggestedHeader = const Color.fromRGBO(189, 89, 66, 0.7);
  static Color suggestedBody = const Color.fromRGBO(189, 89, 66, 0.8);
  static Color billHeader = const Color.fromRGBO(47, 72, 88, 0.7);
  static Color billBody = const Color.fromRGBO(47, 72, 88, 1);
  static Color debtHeader = const Color.fromRGBO(17, 106, 123, 0.7);
  static Color debtBody = const Color.fromRGBO(17, 106, 123, 1);
  static Color bedgetHeader = const Color.fromRGBO(180, 174, 145, 0.7);
  static Color bedgetBody = const Color.fromRGBO(180, 174, 145, 1);
  static Color textFeild = AppColors.button;
  static Color textFeildWhite =  Color.fromARGB(255, 255, 255, 255);
  // static Color textFeild=const Color.fromRGBO(231, 231, 231, 1);
  static Color moneyRed = const Color.fromRGBO(244, 123, 123, 1);
  static Color moneyOrange = const Color.fromRGBO(250, 210, 132, 1);
  static Color moneyYellow = const Color.fromRGBO(245, 237, 162, 1);
  static Color calculatorHeader = const Color.fromRGBO(17, 106, 123, 1);
  static Color calculatorBody = const Color.fromRGBO(194, 222, 220, 1);
  static Color lightTheamColor = const Color.fromRGBO(250, 249, 246, 1);
  static Color lightTheamGreyColor = const Color.fromRGBO(217, 217, 217, 1);
  static Color red = const Color.fromRGBO(233, 76, 76, 1);
  static Color black = const Color.fromRGBO(0, 0, 0, 1);
  static Color blue = const Color.fromRGBO(62, 120, 209, 1);
  static Color cardTitle = black;
  static Color white = Color.fromARGB(255, 255, 255, 255);
  static Color white1 = Color.fromRGBO(223, 216, 216, 1);
  static Color claimColor = Color.fromRGBO(238, 232, 169, 1);
  static Color chatHeader = Colorcodes.budgetDarkGreen;
  static Color chatBody = Colorcodes.budgetLightGreen;
  static Color voucher = Color.fromRGBO(238, 232, 169, 1);
  static Color cardShade1 = Color.fromRGBO(17, 106, 123, 1);
  static Color cardShade2 = Color.fromRGBO(31, 194, 225, 1);
  static Color cardShade3 = Color.fromRGBO(109, 182, 254, 1);
  static Color cardShade4 = Color.fromRGBO(65, 109, 152, 1);
  static Color cardShade5 = Color.fromRGBO(0, 57, 114, 1);
  static Color dropdown = Color.fromRGBO(35, 74, 130, 1);
  static Color borderColor = Color.fromRGBO(31, 194, 225, 1);
  static Color dropdown2 = Color.fromRGBO(8, 16, 28, 1);
  static Color graphColor1 = Color.fromRGBO(9, 48, 48, 1);
  static Color graphColor2 = Color.fromRGBO(0, 208, 158, 1);
  static Color graphColor3 = Color.fromRGBO(223, 247, 226, 1);
  static Color greyLight = Color.fromRGBO(217, 217, 217, 1);
  static Color iconBackGround = Color.fromRGBO(14, 62, 62, 1);
  static Color textColor = Color.fromRGBO(5, 34, 36, 1);
  static Color iconBackGround2 = Color.fromRGBO(209, 180, 233, 1);
  static Color cardBackGround = Color.fromRGBO(14, 62, 62, 1);
  static Color saveButton = Color.fromRGBO(35, 74, 130, 1);
  static Color redDeleteIcon = Color.fromRGBO(239, 98, 111, 1);
  static Color barGraphOrange = Color.fromRGBO(239, 189, 96, 1);
  static Color barGraphOrange3 = Color.fromRGBO(248, 236, 216, 1);
  static Color barGraphOrange2 = Color.fromRGBO(86, 135, 242, 1);
  static Color services = Color.fromRGBO(124, 87, 255, 1);
  static Color graphYaxis = Color.fromRGBO(109, 182, 254, 1);
  static Color tribeCard = Color.fromRGBO(254, 251, 251, 1);
  static Color poll1 = Color.fromRGBO(35, 74, 130, 1);
  static Color poll2 = Color.fromRGBO(8, 16, 28, 1);
  static Color reply = Color.fromRGBO(151, 71, 255, 1);
  static Color rewardCard = Color.fromRGBO(124, 87, 255, 1);
  static double elevation = 2;
  static double elevation3 = 3;
  static double elevation4 = 4;
  static double elevation5 = 5;
  static double borderRadius = 15;
  static double borderRadius10 = 10;
  static double borderRadius30 = 30.0;
  static double borderRadiusCard = 100;
  static double paddingSize = 20;
  static double paddingCard = 20;
  static double borderCut = 40;
  static double paddingCalulator = 15;
  static double paddingHorizontal = 20;
  static double fontSize = 16;
  static double fontSizeHistory = 16;
  static double paddingTopDesign = 40;
  static double paddingTopScroll = 20;
  static double space = 15;
}


List namePresent = [];

Map<String, String> imageMapForHistory = {
  "income": Categories.income, 
  "Income": Categories.income,
  "restaurant": SubCategories.restaurents,
  "hospital": SubCategories.healthCheckup,
  "travel": Categories.travel,
  "drinks": "drinks.svg",
  "events":Categories.events,
  "shopping": Categories.shopping,
  "transport": Categories.travel,
  "support": Categories.support,
  "sports": Categories.sports,
  "household": "household.svg",
  "smoke": SubCategories.tobacco,
  "gifting": "gifts.svg",
  "bills": Categories.bills,
  "snacks": Categories.snacks,
  "others": Categories.other,
  "movies": SubCategories.movies,
  "rent": "b-rent.svg",
  "clothing-shoes": "b-clothing_shoes.svg",
  "electricity": SubCategories.electricity,
  "emis": Categories.emi,
  "wifi-dth": "b-wifi_dth.svg",
  "credit bills": "b-credit.svg",
  "credit bill": "b-credit.svg",
  "personalCare": Categories.personalCare,
  "theatre": "b-movie.svg",
  "repairs": "b-repairs.svg",
  // "electronics": BudgetSubCategories.listofSubCategories['electronics']?? SubCategories.electronics,
  "beauty": "b-beauty.svg",
  "subscriptions": Categories.subscription,
  "skin care": "b-skincare.svg",
  "restaurants": "b-restaurants.svg",
  "pet care": Categories.petCare,
  "emi": Categories.emi,
  "food": Categories.food,
  "health":Categories.health,
  "hobbies":Categories.hobbies,
  "trips": "b-trips.svg",
  "insurance":Categories.insurance,
  "miscellaneous": "b-miscellaneous.svg",
  "untagged": Categories.untagged ,
  "accessories": "b-accessories.svg",
  "investments": Categories.investments,
  "education": Categories.education,
  "alcohol": Categories.alcohal,
  "personal care": Categories.personalCare,//
  "services": Categories.services,
  "personal transfer received":Categories.personalTransferReceived,
  "personal transfer":Categories.personalTransfer,
  "groceries":Categories.groceries,
  "current": Categories.current,
  "children": Categories.children,
  "commerce": Categories.commerce,
  "entertainment": Categories.entertainment,//
};

class StringConstant {
  static String homeTextDes =
      "Hey mate , Are you worried about your personal Finance ? We got You covered ! Here are some tools which will make your life Better!";
  static String calculatorDis =
      "Calculation of your budget now easy peasy with Stake plot’s calculator!!";
  static String calculator = "Calculator";
  static String splitDis = "Always Go Dutch when you are a student!";
  static String split = "Split Bills";
  static String targetDis =
      "Set Target’s that help you stay Up with your finance!";
  static String target = "Set Target’s";
  static String remainders = "Check your due and clear them off!";
  static String resetpassword =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ";
  static String chatText =
      "Its pretty much lonely over here… Try adding your friends and stay connected..!!";
  static String tribeText =
      "Connect with your friends to see whats cooking..!!";
  
  static String otpText = "Enter the OTP sent to your registered email address";

  static String onboading_1 = "Welcome to Expense Manager !";
  static String onboading_2 =
      "Are You to Ready To take control of your finance?";

  static String allTransactions = "All";
  static String pollTransactions = "Pool";
}

class svgIconPath {
  static String notifications = "assets/images/notifications.svg";
  static String rupees = "assets/images/Add_round.svg";
  static String friends = "assets/img/spiltBills.svg";
  static String reward = "assets/images/Add_round.svg";
  static String account = "assets/images/Add_round.svg";
  static String savedList = "assets/images/Saved.svg";
  static String userAvatar = "assets/images/Add_round.svg";
  static String search = "assets/images/Search.svg";
  static String message = "assets/images2/messages.svg";
  //  static String  send1="assets/images/send1.jpg";
  //  static String  send2="assets/images/Debts.svg";
  //  static String  send3="assets/images/Bills.svg";
  //  static String  send4="assets/images/payments.svg";

  // send Tab Screen
  static String send1 = "assets/img/imgs/budgets.svg";
  static String send2 = "assets/img/imgs/debts.svg";
  static String send3 = "assets/img/imgs/bills.svg";
  static String send4 = "assets/img/imgs/schedulePayments.svg";
  //  static String  send1="assets/images/Plot-Budget.svg";
  //  static String  send2="assets/images/Plot-Debts.svg";
  //  static String  send3="assets/images/Plot-Bills.svg";
  //  static String  send4="assets/images/Plot-Payments.svg";

  //Home Screens
  static String comment = "assets/images/comment.svg";
  static String money = "assets/img/Tokens.svg";
  static String target = "assets/img/targets.svg";
  static String splitBill = "assets/img/spiltBills.svg";
  static String calculator = "assets/img/calculator.svg";
  static String earnings = "assets/img/Earnings.svg";
  static String settingUser = "assets/img/ReportFriend.svg";
  static String share = "assets/images2/share.svg";
  static String sendMsg = "assets/images2/share.svg";

  //bottom navigations
  static String bottom1 = "assets/img/imgs/Home.svg";
  static String bottom2 = "assets/img/imgs/Plot.svg";
  static String bottom3 = "assets/img/imgs/Community.svg";
  static String bottom4 = "assets/img/imgs/Hub.svg";
  static String google =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png";
}

Widget textStyleDesign(String str, color, double size, context) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Colorcodes.borderRadius - 10),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Colorcodes.borderRadius - 10),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colorcodes.cardShade3,
            Colorcodes.dropdown,
            // Colorcodes.cardShade2,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 15),
      child: Text(
        str,
        style: FontManager().getTextStyle(context,
            fontSize: size, color: Colorcodes.white, lWeight: FontWeight.bold),
      ),
    ),
  );
}

String doubleToFixed(String s,[int f=0]) {
  try {
    return ((double.parse(s)).toStringAsFixed(f)).toString();
  } catch (e) {
    return s;
  }
}

int getSteps(max, div) {
  try {
    return int.parse(doubleToFixed((max / div).toString()));
  } catch (e) {
    return 1;
  }
}



class BankText
{
    static  String text1="No bank account found";
    static  String text2="It could be due to any of the following reasons";
    static  String text3="The bank accounts aren't connected to your primary number,";
    static  String text4="Joint accounts are currently not supported";
    static  String text5="Bank Servers are not responding at the moment, you can try later";
    static  String text6="Bank Accounts are either dormant or deactivated";
    static String linkNow="Please tap on 'Link Now' to link your bank account";
    static String linkNowproceeding= "Your selected bank is not yet linked. Before proceeding, ensure that the specified bank is linked";
    static String checkNow="No account selected";
    static String checkNowproceeding= "Please select atleast one account to proceed";
    static String nextFetchTime= "Hang tight! Fetching will take ~10 minutes.";
}




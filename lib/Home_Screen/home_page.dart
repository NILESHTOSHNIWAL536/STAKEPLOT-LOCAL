import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/expanded_finance.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/donut_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/manual_transaction.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/pending_users.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/number_picker.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/community_screen.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transactions_graph.dart';
import 'package:flutter_application_code_stakeplot/NavigatorScreens/userNavigator.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/controller.dart/userController.dart';
import 'package:flutter_application_code_stakeplot/customNoti.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:flutter_application_code_stakeplot/userAvatar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
//import 'dart:io';
RxBool sectionReached = false.obs;
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    oneSignalAddClickListener(context);
    initializeData();
  }

  void initializeData()   
  {
    check(context, "homeScreen");
    getBankAccounts();
    getCategoryData();
    getAllTransaction(context);
    getPost();
    getAck();
    getBudget();
    getUserInfomations();
    getUserLend(context);
    getBudget();
    getHiddenTransactions(context);
    getCategoryData();
    getRemainders(context);
    getNotifications(context);
    sectionReached.value=false;
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
   

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();
  final GlobalKey _transactionHistoryKey = GlobalKey();
  var setDonectChat = false.obs; 
  var getHistory = false.obs; 
  

  @override
  void initState()
  {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      bottomNavigationBar: BottomNavigations(data: 0),
      backgroundColor: AppColors.backgroundColor,
      appBar:getAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              Nextfetch(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.23,
                child: NumberPickerScreen(),
              ),
            
              const SizedBox(
                height: 10,
              ),
              
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.51,
                child: FinancePage(
                  scrollController: scrollController,
                  transactionHistoryKey:_transactionHistoryKey ,
                ),
              ),
          
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.16,
                child: Manualtransaction(),
              ),
    
               SizedBox(
                height: MediaQuery.of(context).size.height * 0.46,
                child: TransactionGraph(),
              ),
              
              UserListScreen(),
      
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Obx(() => setDonectChat.value
                    ? DoughnutChartExample()
                    : DoughnutChartExample()),
              ),
            
               TransactionHistory(key: _transactionHistoryKey,),
            
    
            ],
          ),
        ),
      ),
    );
  }
String _getTimeBasedGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return "Good morning";
  } else if (hour < 16) {
    return "Good afternoon,";
  } else {
    return "Good evening,";
  }
}





  AppBar getAppBar(){
    return  AppBar(
        backgroundColor: AppColors.backgroundColor,
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: (){
                   navigatorToMyOwnPage(context);
                },
                child: UserAvatar(url: avatar.value, width: 15, height: 15)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textStyle(
                      context: context,
                      text: _getTimeBasedGreeting(),
                      fontWeight: FontWeight.w500,
                      fontsize: 15),
                  Obx(() => textStyle(
                      context: context,
                      text: userName.value,
                      fontWeight: FontWeight.bold,
                      fontsize: 15))
                ],
              )
            ],
          ),
          Spacer(),
          NotificationsBudget(
            child: Text(""),
          ),
        ],
      );
  }

   void _onScroll() {

    scrollController.addListener(() {
          if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50)
          {
                getAllTransactionHistory(context,false,false); // Fetch next page
          }
    });
  }

}




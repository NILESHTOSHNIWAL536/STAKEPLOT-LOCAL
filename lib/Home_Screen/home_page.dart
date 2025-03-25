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

    initializeData();
  }

  void initializeData()   
  {
    check(context, "homeScreen");
    getBankAccounts();
    getAllTransaction(context);
    getTrending();
    
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
  final GlobalKey _transactionHistoryKey2 = GlobalKey();


  // Assuming setDonectChat and getHistory are RxBool from GetX
  var setDonectChat = false.obs; 
 // Example, replace with your actual state
  var getHistory = false.obs; 
 // Example, replace with your actual state
    void _onScroll() {
    if (_transactionHistoryKey.currentContext != null) {
      final RenderBox renderBox =
          _transactionHistoryKey.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
     
      if ((position.dy + renderBox.size.height-screenHeight) <= 1600 && !sectionReached.value)
       {
            //  navigateToNextPage(context);
            //   sectionReached.value=true;
       }
    }
  }

 

    @override
  void initState() {
    super.initState();
    // sectionReached.value=false;
    scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      bottomNavigationBar: BottomNavigations(
        data: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      // floatingActionButton: IconButton(onPressed: (){

      // }, icon: Icon(Icons.add,color: AppColors.primaryColor,)) ,
      appBar: AppBar(
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
                      text: "Hello",
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            // controller: _scrollController,
            children: [
              // Bank Account Container
              Nextfetch(),
              
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.23,
                child: NumberPickerScreen(),
              ),
             // const SizedBox(height: 10),

              // Finance Chart
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
            
              SizedBox(
                child: TransactionHistory(key: _transactionHistoryKey,),
              ),

            ],
          ),
        ),
      ),
    );
  }
}


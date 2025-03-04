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
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
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

  void initializeData() {
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
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _transactionHistoryKey = GlobalKey();
  final GlobalKey _transactionHistoryKey2 = GlobalKey();


   HomeScreen() {
    _scrollController.addListener(() {
      // print("Scroll position: ${_scrollController.offset}");
    });
  }

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
      if ((position.dy + renderBox.size.height-650) <= screenHeight && !sectionReached.value) {
        _navigateToNextPage();
        setState(() {
          sectionReached.value=true;
        });
      }
    }
  }

  void _navigateToNextPage() {
    // Navigate to your desired page
    Navigator.push(
  context,
  PageTransition(
    type: PageTransitionType.bottomToTop,
    alignment: Alignment.bottomCenter,
    duration: const Duration(milliseconds: 2000),  // Increase duration
    curve: Curves.easeInOut,  // Smooth transition
    child: TransactionHistory(pageTransition: true,),
    isIos: true,
  ),
);
  }

    @override
  void initState() {
    super.initState();
    sectionReached.value=false;
    _scrollController.addListener(_onScroll);
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
              UserAvatar(url: avatar.value, width: 15, height: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textStyle(
                      context: context,
                      text: "Hello..",
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
          controller: _scrollController,
          child: Column(
            //controller: _scrollController,
            children: [
              // Bank Account Container
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.27,
                child: NumberPickerScreen(),
              ),
              const SizedBox(height: 10),

              // Finance Chart
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: FinancePage(
                  scrollController: _scrollController,
                  transactionHistoryKey:_transactionHistoryKey2 ,
                ),
              ),
          
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.16,
                child: Manualtransaction(),
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

// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/expanded_finance.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/finance_chart.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/donut_chart.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/manual_transaction.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/pending_users.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/number_picker.dart';
// import 'package:flutter_application_code_stakeplot/Community_Page/community_screen.dart';
// import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
// import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/controller.dart/userController.dart';
// import 'package:flutter_application_code_stakeplot/customNoti.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:get/get.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// //import 'dart:io';

// class HomePage extends StatefulWidget {
//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final UserController userController = Get.find<UserController>();

//   @override
//   void initState() {
//     super.initState();
//     initializeData();
//   }

//   void initializeData() {
//     check(context, "homeScreen");
//     getAllTransaction(context);
//     getTrending();
//     getPost();
//     getAck();
//     getBudget();
//     getUserInfomations();
//     getUserLend(context);
//     getBudget();
//     getHiddenTransactions(context);
//     getSummary();
//     getCategoryData();
//     getRemainders(context);
//     getAutoMationsTransactionsCustom("date", context);
//     userController.fetchUserInfo();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return HomeScreen();
//   }
// }

// class HomeScreen extends StatefulWidget {
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final ScrollController _scrollController = ScrollController();

//   final GlobalKey _transactionHistoryKey = GlobalKey();
//   HomeScreen() {
//     _scrollController.addListener(() {
//       // print("Scroll position: ${_scrollController.offset}");
//     });
//   }

//   bool _isFullPage = false;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_handleScroll);
//   }

//   void _handleScroll() {
//     if (_transactionHistoryKey.currentContext == null) return;

//     final RenderBox? renderBox =
//         _transactionHistoryKey.currentContext!.findRenderObject() as RenderBox?;
//     if (renderBox == null) return;

//     final position = renderBox.localToGlobal(Offset.zero);
//     final screenHeight = MediaQuery.of(context).size.height;
//     final transactionHistoryTop = position.dy;

//     // Snap to Transaction History when it's near the top
//     if (!_isFullPage &&
//         transactionHistoryTop > 0 &&
//         transactionHistoryTop < screenHeight * 0.1) {
//       _scrollController.animateTo(
//         _scrollController.offset + transactionHistoryTop - 50,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }

//     // Expand to full-screen when scrolled further
//     if (!_isFullPage &&
//         _scrollController.offset <
//             _scrollController.position.maxScrollExtent * 0.9) {
//       setState(() {
//         _isFullPage = true;
//       });
//     }

//     // Collapse when scrolled back up
//     if (_isFullPage && _scrollController.offset < screenHeight * 0.5) {
//       setState(() {
//         _isFullPage = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_handleScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: BottomNavigations(
//         data: 0,
//       ),
//       backgroundColor: AppColors.backgroundColor,
//       // floatingActionButton: IconButton(onPressed: (){

//       // }, icon: Icon(Icons.add,color: AppColors.primaryColor,)) ,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         automaticallyImplyLeading: false,
//         actions: [
//           Row(
//             children: [
//               AvatarProfileImage(url: avatar.value, width: 15, height: 15),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   textStyle(
//                       context: context,
//                       text: "Hello..",
//                       fontWeight: FontWeight.w500,
//                       fontsize: 15),
//                   textStyle(
//                       context: context,
//                       text: userName.value,
//                       fontWeight: FontWeight.bold,
//                       fontsize: 15)
//                 ],
//               )
//             ],
//           ),
//           Spacer(),
//           NotificationsBudget(
//             child: Text(""),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         child: _isFullPage
//             ? _buildExpandedTransactionHistory()
//             : _buildNormalView(),
//       ),
//     );
//   }

//   Widget _buildNormalView() {
//     return SingleChildScrollView(
//       controller: _scrollController,
//       child: Column(
//         //controller: _scrollController,
//         children: [
//           // Bank Account Container
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.27,
//             child: NumberPickerScreen(),
//           ),
//           const SizedBox(height: 10),

//           // Finance Chart
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.5,
//             child: FinancePage(
//               scrollController: _scrollController,
//               transactionHistoryKey: _transactionHistoryKey,
//             ),
//           ),
//           //const SizedBox(height: 20),

//           // Manual Transaction Container
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.16,
//             child: Manualtransaction(),
//           ),
//           //const SizedBox(height: 20),

//           // Pending Users
//           UserListScreen(),

//           //const SizedBox(height: 20),

//           // Doughnut Chart
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.5,
//             child: Obx(() => setDonectChat.value
//                 ? DoughnutChartExample()
//                 : DoughnutChartExample()),
//           ),
//           //const SizedBox(height: 20),

//           // Transaction History
//           // SizedBox(
//           //   // height: MediaQuery.of(context).size.height * 0.8,
//           //   child: Obx(() => getHistory.value
//           //       ? TransactionHistory(key: _transactionHistoryKey)
//           //       : TransactionHistory(key: _transactionHistoryKey)),
//           // ),
//           SizedBox(
//             child: TransactionHistory(key: _transactionHistoryKey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExpandedTransactionHistory() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       height: MediaQuery.of(context).size.height,
//       child: SingleChildScrollView(
//         controller: _scrollController,
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             TransactionHistory(key: _transactionHistoryKey),
//           ],
//         ),
//       ),
//     );
//   }
// }

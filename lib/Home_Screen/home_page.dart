import 'package:flutter/material.dart';
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
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
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
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:get/get.dart';

//import 'dart:io';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    check(context, "homeScreen");
    getAllTransaction(context);
    getTrending();
    getPost();
    getAck();
    getBudget();
    getUserInfomations();
    getUserLend(context);
    getBudget();
    getSummary(); 
    userController.fetchUserInfo();
  }


  @override
  Widget build(BuildContext context) {
    return HomeScreen();
}

}


class HomeScreen extends StatelessWidget {
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:  BottomNavigations(data: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListView(
            children: [
              // Top Notifications Row
              NotificationsBudget(
                child: Text(""),
              ),

              setPinForAccountHide(context),

              // Bank Account Container
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.24,
                child: NumberPickerScreen(),
              ),
              //const SizedBox(height: 10),

              // Finance Chart
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: const FinanceChartApp(),
              ),
              //const SizedBox(height: 20),

              // Manual Transaction Container
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.16,
                child: Manualtransaction(),
              ),
              //const SizedBox(height: 20),

              // Pending Users
              UserListScreen(),
              //const SizedBox(height: 20),

              // Doughnut Chart
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: DoughnutChartExample(),
              ),
              //const SizedBox(height: 20),

              // Transaction History
              SizedBox(
                // height: MediaQuery.of(context).size.height * 0.8,
                child: TransactionHistory(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
 Widget setPinForAccountHide(context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
           mainAxisAlignment: MainAxisAlignment.end,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
                const SizedBox(height: 10),
               Obx(()=> cupertinoPin.value=="0"? InkWell(
                  onTap: (){
                      showModalBottomSheet(context: context, 
                                              backgroundColor: Colorcodes.appBarColor,
                                            builder: (context) {
                                                  return setPassword(context);
                          },);
                  },
                child: Container(
                  color: Colorcodes.textFeild,
                  padding: const EdgeInsets.all(8.0),
                  child: textStyle(text: "Set pin",context: context,fontsize: 10,fontWeight: FontWeight.bold),
                )):SizedBox.shrink()),
                const SizedBox(height: 10),
           ],
        ),
      );
  }


Widget setPassword(context){
        TextEditingController controller=TextEditingController();

       return Container(
          width: MediaQuery.of(context).size.width,
          height:  MediaQuery.of(context).size.height/1.2,
          padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
          child: Column(
               children: [
                      TextFeildWidget(textEditingController: controller, heading: "Set Pin", keyBoard: TextInputType.visiblePassword, lableText: "Set Pin"),
                      SizedBox(height: 10,),
                      InkWell(
                           onTap: (){
                                  setPasswordApiCalled(context,controller.text);
                           },
                          child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                ),
                               child: Text("Set Password click me")
                            ),
                      ),
               ],
          ), 
       );
  }



}

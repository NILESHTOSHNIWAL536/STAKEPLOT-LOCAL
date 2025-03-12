
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'dart:async';


String bankImage =
    "https://static.vecteezy.com/system/resources/thumbnails/023/364/757/small_2x/3d-illustration-of-bank-building-and-money-bag-png.png";


class ShareAccountLogin extends StatefulWidget {
  bool flag = false;
  ShareAccountLogin({Key? key, this.flag = false}) : super(key: key);

  @override
  _ShareAccountLoginState createState() => _ShareAccountLoginState();
}

class _ShareAccountLoginState extends State<ShareAccountLogin> {
  late ScrollController _scrollController;
  Timer? _timer;
  bool _isExpanded = false;
  double h = 28;
  double w = 28;

  final List<Map<String, dynamic>> autoScrollItems = [
    {'icon': Icons.account_balance_wallet, 'text': 'Budgeting'},
    {'icon': Icons.business, 'text': 'Management'},
    
    {'icon': Icons.trending_up, 'text': 'Growth'},
    {'icon': Icons.people, 'text': 'Community'},
    
  ];

  @override
  void initState() {
    super.initState();
    if (widget.flag) getLinkedAccountInfo();
    _scrollController = ScrollController();
    _startAutoScroll();
    
  }

 void _startAutoScroll() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        double delta = 4.0; // Speed of the auto-scroll

        // If we've reached the end, reset to the start, but with a small delay
        if (currentScroll + delta >= maxScroll) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollController.jumpTo(0.0);
          });
        } else {
          // Smoothly move the scroll position
          _scrollController.jumpTo(currentScroll + delta);
        }
      }
    });
  }

 

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: true,
      bottomSheet: bottomSheet(context),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: AppColors.backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 60, 10, 30),
              child: Container(
                height: 60,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: autoScrollItems.length,
                  
                  itemBuilder: (context, index) {
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mt,
                          borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              autoScrollItems[index]['icon'],
                              size: 20.0,
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              autoScrollItems[index]['text'],
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            //Asset Image
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child:
                  AvatarProfileImage(url: Sign.transform, width: 4, height: 4),
            ),
    
            Text(
              "Transform your money habits",
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.bg1),
            ),
            Text(
              "with stakeplot",
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.bg1),
            ),
            SizedBox(
              height: 15,
            ),

            Text(
              "Fuel Your Dreams.Fuel Your Wallet:Your Journey To Financial Success Starts Here",
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w200, fontSize: 10, color: AppColors.bg1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: InkWell(
                  onTap: () {
                   
                    if (!widget.flag) initFinvuManager(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            widget.flag ? const DiscoverAccount() : MobileNumber(),
                      ),
                    );
                  },
                  child: getButton(
                      context,
                      widget.flag
                          ? getFetch.value
                              ? "Loading..."
                              : "Fetch Bank Account"
                          : "Start now")),
            ),
          ],
        ),
      ),
    );
  }


  Widget bottomSheet(BuildContext context) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeInOut,
    width: MediaQuery.of(context).size.width,
    constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height / 14,
      maxHeight: _isExpanded
          ? MediaQuery.of(context).size.height / 2 // Expanded height
          : MediaQuery.of(context).size.height / 14, // Collapsed height
    ),
    decoration: const BoxDecoration(
      color: AppColors.rbi1,
    ),
    child: SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: AppColors.rbi1,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //AvatarProfileImage(url: Sign.india, width: w, height: h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "Connect your bank accounts using AA services",
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w500,
                                fontSize: 12,
                                color: AppColors.bg1),
                          ),
                        ),
                        // Text(
                        //   "India",
                        //   style: FontManager().getTextStyle(context,
                        //       lWeight: FontWeight.w500,
                        //       fontSize: 14,
                        //       color: AppColors.bg1),
                        // ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: AvatarProfileImage(
                    url: _isExpanded ? Sign.minimise : Sign.maximise,
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: AppColors.rbi1,
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What are Account Aggregators?",
                    style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.bg1),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Account Aggregators are RBI-authorized institutions that securely collect and share your financial information with us.',
                    style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w400,
                              fontSize: 12,
                              color: AppColors.bg1),
                  ),
                  const SizedBox(height: 5.0),
                   Text("Supported by:",style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.bg1),),
                ],
              ),
            ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: AppColors.rbi2,
            ),
            child: Row(
              children: [
                AvatarProfileImage(url: Sign.protection, width: 40, height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Secure & Quick Sharing",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      "via RBI-authorised Account Aggregator Services",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}

Widget getButton(context, str,[color=AppColors.primaryColor,textColor=AppColors.bg5]) {
  return Container(
    width: MediaQuery.of(context).size.width / 1.1,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(24)),
    child: Center(
      child: Text(
        str,
        style: FontManager().getTextStyle(context,
            lWeight: FontWeight.bold, fontSize: 15, color:textColor ),
      ),
    ),
  );
}


Widget getspinner(context, str,[color=AppColors.primaryColor,textColor=AppColors.bg5]) {
  return Container(
    width: MediaQuery.of(context).size.width / 1.1,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(24)),
    child: Center(
      child: Spinner(color: Colorcodes.white,size: 20,)
    ),
  );
}
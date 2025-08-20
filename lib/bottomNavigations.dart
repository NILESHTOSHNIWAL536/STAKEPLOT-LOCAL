import "package:flutter/cupertino.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Community_Page/community_screen.dart";
import "package:flutter_application_code_stakeplot/Constants/app_styles.dart";
import "package:flutter_application_code_stakeplot/Constants/colors.dart";
import "package:flutter_application_code_stakeplot/controllers/controllerManagement.dart";
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/helper.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/Home/home_page.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart";
import "package:flutter_application_code_stakeplot/finSpace/welcomeScreen.dart";
import "package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart";
import "package:flutter_application_code_stakeplot/profile_screen/profile_screen.dart.dart";
import "package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart";
import "package:get/get.dart";
import "package:page_transition/page_transition.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavigations extends StatefulWidget {
  int data;
  final VoidCallback? onCommunityDoubleTap;
  final VoidCallback? onHomeDoubleTap;
  BottomNavigations({Key? key, required this.data, this.onCommunityDoubleTap, this.onHomeDoubleTap}) : super(key: key);

  @override
  _BottomNavigationsState createState() => _BottomNavigationsState();
}

class _BottomNavigationsState extends State<BottomNavigations> {
  final List<String> _tabNames = ['Home', 'Finance', 'Community', 'Profile'];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (widget.data >= 0 && widget.data < _tabNames.length) {
          ScreenTimeTracker().switchTab(_tabNames[widget.data]);
         
        }
        handleWidgetNavigation();
      } catch (e) {
       
      }
    });
  }

  void handleWidgetNavigation() async {
   
    try {
      // Android intent
      final route =
          await SystemChannels.platform.invokeMethod('getInitialRoute');
   
      if (route != null && route is Map) {
        if (route['navigate_to_tab'] == 'finance') {
       
          setState(() {
            widget.data = 1;
          });
          ScreenTimeTracker().switchTab(_tabNames[1]);
          pushName(PlotFinance());
         
        }
      }

      // iOS deep link (for future support)
      const channel = MethodChannel('com.stakeplot.pfa/navigation');
      channel.setMethodCallHandler((call) async {
       
        if (call.method == 'navigateToFinance') {
          setState(() {
            widget.data = 1;
          });
          ScreenTimeTracker().switchTab(_tabNames[1]);
          pushName(PlotFinance());
          
        }
      });
    } catch (e) {
     
    }
  }

  @override
  Widget build(BuildContext context) {
    //int selectedIndex = 0;
       final userController = ControllerManagement.userController;

    return Container(
      height: Colorcodes.paddingSize * 2.5,
      color:AppColors.backgroundColor,
     // padding: const EdgeInsets.only(left: 3.0, right: 3.0, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          getContainer(NavBarIcons.home, 0),
          getContainer(NavBarIcons.screen2, 1),
          if (sizeRoom)
            getContainer(
              'assets/images/room.svg',
              2,
            ),
          getContainer(
            NavBarIcons.community,
            sizeRoom ? 3 : 2,
          ),
          getContainer(
            svgIconPath.bottom4,
            sizeRoom ? 4 : 3,
          ),
        ],
      ),
    );
  }

  Widget imageurl(String url, int index) {
    bool isSelected = widget.data == index;
    String iconPath = url; // Default to the passed url
   UserController userController=ControllerManagement.userController;
    // Toggle icons based on selection
    if (url == NavBarIcons.home) {
      iconPath = isSelected ? NavBarIcons.home : NavBarIcons.home1;
    } else if (url == NavBarIcons.screen2) {
      iconPath = isSelected ? NavBarIcons.screen21 : NavBarIcons.screen2;
    } else if (url == NavBarIcons.community) {
      iconPath = isSelected ? NavBarIcons.community : NavBarIcons.community1;
    } else if (url == 'assets/images/room.svg') {
      iconPath = url;
    } else if (url == svgIconPath.bottom4) {
      iconPath = avaterUrlPath(userController.userName.value);
    }
    bool ifAvatar = index == 3 || index == 4;

    return Center(
      child: ifAvatar? Obx(()=> AvatarProfile(name:userController. userName.value, width: 5, height: 14,background: userController.avatarBackGround.value))
          
          : SvgPicture.asset(
              iconPath,
              width: MediaQuery.of(context).size.width /30, // Adjust the multiplier as needed
              height: MediaQuery.of(context).size.height /30, // Adjust the multiplier as needed
              // colorFilter: isSelected
              //     ? ColorFilter.mode(AppColors.finSpaceColor, BlendMode.srcIn)
              //     : ColorFilter.mode(
              //         AppColors.bg1, BlendMode.srcIn),
            ),
    );
  }

  Widget getContainer(url, i) {
    bool isSelected =
        widget.data == i; // Check if the current index is selected
int communityIndex = sizeRoom ? 3 : 2;
    return GestureDetector(
      //  onDoubleTap: () {
      //   if (i == communityIndex && isSelected) {
      //     // Double-tap on Community tab when active
      //     widget.onCommunityDoubleTap?.call();
      //   }
      // },
      onLongPress: () async {
        if (i == 2 && widget.data != i)
          pushName(TribeChats(), true);
        else if (i == 0) {
          // Handle long press for index 0
        } else if (i == 3 && widget.data != i) {}
      },
      onTap: () {
        if (i == 0 && isSelected) {
          // Single tap on already selected Home tab
          HapticFeedback.lightImpact();
          widget.onHomeDoubleTap?.call(); // Call the Home scroll-to-top callback
          return;
        }
         if (i == communityIndex && isSelected) {
          // Single tap on already selected Community tab
          HapticFeedback.lightImpact();
          widget.onCommunityDoubleTap?.call();
          return;
        }
      
        if (widget.data == i) return;
         HapticFeedback.heavyImpact();
        try {
          String tabName = _tabNames[i];
          ScreenTimeTracker().switchTab(tabName);
          // added
          
         
          if (i == 0)
            pushName(HomePage());
          else if (i == 1) pushName(PlotFinance());
        
           else if (i == 2) pushName(ControllerManagement.userController.interestedTags.isEmpty? WelcomeScreen():Community());
           else if (i == 3) pushName(ProfileScreenDart());

          setState(() {
            widget.data = i; // Update selected index
          });
        } catch (e) {
         
        }
      },
      child: Container(
        child: imageurl(url, i),
      ),
    );
  }

void pushName(Widget widgetName, [bool flag = false]) {
  final route = PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => widgetName,
  );

  if (flag) {
    Navigator.push(context, route);
  } else {
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }
}
}


Widget showUserData(BuildContext context){
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  UserController userController=ControllerManagement.userController;

  List<String> loginUsers = loginUsersList.keys.toList();
  loginUsers.remove(userController.userName.value);
  loginUsers.insert(0, userController.userName.value);

  return Container(
    width: width,
    height: loginUsers.length == 0 ? height / 5 : height / 2.7,
    decoration: BoxDecoration(
      color: Colorcodes.budgetLightGreen,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: width / 8,
          height: 4,
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: Colorcodes.white, borderRadius: BorderRadius.circular(10)),
        ),
        loginUsers.length == 0
            ? SizedBox.shrink()
            : Container(
                width: width / 1.1,
                height:
                    loginUsers.length == 1 ? height / 5.7 / 2 : height / 5.7,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    color: Colorcodes.white,
                    borderRadius: BorderRadius.circular(20)),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    String name = loginUsers[index];
                    dynamic user = loginUsersList[name];

                    return InkWell(
                      onTap: () async {
                           clearGetX();
                        TextEditingController emailController =TextEditingController(text: user['email']);
                        TextEditingController passwordController =
                            TextEditingController(text: user['password']);
                        final SharedPreferences _pref =
                            await SharedPreferences.getInstance();
                        String userId = user['accessToken'] ?? user['email'];
                       
                        await ScreenTimeTracker().setUser(userId);
                        _pref.remove("accessToken").then((_) {
                          _pref.setString("accessToken", user['accessToken']);
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/', (Route<dynamic> route) => false);
                          Navigator.pushReplacementNamed(context, '/home');
                        }).catchError((error) {
                        });

                     
                        loginUser(emailController, passwordController, context);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        child: Row(
                          children: [
                            AvatarProfileImage(
                                url: user['avatar'], width: 16, height: 16),
                            Container(
                              width: width / 1.8,
                              child: Text(
                                user['name'],
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colorcodes.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Obx(() => user['name'] ==userController.userName.value
                                ? Container(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.check_circle_outlined,
                                      color: Colorcodes.budgetDarkGreen,
                                    ),
                                  )
                                : SizedBox.shrink()),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: loginUsers.length,
                ),
              ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/');
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 10),
              child: Row(
                children: [
                  CircleAvatar(
                      backgroundColor: Colorcodes.white,
                      child: AvatarProfileImage(
                          url: svgIconPath.account, width: 10, height: 10)),
                  const SizedBox(
                    width: 20,
                  ),
                  Text("Add StakePlot Account",
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Colorcodes.black)),
                ],
              ),
            ),
          ),
        ),
        logoutWidget(context, true),
      ],
    ),
  );
}

Widget logoutWidget(context, [flag = false]) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              try {
              
                clearServarData(context);
                await ScreenTimeTracker().clearUserData();
                final SharedPreferences _pref =
                    await SharedPreferences.getInstance();
                String? userId = _pref.getString('accessToken') ?? '';
                await _pref.remove("accessToken");
                await _pref.remove('login_count_${DateTime.now().toIso8601String().substring(0, 10)}_$userId');
                await _pref.remove('login_history_$userId');
                
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/', (Route<dynamic> route) => false);
                Navigator.pushReplacementNamed(context, '/');
                clearGetX();
              } catch (e) {
                
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: flag
                  ? MediaQuery.of(context).size.width / 1.1
                  : MediaQuery.of(context).size.width / 1.2,
              decoration: BoxDecoration(
                  color: Colorcodes.budgetDarkGreen,
                  borderRadius: BorderRadius.circular(100)),
              child: Center(
                child: Text(
                  "LogOut",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
                    fontSize: 20,
                    color: Colorcodes.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void clearServarData(context) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  await _pref.remove("accessToken");
  await _pref.remove("token");
  await _pref.remove("ConsentHandleId");
  await _pref.remove("consentId");
  await _pref.remove("from");
  await _pref.remove("to");
  await _pref.remove("sessionId");
}

void navigateToNextPage(context) {
  // Navigate to your desired page
  Navigator.push(
    context,
    PageTransition(
      type: PageTransitionType.bottomToTop,
      alignment: Alignment.bottomCenter,
      duration: const Duration(milliseconds: 2000), // Increase duration
      curve: Curves.easeInOut, // Smooth transition
      child: TransactionHistory(
        pageTransition: true,
      ),
      isIos: true,
    ),
  );
}

import "package:flutter/cupertino.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Community_Page/community_screen.dart";
import "package:flutter_application_code_stakeplot/Constants/app_styles.dart";
import "package:flutter_application_code_stakeplot/Constants/colors.dart";
import "package:flutter_application_code_stakeplot/controllers/controllerManagement.dart";
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import "package:flutter_application_code_stakeplot/components/helper.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/home_screen_state/home_page.dart";

import "package:flutter_application_code_stakeplot/image_service/avatarProfile.dart";

import "package:flutter_application_code_stakeplot/loginservices/screenTime.dart";
import "package:flutter_application_code_stakeplot/finSpace/welcomeScreen.dart";

import "package:flutter_application_code_stakeplot/profile_screen/profile_screen.dart.dart";
import "package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart";
import "package:get/get.dart";

import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/Constants/colorcodes.dart";
import 'package:flutter_svg/flutter_svg.dart';



import "../Constants/font_manager.dart";
import "shared_utils.dart";
import "../finance_screen/finanace_dashboard/index_finances.dart";


class BottomNavigations extends StatefulWidget {
  int data;
  final VoidCallback? onCommunityDoubleTap;
  final VoidCallback? onHomeDoubleTap;
  BottomNavigations(
      {Key? key,
      required this.data,
      this.onCommunityDoubleTap,
      this.onHomeDoubleTap})
      : super(key: key);

  @override
  _BottomNavigationsState createState() => _BottomNavigationsState();
}

class _BottomNavigationsState extends State<BottomNavigations> {
  final List<String> _tabNames = ['Home', 'Plot', 'Finance', 'Profile'];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (widget.data >= 0 && widget.data < _tabNames.length) {
          ScreenTimeTracker().switchTab(_tabNames[widget.data]);
        }
        handleWidgetNavigation();
      } catch (e) {}
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
          pushName(FinanceDashboard());
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
          pushName(FinanceDashboard());
        }
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    //int selectedIndex = 0;
    final userController = ControllerManagement.userController;

    return Container(
      height: Colorcodes.paddingSize * 2.5,
      color: AppColors.backgroundColor,
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
  String iconPath = url;
  UserController userController = ControllerManagement.userController;

  if (url == NavBarIcons.home) {
    iconPath = isSelected ? NavBarIcons.home : NavBarIcons.home1;
  } else if (url == NavBarIcons.screen2) {
    iconPath = isSelected ? NavBarIcons.screen21 : NavBarIcons.screen2;
  } else if (url == NavBarIcons.community) {
    iconPath = isSelected ? NavBarIcons.community : NavBarIcons.community1;
  } else if (url == svgIconPath.bottom4) {
    iconPath = avaterUrlPath(userController.userName.value);
  }

  bool isAvatar = index == 3 || index == 4;

  return Padding(
    padding: isAvatar?const EdgeInsets.only(bottom: 2):EdgeInsets.all(0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// ICON
        isAvatar
            ? Obx(() => CircleAvatar(
              backgroundColor: AppColors.primaryColor,
            child: Text(
    userController.userName.value.trim().isNotEmpty
        ? userController.userName.value.trim()[0].toUpperCase()
        : '',
        style: FontManager().getTextStyle(context, color: AppColors.backgroundColor, fontSize: 16),
    ),
    
              radius: 17,
            ))
            // AvatarProfile(
            //       name: userController.userName.value,
            //       width: 8,
            //       height: 16,
            //       background: userController.avatarBackGround.value,
            //     ))
            : SvgPicture.asset(
                iconPath,
                width: MediaQuery.of(context).size.width / 30,
                height: MediaQuery.of(context).size.height / 30,
              ),
    
        const SizedBox(height: 4),
    
        /// TEXT LABEL
        Text(
          _tabNames[index],
          style: FontManager().getTextStyle(
            context,
            fontSize: 10,
            lWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? AppColors.finSpaceColor
                : AppColors.bg1,
          ),
        ),
      ],
    ),
  );
}

  // Widget imageurl(String url, int index) {
  //   bool isSelected = widget.data == index;
  //   String iconPath = url; // Default to the passed url
  //   UserController userController = ControllerManagement.userController;
  //   // Toggle icons based on selection
  //   if (url == NavBarIcons.home) {
  //     iconPath = isSelected ? NavBarIcons.home : NavBarIcons.home1;
  //   } else if (url == NavBarIcons.screen2) {
  //     iconPath = isSelected ? NavBarIcons.screen21 : NavBarIcons.screen2;
  //   } else if (url == NavBarIcons.community) {
  //     iconPath = isSelected ? NavBarIcons.community : NavBarIcons.community1;
  //   } else if (url == 'assets/images/room.svg') {
  //     iconPath = url;
  //   } else if (url == svgIconPath.bottom4) {
  //     iconPath = avaterUrlPath(userController.userName.value);
  //   }
  //   bool ifAvatar = index == 3 || index == 4;

  //   return Center(
  //     child: ifAvatar
  //         ? Obx(() => AvatarProfile(
  //             name: userController.userName.value,
  //             width: 5,
  //             height: 14,
  //             background: userController.avatarBackGround.value))
  //         : SvgPicture.asset(
  //             iconPath,
  //             width: MediaQuery.of(context).size.width /
  //                 30, // Adjust the multiplier as needed
  //             height: MediaQuery.of(context).size.height /
  //                 30, // Adjust the multiplier as needed
  //             // colorFilter: isSelected
  //             //     ? ColorFilter.mode(AppColors.finSpaceColor, BlendMode.srcIn)
  //             //     : ColorFilter.mode(
  //             //         AppColors.bg1, BlendMode.srcIn),
  //           ),
  //   );
  // }

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
          // HapticFeedback.lightImpact();
          SystemSound.play(SystemSoundType.click);
          widget.onHomeDoubleTap
              ?.call(); // Call the Home scroll-to-top callback
          return;
        }
        if (i == communityIndex && isSelected) {
          // Single tap on already selected Community tab
          // HapticFeedback.lightImpact();
          SystemSound.play(SystemSoundType.click);
          widget.onCommunityDoubleTap?.call();
          return;
        }

        if (widget.data == i) return;
        // HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
        try {
          String tabName = _tabNames[i];
          ScreenTimeTracker().switchTab(tabName);
          // added

          if (i == 0)
            pushName(HomePage(),false,true);
          // else if (i == 1) pushName(Connections());
          else if (i == 1)
            pushName(FinanceDashboard());

          else if (i == 2)
            pushName(ControllerManagement.userController.interestedTags.isEmpty
                ? WelcomeScreen()
                : Community());
          else if (i == 3) pushName(ProfileScreenDart());

          setState(() {
            widget.data = i; // Update selected index
          });
        } catch (e) {}
      },
      child: Container(
        child: imageurl(url, i),
      ),
    );
  }

  void pushName(Widget widgetName, [bool flag = false,bool isHomePage=false]) {
    final route = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widgetName,
    );

    if (flag)
    {
      Navigator.push(context, route);
    } else {
      // if(!isHomePage)
      // {
      //     Navigator.of(context).pushNamed("/home");
      // }
      // Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
      if (!isHomePage) {
           Navigator.of(context).pushNamed("/home");
        }

        Navigator.of(context).pushAndRemoveUntil(
          route,
          ModalRoute.withName("/home"),
        );

    }
  }

  


}

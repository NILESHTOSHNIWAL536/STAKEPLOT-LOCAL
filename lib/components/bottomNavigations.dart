// import "package:flutter/cupertino.dart";
// import "package:flutter/services.dart";
// import "package:flutter/widgets.dart";
// import "package:flutter/material.dart";
// import "package:flutter_application_code_stakeplot/Community_Page/community_screen.dart";
// import "package:flutter_application_code_stakeplot/Constants/app_styles.dart";
// import "package:flutter_application_code_stakeplot/Constants/colors.dart";
// import "package:flutter_application_code_stakeplot/Constants/theme_helper.dart";
// import "package:flutter_application_code_stakeplot/controllers/controllerManagement.dart";
// import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
// import "package:flutter_application_code_stakeplot/components/helper.dart";
// import "package:flutter_application_code_stakeplot/Home_Screen/home_screen_state/home_page.dart";

// import "package:flutter_application_code_stakeplot/image_service/avatarProfile.dart";

// import "package:flutter_application_code_stakeplot/loginservices/screenTime.dart";
// import "package:flutter_application_code_stakeplot/finSpace/welcomeScreen.dart";

// import "package:flutter_application_code_stakeplot/profile_screen/profile_screen.dart.dart";
// import "package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart";
// import "package:get/get.dart";

// import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
// import "package:flutter_application_code_stakeplot/Constants/colorcodes.dart";
// import 'package:flutter_svg/flutter_svg.dart';



// import "../Constants/core/app_padding_sizes.dart";
// import "../Constants/font_manager.dart";
// import "shared_utils.dart";
// import "../finance_screen/finanace_dashboard/index_finances.dart";


// class BottomNavigations extends StatefulWidget {
//   int data;
//   final VoidCallback? onCommunityDoubleTap;
//   final VoidCallback? onHomeDoubleTap;
//   BottomNavigations(
//       {Key? key,
//       required this.data,
//       this.onCommunityDoubleTap,
//       this.onHomeDoubleTap})
//       : super(key: key);

//   @override
//   _BottomNavigationsState createState() => _BottomNavigationsState();
// }

// class _BottomNavigationsState extends State<BottomNavigations> {
//   final List<String> _tabNames = ['Home', 'Plot', 'Finance', 'Profile'];
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       try {
//         if (widget.data >= 0 && widget.data < _tabNames.length) {
//           ScreenTimeTracker().switchTab(_tabNames[widget.data]);
//         }
//         handleWidgetNavigation();
//       } catch (e) {}
//     });
//   }

//   void handleWidgetNavigation() async {
//     try {
//       // Android intent
//       final route =
//           await SystemChannels.platform.invokeMethod('getInitialRoute');

//       if (route != null && route is Map) {
//         if (route['navigate_to_tab'] == 'finance') {
//           setState(() {
//             widget.data = 1;
//           });
//           ScreenTimeTracker().switchTab(_tabNames[1]);
//           pushName(const FinanceDashboard());
//         }
//       }

//       // iOS deep link (for future support)
//       const channel = MethodChannel('com.stakeplot.pfa/navigation');
//       channel.setMethodCallHandler((call) async {
//         if (call.method == 'navigateToFinance') {
//           setState(() {
//             widget.data = 1;
//           });
//           ScreenTimeTracker().switchTab(_tabNames[1]);
//           pushName(const FinanceDashboard());
//         }
//       });
//     } catch (e) {}
//   }

//   @override
//   Widget build(BuildContext context) {

//     return BottomAppBar(
//       color: Colors.transparent,
//       elevation: 0,
//       padding: EdgeInsets.zero,
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
//           child: Container(
//             height: 60,
//             decoration: BoxDecoration(
//               color: context.appColors.bottomBarBackground,
//               borderRadius: BorderRadius.circular(32),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.12),
//                   blurRadius: 24,
//                   spreadRadius: 2,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 getContainer(NavBarIcons.home, 0),
//                 getContainer(NavBarIcons.screen2, 1),
//                 getContainer(NavBarIcons.community, 2),
//                 getContainer(svgIconPath.bottom4, 3),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//   }
// //   Widget build(BuildContext context) {
// // final bottomSafe = MediaQuery.of(context).padding.bottom;
// //     return Container(
// //       height: 60+bottomSafe,
// //       color: AppColors.backgroundColor,
// //       // padding: const EdgeInsets.only(left: 3.0, right: 3.0, bottom: 2),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceAround,
// //         children: [
// //           getContainer(NavBarIcons.home, 0),
// //           getContainer(NavBarIcons.screen2, 1),
// //           if (sizeRoom)
// //             getContainer(
// //               'assets/images/room.svg',
// //               2,
// //             ),
// //           getContainer(
// //             NavBarIcons.community,
// //             sizeRoom ? 3 : 2,
// //           ),
// //           getContainer(
// //             svgIconPath.bottom4,
// //             sizeRoom ? 4 : 3,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// Widget imageurl(String url, int index) {
//   bool isSelected = widget.data == index;
//   String iconPath = url;
//   UserController userController = ControllerManagement.userController;

//   if (url == NavBarIcons.home) {
//     iconPath = isSelected ? NavBarIcons.home : NavBarIcons.home1;
//   } else if (url == NavBarIcons.screen2) {
//     iconPath = isSelected ? NavBarIcons.screen21 : NavBarIcons.screen2;
//   } else if (url == NavBarIcons.community) {
//     iconPath = isSelected ? NavBarIcons.community : NavBarIcons.community1;
//   } else if (url == svgIconPath.bottom4) {
//     iconPath = avaterUrlPath(userController.userName.value);
//   }

//   bool isAvatar = index == 3 || index == 4;

//   final colors = context.appColors;
//   final activeColor = colors.primary;
//   final inactiveColor = colors.secondaryText;

//   return Padding(
//     padding: isAvatar ? const EdgeInsets.only(bottom: 2) : EdgeInsets.zero,
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         /// ICON
//         isAvatar
//             ? Obx(() => CircleAvatar(
//               backgroundColor: activeColor,
//               radius: 17,
//               child: Text(
//                 userController.userName.value.trim().isNotEmpty
//                     ? userController.userName.value.trim()[0].toUpperCase()
//                     : '',
//                 style: FontManager().getTextStyle(context, color: Colors.white, fontSize: 16),
//               ),
//             ))
//             : SvgPicture.asset(
//                 iconPath,
//                 width: MediaQuery.of(context).size.width / 30,
//                 height: MediaQuery.of(context).size.height / 30,
//                 colorFilter: ColorFilter.mode(
//                   isSelected ? activeColor : inactiveColor,
//                   BlendMode.srcIn,
//                 ),
//               ),

//         SizedBox(height: AppSizes.h4),

//         /// TEXT LABEL
//         Text(
//           _tabNames[index],
//           style: FontManager().getTextStyle(
//             context,
//             fontSize: 10,
//             lWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//             color: isSelected ? activeColor : inactiveColor,
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   // Widget imageurl(String url, int index) {
//   //   bool isSelected = widget.data == index;
//   //   String iconPath = url; // Default to the passed url
//   //   UserController userController = ControllerManagement.userController;
//   //   // Toggle icons based on selection
//   //   if (url == NavBarIcons.home) {
//   //     iconPath = isSelected ? NavBarIcons.home : NavBarIcons.home1;
//   //   } else if (url == NavBarIcons.screen2) {
//   //     iconPath = isSelected ? NavBarIcons.screen21 : NavBarIcons.screen2;
//   //   } else if (url == NavBarIcons.community) {
//   //     iconPath = isSelected ? NavBarIcons.community : NavBarIcons.community1;
//   //   } else if (url == 'assets/images/room.svg') {
//   //     iconPath = url;
//   //   } else if (url == svgIconPath.bottom4) {
//   //     iconPath = avaterUrlPath(userController.userName.value);
//   //   }
//   //   bool ifAvatar = index == 3 || index == 4;

//   //   return Center(
//   //     child: ifAvatar
//   //         ? Obx(() => AvatarProfile(
//   //             name: userController.userName.value,
//   //             width: 5,
//   //             height: 14,
//   //             background: userController.avatarBackGround.value))
//   //         : SvgPicture.asset(
//   //             iconPath,
//   //             width: MediaQuery.of(context).size.width /
//   //                 30, // Adjust the multiplier as needed
//   //             height: MediaQuery.of(context).size.height /
//   //                 30, // Adjust the multiplier as needed
//   //             // colorFilter: isSelected
//   //             //     ? ColorFilter.mode(AppColors.finSpaceColor, BlendMode.srcIn)
//   //             //     : ColorFilter.mode(
//   //             //         AppColors.bg1, BlendMode.srcIn),
//   //           ),
//   //   );
//   // }

//   Widget getContainer(url, i) {
//     bool isSelected =
//         widget.data == i; // Check if the current index is selected
//     int communityIndex = sizeRoom ? 3 : 2;
//     return GestureDetector(
//       //  onDoubleTap: () {
//       //   if (i == communityIndex && isSelected) {
//       //     // Double-tap on Community tab when active
//       //     widget.onCommunityDoubleTap?.call();
//       //   }
//       // },
//       onLongPress: () async {
//         if (i == 2 && widget.data != i){
//            pushName(const TribeChats(), true);

//         }

//         else if (i == 0) {
//           // Handle long press for index 0
//         } else if (i == 3 && widget.data != i) {}
//       },
//       onTap: () {
//         if (i == 0 && isSelected) {
//           // Single tap on already selected Home tab
//           // HapticFeedback.lightImpact();
//           SystemSound.play(SystemSoundType.click);
//           widget.onHomeDoubleTap
//               ?.call(); // Call the Home scroll-to-top callback
//           return;
//         }
//         if (i == communityIndex && isSelected) {
//           // Single tap on already selected Community tab
//           // HapticFeedback.lightImpact();
//           SystemSound.play(SystemSoundType.click);
//           widget.onCommunityDoubleTap?.call();
//           return;
//         }

//         if (widget.data == i) return;
//         // HapticFeedback.heavyImpact();
//         SystemSound.play(SystemSoundType.click);
//         try {
//           String tabName = _tabNames[i];
//           ScreenTimeTracker().switchTab(tabName);
//           // added

//           if (i == 0){
//              pushName(HomePage(),false,true);

//           }

//           // else if (i == 1) pushName(Connections());
//           else if (i == 1)
//           {
//              pushName(const FinanceDashboard());
//           }


//           else if (i == 2)
//           {
//              pushName(ControllerManagement.userController.interestedTags.isEmpty
//                 ? const WelcomeScreen()
//                 : const Community());
//           }

//           else if (i == 3)
//           {
//              pushName(const ProfileScreenDart());

//           }


//           setState(() {
//             widget.data = i; // Update selected index
//           });
//         } catch (e) {}
//       },
//       child: Container(
//         child: imageurl(url, i),
//       ),
//     );
//   }

//   void pushName(Widget widgetName, [bool flag = false,bool isHomePage=false]) {
//     final route = PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => widgetName,
//     );

//     if (flag)
//     {
//       Navigator.push(context, route);
//     } else {
//       // if(!isHomePage)
//       // {
//       //     Navigator.of(context).pushNamed("/home");
//       // }
//       // Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
//       if (!isHomePage) {
//            Navigator.of(context).pushNamed("/home");
//         }

//         Navigator.of(context).pushAndRemoveUntil(
//           route,
//           ModalRoute.withName("/home"),
//         );

//     }
//   }




// }


import "dart:async";
import "package:flutter/cupertino.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Community_Page/community_screen.dart";
import "package:flutter_application_code_stakeplot/Constants/app_styles.dart";
import "package:flutter_application_code_stakeplot/Constants/colors.dart";
import "package:flutter_application_code_stakeplot/Constants/theme_helper.dart";
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
import "package:flutter_application_code_stakeplot/repository/bankinfo.dart";
import 'package:flutter_svg/flutter_svg.dart';



import "../Constants/app_svgs.dart";
import "../Constants/font_manager.dart";
import "../finance_screen/finanace_dashboard/index_finances.dart";
import "../Constants/core/app_padding_sizes.dart";
import "../components/shared_utils.dart";
import "../model/bank_model.dart";
import "../model/fips_metric_model.dart";
import "../Utils/homepageStrings.dart.dart";
import "package:flutter_application_code_stakeplot/backed_connections/bankServices/nextFetch.dart" show modalPageController;
import "package:flutter_application_code_stakeplot/backed_connections/bankServices/bank_sync_flow.dart";


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
  int _currentBankIndex = 0;
  Timer? _bankCycleTimer;

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

    _bankCycleTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (mounted) setState(() => _currentBankIndex++);
    });
  }

  @override
  void dispose() {
    _bankCycleTimer?.cancel();
    super.dispose();
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
          pushName(const FinanceDashboard());
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
          pushName(const FinanceDashboard());
        }
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return BottomAppBar(
      // color: colors.whiteColor,
      elevation: 0,
      // shadowColor: Colors.white,
      // surfaceTintColor: Colors.white,
     padding: const EdgeInsets.fromLTRB(10, 6, 8, 20),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors.whiteColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      getContainer(BottomNavigationSvgs.homeIcon, 0),
                      getContainer(BottomNavigationSvgs.financeIcon, 1),
                      getContainer(BottomNavigationSvgs.investmentIcon, 2),
                     getContainer(svgIconPath.bottom4, 3),
                    ],
                  ),
                ),

              ),
              const SizedBox(width: 8),
              _buildBankIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankIndicator() {
    return Obx(() {
      final banks = bankInfoController.bankAccountLinkedList;

      // Deduplicate by fipId so each bank appears once
      final seen = <String>{};
      final unique = banks.where((b) => seen.add(b.fipId)).toList();

      final decoration = BoxDecoration(
        color: context.appColors.bottomBarBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      );

      if (unique.isEmpty) {
        return Container(
          height: 50,
          width: 50,
          decoration: decoration,
          child: Center(
            child: Icon(
              Icons.account_balance_outlined,
              color: context.appColors.secondaryText,
              size: 22,
            ),
          ),
        );
      }

      final bank = unique[_currentBankIndex % unique.length];

      return GestureDetector(
        onTap: () => _showBankFetchModal(context, bank),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Container(
            key: ValueKey(bank.fipId),
            height: 50,
            width: 50,
            decoration: decoration,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  bank.bankLogo,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.account_balance_outlined,
                    color: context.appColors.primary,
                    size: 24,
                  ),
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Icon(
                          Icons.account_balance_outlined,
                          color: context.appColors.secondaryText,
                          size: 24,
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

Widget imageurl(String url, int index) {
  bool isSelected = widget.data == index;
  bool isAvatar = index == 3 || index == 4;
  UserController userController = ControllerManagement.userController;

  final colors = context.appPalette;

  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      isAvatar
          ? Obx(() => CircleAvatar(
                backgroundColor: colors.blackColor,
                radius: 15,
                child: Text(
                  userController.userName.value.trim().isNotEmpty
                      ? userController.userName.value.trim()[0].toUpperCase()
                      : '',
                  style: FontManager()
                      .getTextStyle(context, color: Colors.white, fontSize: 16),
                ),
              ))
          : SvgPicture.asset(
              url,
              width: MediaQuery.of(context).size.width / 32,
              height: MediaQuery.of(context).size.height / 32,
              // colorFilter: ColorFilter.mode(
              //   isSelected ? activeColor : inactiveColor,
              //   BlendMode.srcIn,
              // ),
            ),
      const SizedBox(height: 2),
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 2.5,
        width: isSelected ? 20.0 : 0.0,
        decoration: BoxDecoration(
          color: colors.blackColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ],
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

          if (i == 0){
             pushName(HomePage(),false,true);

          }

          // else if (i == 1) pushName(Connections());
          else if (i == 1)
          {
             pushName(const FinanceDashboard());
          }


          else if (i == 2)
          {
             pushName(ControllerManagement.userController.interestedTags.isEmpty
                ? const WelcomeScreen()
                : const Community());
          }

          else if (i == 3)
          {
             pushName(const ProfileScreenDart());

          }


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
      if (!isHomePage) {
           Navigator.of(context).pushNamed("/home");
        }

        Navigator.of(context).pushAndRemoveUntil(
          route,
          ModalRoute.withName("/home"),
        );

    }
  }

  void _showBankFetchModal(BuildContext context, BankAccountModel bank) {
    if (consentAndHandleDetails.isEmpty) return;

    final index = bankAccountLinkedList.indexWhere(
      (item) => item.accountId == bank.accountId,
    );
    if (index != -1) {
      bankInfoController.selectBankAccount(index, context);
    }

    if (modalPageController.hasClients) {
      modalPageController.jumpToPage(0);
    }

    if (fipsMetricList.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final FipsMetric metric = fipsMetricList.firstWhere(
              (item) => item.BankName == BankName.value,
              orElse: () => fipsMetricList.first,
            );
            final selectedConsent = _selectedConsentInfoForBank(bank);
            final formattedNextFetch = _formatFetchDateStr(nextFecthDate.value);
            final formattedLastFetch = _formatFetchDateStr(LastFetchDate.value);
            final currentFetchCount = int.tryParse(fetchCount.value) ?? 0;
            final bool limit = currentFetchCount >= 5;

            return SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: AppSizes.p24),
                decoration: BoxDecoration(
                  color: ctx.appColors.dialogBackground,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.58,
                  child: isBankHandleFetching(bank.consendHandleId)
                      ? _buildBankSyncInProgress(ctx, bank)
                      : PageView(
                          controller: modalPageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Connected Banks",
                                    style: FontManager().getTextStyle(
                                      ctx,
                                      fontSize: 16,
                                      lWeight: FontWeight.w500,
                                      color: ctx.appColors.onSurface,
                                      lineHeight: 21 / fontSize,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.h16),
                                  _buildConnectedBanksRow(ctx,
                                      onBankChanged: () =>
                                          setModalState(() {})),
                                  const SizedBox(height: AppSizes.h20),
                                  _buildFetchInfoCard(
                                    context: ctx,
                                    title: "Fetching bank",
                                    value: BankName.value,
                                  ),
                                  const SizedBox(height: AppSizes.h12),
                                  _buildFetchInfoCard(
                                    context: ctx,
                                    title: "Average latency",
                                    value: "${metric.latencyAvgMs + 40}ms",
                                  ),
                                  const SizedBox(height: AppSizes.h12),
                                  _buildFetchInfoCard(
                                    context: ctx,
                                    title: HomepageStringsDart().lastFetchLabel,
                                    value: formattedLastFetch,
                                  ),
                                  const SizedBox(height: AppSizes.h12),
                                  _buildFetchInfoCard(
                                    context: ctx,
                                    title: HomepageStringsDart().nextFetchTitle,
                                    value: formattedNextFetch,
                                  ),
                                  const SizedBox(height: AppSizes.h12),
                                  _buildFetchInfoCard(
                                    context: ctx,
                                    title: HomepageStringsDart().fetchCountTitle,
                                    value: '${!limit ? fetchCount.value : "5"}/5',
                                  ),
                                  const SizedBox(height: AppSizes.h20),
                                  _buildFetchContinueButton(ctx),
                                ],
                              ),
                            ),
                            BankSyncFlow(
                              consentInfo: selectedConsent,
                              bankName: BankName.value,
                              bankLogo: BankUrl.value,
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBankSyncInProgress(BuildContext context, BankAccountModel bank) {
    final displayBankName = fetchingBankNameForHandle(
      bank.consendHandleId,
      bank.bankName,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: context.appColors.iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.sync, size: 26, color: context.appColors.primary),
        ),
        const SizedBox(height: AppSizes.h20),
        Text(
          "$displayBankName sync in progress",
          textAlign: TextAlign.center,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 16,
            color: context.appColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSizes.h10),
        Text(
          "Please wait while we retrieve the latest data from $displayBankName. The process may take a moment depending on the bank's server response.",
          textAlign: TextAlign.center,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w300,
            fontSize: 12,
            color: context.appColors.secondaryText,
            lineHeight: 18 / fontSize,
          ),
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height / 30),
        SizedBox(
          width: double.infinity,
          height: AppSizes.h48,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              "Done",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.backgroundColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFetchContinueButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        modalPageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: double.infinity,
        height: AppSizes.h48,
        decoration: BoxDecoration(
          color: context.appColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            "Continue",
            style: FontManager().getTextStyle(
              context,
              fontSize: 16,
              lWeight: FontWeight.w500,
              color: AppColors.backgroundColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFetchInfoCard({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.appColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: FontManager().getTextStyle(
                context,
                fontSize: screenWidth < 400 ? 12 : 14,
                lWeight: FontWeight.w400,
                color: context.appColors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.w10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontManager().getTextStyle(
                context,
                fontSize: screenWidth < 400 ? 10 : 12,
                color: context.appColors.secondaryText,
                lWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedBanksRow(BuildContext context,
      {VoidCallback? onBankChanged}) {
    if (bankAccountLinkedList.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(vertical: AppSizes.p6, horizontal: 6),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.border, width: 1),
      ),
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: bankAccountLinkedList.length,
          separatorBuilder: (_, __) => const SizedBox(width: 2),
          itemBuilder: (context, index) {
            final bank = bankAccountLinkedList[index];
            final bool isActive = bank.accountId == accountId.value;
            return GestureDetector(
              onTap: () {
                bankInfoController.selectBankAccount(index, context);
                onBankChanged?.call();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 86,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.p6,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? context.appColors.iconBackground
                      : AppColors.transparentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      bank.bankLogo,
                      width: 28,
                      height: 28,
                      errorBuilder: getErrorBankLogo(),
                    ),
                    const SizedBox(height: AppSizes.h4),
                    Text(
                      bank.bankName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 12,
                        lWeight: FontWeight.w500,
                        color: isActive
                            ? context.appColors.primary
                            : context.appColors.onSurface,
                        lineHeight: 18 / fontSize,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ConsentInfoModel? _selectedConsentInfoForBank(BankAccountModel bank) {
    if (consentAndHandleDetails.isEmpty) return null;
    final selectedAccount = scrollBankPage.value >= 0 &&
            scrollBankPage.value < bankAccountLinkedList.length
        ? bankAccountLinkedList[scrollBankPage.value]
        : null;
    return consentAndHandleDetails.firstWhereOrNull(
          (item) =>
              selectedAccount != null &&
              item.consendHandleId == selectedAccount.consendHandleId,
        ) ??
        consentAndHandleDetails.firstWhereOrNull(
          (item) => item.accountId == accountId.value,
        ) ??
        consentAndHandleDetails.firstWhereOrNull(
          (item) =>
              selectedAccount != null && item.fipId == selectedAccount.fipId,
        ) ??
        consentAndHandleDetails.firstWhereOrNull(
          (item) => item.bankName == BankName.value,
        );
  }

  String _formatFetchDateStr(String value) {
    try {
      return value.isNotEmpty
          ? formatWhatsAppDate(DateTime.parse(value))
          : HomepageStringsDart().notScheduled;
    } catch (_) {
      return HomepageStringsDart().notScheduled;
    }
  }
}

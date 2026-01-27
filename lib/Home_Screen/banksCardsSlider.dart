// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/components/helper.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/bankServices/bankSlider.dart';
// import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/repository/bankinfo.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// import 'package:flutter_application_code_stakeplot/profile_screen/resetPin.dart';
// import 'package:get/get.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:lottie/lottie.dart';

// import '../components/shared_utils.dart';
// import '../model/bank_model.dart';

// RxInt firstDigit = 0.obs;
// RxInt secondDigit = 0.obs;
// RxBool digitLoad = false.obs;

// class NumberPickerScreen extends StatefulWidget {
//   @override
//   State<NumberPickerScreen> createState() => _NumberPickerScreenState();
// }

// class _NumberPickerScreenState extends State<NumberPickerScreen> {
//   final FixedExtentScrollController firstDigitController =
//       FixedExtentScrollController(initialItem: 0);
//   final FixedExtentScrollController secondDigitController =
//       FixedExtentScrollController(initialItem: 0);

//   List lock = HomepageStringsDart().lockPatterns;



//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;

//     // Check for zero to avoid division by zero
//     return Container(
//         // Wrap content with SingleChildScrollView
//         child: SizedBox(
//             width: width,
//             height: height > 0 ? height / 2.5 : 100, // Fallback height
//             child: Obx(() => loadBanks.value ? BankSlider() :loadBalance.value?  avatarSlider(): avatarSlider())));
//   }

//   Widget avatarSlider() {
//     return bankAccountLinkedList.isEmpty
//         ? connectBankAccount(context)
//         :PageView.builder(
//                   itemCount: bankAccountLinkedList.length,
//                   controller: PageController(viewportFraction: 1.0,initialPage:scrollBankPage.value ),
//                    onPageChanged: (index) {
//                       if (bankAccountLinkedList.isEmpty) return;
//                       // accountId.value = bankAccountLinkedList[index]['accountId'] ?? "";
//                       // LastFetchDate.value = bankAccountLinkedList[index]['lastFetch'].toString();
//                       // nextFecthDate.value = bankAccountLinkedList[index]['nextFetch'].toString();
//                       // fetchCount.value = bankAccountLinkedList[index]['fetchCount'].toString();
//                       // BankName.value = bankAccountLinkedList[index]['bankName'].toString();
//                       // BankUrl.value = bankAccountLinkedList[index]['bankLogo'].toString();
//                       // scrollBankPage.value = index;
//                       // calledFunctionToFetchData(context);
//                        final account = bankAccountLinkedList[index];

//               accountId.value = account.accountId;
//               LastFetchDate.value = account.lastFetch;
//               nextFecthDate.value = account.nextFetch;
//               fetchCount.value = account.fetchCount.toString();
//               BankName.value = account.bankName;
//               BankUrl.value = account.bankLogo;
//               scrollBankPage.value = index;
//               calledFunctionToFetchData(context);
//                     },
//                 //   itemBuilder: (context, index) {
//                 //     return AnimatedBuilder(
//                 //       animation: PageController(viewportFraction: 1.0),
//                 //       builder: (context, child) {
//                 //         return Transform.scale(
//                 //           scale: 1.0, // customize scale effect
//                 //           child: child,
//                 //         );
//                 //       },
//                 //       child: Padding(
//                 //         padding:  EdgeInsets.fromLTRB(0,2,2,2),
//                 //         child: getListViewBankInfo(bankAccountLinkedList[index]),
//                 //       ),
//                 //     );
//                 //   },
//                 // );

//   // }

//  itemBuilder: (context, index) {
//               final account = bankAccountLinkedList[index];
//               return AnimatedBuilder(
//                 animation:
//                     PageController(viewportFraction: 1.0), // dummy controller
//                 builder: (context, child) {
//                   return Transform.scale(
//                     scale: 1.0,
//                     child: child,
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(0, 2, 2, 2),
//                   child: getListViewBankInfo(account),
//                 ),
//               );
//             },
//           );
//   }
//   Widget getListViewBankInfo(BankAccountModel data) {
//     int randomIndex = Random().nextInt(lock.length);
//     if (randomIndex == lock.length) randomIndex = 0;

//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: Colorcodes.paddingHorizontal,
//         vertical: Colorcodes.paddingHorizontal / 6,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.accentColor,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           SizedBox(height: Colorcodes.borderRadius10),
//           Row(
//             children: [
//               Image.network(
//                 data.bankLogo,
//                 width: 30,
//                 height: 30,
//                 fit: BoxFit.fitWidth,
//                 errorBuilder: getErrorBankLogo(),
//               ),
//               SizedBox(width: Colorcodes.borderRadius10),
//               Text(
//                 data.bankName,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.normal,
//                   fontSize: 18,
//                   color: AppColors.backgroundColor,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: Colorcodes.borderRadius),
//           Text(
//             HomepageStringsDart().accountNumberLabel +
//                 data.maskedAccNumber,
//             style: FontManager().getTextStyle(
//               context,
//               lWeight: FontWeight.bold,
//               fontSize: 16,
//               color: AppColors.backgroundColor,
//             ),
//           ),
//           SizedBox(height: Colorcodes.borderRadius10),
//           Text(
//             HomepageStringsDart().availableBalanceLabel,
//             style: FontManager().getTextStyle(
//               context,
//               lWeight: FontWeight.w400,
//               fontSize: 12,
//               color: AppColors.backgroundColor,
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Obx(() {
//                 final String pin =
//                     userController.cupertinoPin.value;
//                 final bool hide =
//                     hideBackAccountPassword.value;

//                 final double balance = data.currentBalance;

//                 // If you consider 0.0 as "no data", you can handle it:
//                 // if (balance == 0.0) { ... }

//                 final bool showBalance =
//                     (pin == "0" || pin == "00" || hide);

//                 return Text(
//                   '\u{20B9} ${showBalance ? formatMoneyIndian(balance.toString(), lock[randomIndex]) : lock[randomIndex]}',
//                   style: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.bold,
//                     fontSize: 20,
//                     color: AppColors.backgroundColor,
//                   ),
//                 );
//               }),
//               setPinForAccountHide(context),
//             ],
//           ),
//           SizedBox(height: Colorcodes.elevation5),
//         ],
//       ),
//     );
//   }
// //   Widget getListViewBankInfo(data) {
// //     int randomIndex = Random().nextInt(lock.length);
// //     if (randomIndex == lock.length) randomIndex = 0;
   
// //     return Container(
// //         padding: EdgeInsets.symmetric(horizontal: Colorcodes.paddingHorizontal,vertical: Colorcodes.paddingHorizontal / 6),
// //         decoration: BoxDecoration(
// //           color: AppColors.accentColor,
// //           borderRadius: BorderRadius.circular(16),
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           mainAxisAlignment: MainAxisAlignment.spaceAround,
// //           children: [
// //             SizedBox(height: Colorcodes.borderRadius10),
// //             Row(
// //               children: [
// //             Image.network
// //             (
// //                 data['bankLogo'],
// //                 width: 30,
// //                 height: 30,
// //                 fit: BoxFit.fitWidth,
// //                 errorBuilder: getErrorBankLogo(),
// //             ),
// //              SizedBox(width: Colorcodes.borderRadius10),
// //                 Text(
// //                   data['bankName'],
// //                   style: FontManager().getTextStyle(context,
// //                       lWeight: FontWeight.normal,
// //                       fontSize: 18,
// //                       color: AppColors.backgroundColor),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: Colorcodes.borderRadius),
// //             Text(
// //               HomepageStringsDart().accountNumberLabel + data['maskedAccNumber'],
// //               style: FontManager().getTextStyle(context,
// //                   lWeight: FontWeight.bold,
// //                   fontSize: 16,
// //                   color: AppColors.backgroundColor),
// //             ),
// //             SizedBox(height: Colorcodes.borderRadius10),
// //             Text(HomepageStringsDart().availableBalanceLabel,
// //                 style: FontManager().getTextStyle(context,
// //                     lWeight: FontWeight.w400,
// //                     fontSize: 12,
// //                     color: AppColors.backgroundColor)),
            
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Obx(() {
// //   // use .value so Obx actually depends on these reactive variables
// //   final String pin = userController.cupertinoPin.value;
// //   final bool hide = hideBackAccountPassword.value;

// //   final balance = data['currentBalance'];

// //   // If API didn't return balance -> show small text (no lock)
// //   if (balance == null) {
// //     return Text(
// //       "Balance not available",
// //       style: FontManager().getTextStyle(
// //         context,
// //         lWeight: FontWeight.w500,
// //         fontSize: 14,
// //         color: AppColors.backgroundColor,
// //       ),
// //     );
// //   }

// //   // compute showBalance inside Obx using reactive values
// //   final bool showBalance = (pin == "0" || pin == "00" || hide);

// //   return Text(
// //     '\u{20B9} ${showBalance ? formatMoneyIndian(balance, lock[randomIndex]) : lock[randomIndex]}',
// //     style: FontManager().getTextStyle(
// //       context,
// //       lWeight: FontWeight.bold,
// //       fontSize: 20,
// //       color: AppColors.backgroundColor,
// //     ),
// //   );
// // })
// // ,
// //               //  Obx(()=> 
// //               //  Text(
// //               //     '\u{20B9} ${(hideBackAccountPassword.value || userController.cupertinoPin.value == "0" || userController.cupertinoPin.value == "00") ? formatMoneyIndian(data['currentBalance'] ?? "null",lock[randomIndex]) : lock[randomIndex]}',
// //               //     style: FontManager().getTextStyle(context,
// //               //         lWeight: FontWeight.bold,
// //               //         fontSize: 20,
// //               //         color: AppColors.backgroundColor),
// //               //  )
// //               //  ),
// //                 //  locker(context),
// //                 setPinForAccountHide(context)
// //               ],
// //             ),
// //             SizedBox(height: Colorcodes.elevation5),
// //           ],
// //         ));
// //   }

//   Widget locker(context) {
//     return Row(
//       children: [
//         _buildPicker("firstDigit", context),
//         _buildPicker("secondDigit", context),
//       ],
//     );
//   }

//   void setBack() {
//     setState(() {
//       firstDigit.value = 0;
//       secondDigit.value = 0;
//       firstDigitController.jumpToItem(0);
//       secondDigitController.jumpToItem(0);
//     });
//   }

//   Widget _buildPicker(String controllerValue, BuildContext context) {
//     double height = MediaQuery.of(context).size.height;

//     return SizedBox(
//       width: MediaQuery.of(context).size.width / 6,
//       height: height > 0 ? height / 18 : 50, // Fallback height
//       child: CupertinoPicker(
//         itemExtent: 30,
//         scrollController: controllerValue == "firstDigit"
//             ? firstDigitController
//             : secondDigitController,
//         onSelectedItemChanged: (index) {
//           if (controllerValue == "firstDigit") {
//             firstDigit.value = index;
//           } else {
//             secondDigit.value = index;
//           }
//           pinPasswordVerifyDebounced(
//               firstDigit.value.toString() + "" + secondDigit.value.toString(),
//               context,
//               setBack);
//         },
//         children: List<Widget>.generate(
//           10,
//           (index) => Center(
//             child: Text(
//               index.toString(),
//               style: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.normal,
//                   fontSize: 16,
//                   color: AppColors.backgroundColor),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// Widget setPinForAccountHide(context) {
//   return Obx(() {
//     if (userController.cupertinoPin.value == "0" || userController.cupertinoPin.value == "00" || userController.cupertinoPin.value.isEmpty ||  userController.cupertinoAttemptCount.value) { // Handle empty case too
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 5),
//         child: InkWell(
//           onTap: () {

//             if(userController.cupertinoAttemptCount.value)
//             {
//               resetCupertinoPin(context);
//               return;
//             }
//             showModalBottomSheet(
//               context: context,
//               backgroundColor: Colorcodes.appBarColor,
//               builder: (context) {
//                 return setPassword(context);
//               },
//             );
//           },
//           child: Container(
//             padding: const EdgeInsets.all(AppSizes.p8),
//             width: 80,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: AppColors.bg3,
//             ),
//             child: Center(
//               child: Obx(()=>  Text(
//                !  userController.cupertinoAttemptCount.value?  HomepageStringsDart().setPinButton: HomepageStringsDart().resetCupertinoPin,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.normal,
//                   fontSize: 12,
//                   color: AppColors.backgroundColor,
//                 ),
//               )),
//             ),
//           ),
//         ),
//       );
//     } else {
//       return locker(context);
//     }
//   });
// }
 
//   Widget setPassword(context) {
//     double height = MediaQuery.of(context).size.height;
//    RxInt selectedNumber1 = 0.obs; // Make first digit reactive
//     RxInt selectedNumber2 = 0.obs;  // Second selected number

//     return SafeArea(
//       child: Container(
//         //  color: AppColors.backgroundColor,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(16), topRight: Radius.circular(16)),
//           color: AppColors.backgroundColor,
//         ),
//         width: MediaQuery.of(context).size.width,
//         height: height > 0 ? height / 3.8 : 100, // Fallback height
//         padding: EdgeInsets.symmetric(horizontal: 30, vertical: AppSizes.p10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top:AppSizes.p20),
//               child: textStyle(
//                   context: context,
//                   text: HomepageStringsDart().setLockTitle,
//                   fontsize: 20,
//                   fontWeight: FontWeight.bold),
//             ),
//             // First Cupertino Picker
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width / 6,
//                       height: MediaQuery.of(context).size.height /
//                           16, // Adjust height as needed
//                       child: CupertinoPicker(
//                         itemExtent: 26.0, // Height of each item
//                         onSelectedItemChanged: (int index) {
//                           selectedNumber1.value = index; // Update first number
//                         },
//                         children: List<Widget>.generate(10, (int index) {
//                           return Center(child: Text(index.toString()));
//                         }), // Numbers 0-99
//                       ),
//                     ),
      
//                     // Second Cupertino Picker
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width / 6,
//                       height: MediaQuery.of(context).size.height /
//                           16, // Adjust height as needed
//                       child: CupertinoPicker(
//                         itemExtent: 26.0, // Height of each item
//                         onSelectedItemChanged: (int index) {
//                           selectedNumber2.value = index; // Update second number
//                         },
//                         children: List<Widget>.generate(10, (int index) {
//                           return Center(child: Text(index.toString()));
//                         }), // Numbers 0-99
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 30,
//                 ),
//                Obx(() {
//                   String combinedInput = '${selectedNumber1.value}${selectedNumber2.value}';
//                   bool isInvalidPin = combinedInput == "00";
                
//                   return InkWell(
//                     onTap: isInvalidPin
//                         ? null
//                         : () {
//                             setPasswordApiCalled(context, combinedInput);
//                           },
//                     child:  Container(
//                       width: MediaQuery.of(context).size.width / 1.1,
//                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: AppSizes.p20),
//                       decoration: BoxDecoration(
//                         color: isInvalidPin
//                             ? AppColors.bg3
//                             : AppColors.primaryColor, // Button color based on validity
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: Center(
//                         child: Text(
//                           HomepageStringsDart().confirmButton,
//                           style: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: AppColors.bg5,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

  
//   PopupMenuEntry<String> getItemOfListPopupMenuItem(
//       String bankName, String fipId, var data, String id) {
//     return PopupMenuItem<String>(
//       value: id, // Ensure value is of type String
//       child: Text(bankName),
//     );
//   }
  
//  Widget connectBankAccount(BuildContext context) {
//    return Container(
//   color: AppColors.backgroundColor,
//   padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//   child: Center(
//     child: InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ShareAccountLogin(),
//           ),
//         );
     
//       },
//       child: Column(
//         children: [
//             Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                               height: 30,
//                               width: 30,
//                               child: Lottie.asset("assets/splashScreen/fetchLoad.json"),
//                  ),
//                  textStyle(context: context, text: HomepageStringsDart().noBankLinked, fontsize: 11, fontWeight: FontWeight.bold),
//                 ],
//               ),
//           Card(
//             elevation: 2,
//             color: AppColors.primaryColor,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             child: Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   AvatarProfileImage(
//                     width: 2,
//                     height: 10,
//                     url: bankImage,
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "Securely connect your bank account",
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w500,
//                       fontSize: 15,
//                       color: Colorcodes.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   ),
// );

// }
// }


// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/components/helper.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/bankServices/bankSlider.dart';
// import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/repository/bankinfo.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// import 'package:flutter_application_code_stakeplot/profile_screen/resetPin.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:lottie/lottie.dart';

// import '../backed_connections/bankServices/nextFetch.dart';
// import '../components/shared_utils.dart';
// import '../model/bank_model.dart';

// RxInt firstDigit = 0.obs;
// RxInt secondDigit = 0.obs;
// RxBool digitLoad = false.obs;

// class NumberPickerScreen extends StatefulWidget {
//   @override
//   State<NumberPickerScreen> createState() => _NumberPickerScreenState();
// }

// class _NumberPickerScreenState extends State<NumberPickerScreen> {
//   final FixedExtentScrollController firstDigitController =
//       FixedExtentScrollController(initialItem: 0);
//   final FixedExtentScrollController secondDigitController =
//       FixedExtentScrollController(initialItem: 0);

//   List lock = HomepageStringsDart().lockPatterns;



//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;

//     // Check for zero to avoid division by zero
//     return Container(
//         // Wrap content with SingleChildScrollView
//         child: SizedBox(
//             width: width,
//             height: height > 0 ? height / 2.5 : 100, // Fallback height
//             child: Obx(() => loadBanks.value ? BankSlider() :loadBalance.value?  avatarSlider(): avatarSlider())));
//   }

//  Widget avatarSlider() {
//   if (bankAccountLinkedList.isEmpty) return connectBankAccount(context);

//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Expanded(
//         child: PageView.builder(
//           itemCount: bankAccountLinkedList.length,
//           controller: PageController(
//             viewportFraction: 1.0,
//             initialPage: scrollBankPage.value,
//           ),
//           onPageChanged: (index) {
//             final account = bankAccountLinkedList[index];
//             accountId.value = account.accountId;
//             LastFetchDate.value = account.lastFetch;
//             nextFecthDate.value = account.nextFetch;
//             fetchCount.value = account.fetchCount.toString();
//             BankName.value = account.bankName;
//             BankUrl.value = account.bankLogo;
//             scrollBankPage.value = index;
//             calledFunctionToFetchData(context);
//           },
//           itemBuilder: (context, index) {
//             final account = bankAccountLinkedList[index];
//             return Padding(
//               padding: const EdgeInsets.fromLTRB(0, 2, 2, 2),
//               child: getListViewBankInfo(account),
//             );
//           },
//         ),
//       ),

//       SizedBox(height: 6),

//       Obx(() => Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: List.generate(
//           bankAccountLinkedList.length,
//           (index) => AnimatedContainer(
//             duration: Duration(milliseconds: 250),
//             margin: EdgeInsets.symmetric(horizontal: 4),
//             height: 8,
//             width: scrollBankPage.value == index ? 8 : 8,  // active dot grows
//             decoration: BoxDecoration(
//               color: scrollBankPage.value == index
//                   ? AppColors.primaryColor
//                   : AppColors.accentColor.withOpacity(0.4),
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       )),

//       SizedBox(height: 8),
//     ],
//   );
// }

 
// Widget getListViewBankInfo(BankAccountModel data) {
//   int randomIndex = Random().nextInt(lock.length);
//   if (randomIndex == lock.length) randomIndex = 0;

//   // Card paddings / radii (tweak if needed)
//   const double cardRadius = 16.0;
//   final double horizontalPadding = Colorcodes.paddingHorizontal;
//   final double verticalPadding = Colorcodes.paddingHorizontal / 6;

//   return ClipRRect(
//     borderRadius: BorderRadius.circular(cardRadius),
//     child: Stack(
//       children: [
//         // --- SVG Background
//         Positioned.fill(
          
//           child: AvatarProfileImageZero(url: HomePageIcons.bankContainerBg, width: 1, height: 2.4),
//         ),

//         Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: horizontalPadding,
//             vertical: verticalPadding,
//           ),
//           decoration: BoxDecoration(
//             // Keep background transparent because svg sits behind.
//             color: Colors.transparent,
//             borderRadius: BorderRadius.circular(cardRadius),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               // Horizontal logos strip (if >1 account)
//               if (bankAccountLinkedList.length > 1)
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: SizedBox(
//                     height: 56,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       physics: BouncingScrollPhysics(),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: bankAccountLinkedList.asMap().entries.where((entry) {
//                           final index = entry.key;
//                           final account = entry.value as BankAccountModel;
//                           return account.accountId != data.accountId;
//                         }).map((entry) {
//                           final index = entry.key;
//                           final account = entry.value as BankAccountModel;
//                           return Padding(
//                             padding: const EdgeInsets.only(right:AppSizes.p10),
//                             child: GestureDetector(
//                               onTap: () {
//                                 accountId.value = account.accountId;
//                                 LastFetchDate.value = account.lastFetch;
//                                 nextFecthDate.value = account.nextFetch;
//                                 fetchCount.value = account.fetchCount.toString();
//                                 BankName.value = account.bankName;
//                                 BankUrl.value = account.bankLogo;
//                                 scrollBankPage.value = index;
//                                 calledFunctionToFetchData(context);
//                               },
//                               child: Container(
//   width: 82,
//   height: 42,
//   decoration: BoxDecoration(
//     color: Colors.white.withOpacity(0.02),   // Figma: opacity 0.02
//     borderRadius: const BorderRadius.only(
//       topLeft: Radius.circular(4),
//       topRight: Radius.circular(14),
//       bottomRight: Radius.circular(14),
//       bottomLeft: Radius.circular(4),
//     ),
//   ),
//   child: Image.network(
//     account.bankLogo,
//     fit: BoxFit.contain,
//     height: 10,
//     width: 10,
//     errorBuilder: getErrorBankLogo(),
//   ),
// )
// ,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 ),

//               // Next fetch widget
//               Nextfetch(),

//               SizedBox(height: Colorcodes.borderRadius10),

//               // Bank logo + masked number (main row)
//               Row(
//                 children: [
//                   Image.network(
//                     data.bankLogo,
//                     width: 30,
//                     height: 30,
//                     fit: BoxFit.fitWidth,
//                     errorBuilder: getErrorBankLogo(),
//                   ),
//                   SizedBox(width: Colorcodes.borderRadius10),
//                   Text(
//                     data.maskedAccNumber,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: AppColors.backgroundColor,
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: Colorcodes.borderRadius),

//               // Available balance label
//               Text(
//                 HomepageStringsDart().availableBalanceLabel,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.w400,
//                   fontSize: 12,
//                   color: AppColors.backgroundColor,
//                 ),
//               ),

//               // Balance + pin
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Obx(() {
//                     final String pin = userController.cupertinoPin.value;
//                     final bool hide = hideBackAccountPassword.value;
//                     final double balance = data.currentBalance;
//                     final bool showBalance = (pin == "0" || pin == "00" || hide);

//                     return Text(
//                       '\u{20B9} ${showBalance ? formatMoneyIndian(balance.toString(), lock[randomIndex]) : lock[randomIndex]}',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.bold,
//                         fontSize: 20,
//                         color: AppColors.backgroundColor,
//                       ),
//                     );
//                   }),
//                   setPinForAccountHide(context),
//                 ],
//               ),

//               // Quick check row
//               Row(
//                 children: [
//                   Image.network(
//                     data.bankLogo,
//                     width: 20,
//                     height: 20,
//                     fit: BoxFit.fitWidth,
//                     errorBuilder: getErrorBankLogo(),
//                   ),

//                   const SizedBox(width: 8),

//                   InkWell(
//                     onTap: () {
                    
//                     },
//                     child: Text(
//                       "Quick check",
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w400,
//                         fontSize: 12,
//                         color: AppColors.backgroundColor,
//                       ).copyWith(
//                         decoration: TextDecoration.underline,
//                         decorationColor: AppColors.backgroundColor,
//                         decorationThickness: 1.5,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: Colorcodes.elevation5),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// //   Widget getListViewBankInfo(data) {
// //     int randomIndex = Random().nextInt(lock.length);
// //     if (randomIndex == lock.length) randomIndex = 0;
   
// //     return Container(
// //         padding: EdgeInsets.symmetric(horizontal: Colorcodes.paddingHorizontal,vertical: Colorcodes.paddingHorizontal / 6),
// //         decoration: BoxDecoration(
// //           color: AppColors.accentColor,
// //           borderRadius: BorderRadius.circular(16),
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           mainAxisAlignment: MainAxisAlignment.spaceAround,
// //           children: [
// //             SizedBox(height: Colorcodes.borderRadius10),
// //             Row(
// //               children: [
// //             Image.network
// //             (
// //                 data['bankLogo'],
// //                 width: 30,
// //                 height: 30,
// //                 fit: BoxFit.fitWidth,
// //                 errorBuilder: getErrorBankLogo(),
// //             ),
// //              SizedBox(width: Colorcodes.borderRadius10),
// //                 Text(
// //                   data['bankName'],
// //                   style: FontManager().getTextStyle(context,
// //                       lWeight: FontWeight.normal,
// //                       fontSize: 18,
// //                       color: AppColors.backgroundColor),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: Colorcodes.borderRadius),
// //             Text(
// //               HomepageStringsDart().accountNumberLabel + data['maskedAccNumber'],
// //               style: FontManager().getTextStyle(context,
// //                   lWeight: FontWeight.bold,
// //                   fontSize: 16,
// //                   color: AppColors.backgroundColor),
// //             ),
// //             SizedBox(height: Colorcodes.borderRadius10),
// //             Text(HomepageStringsDart().availableBalanceLabel,
// //                 style: FontManager().getTextStyle(context,
// //                     lWeight: FontWeight.w400,
// //                     fontSize: 12,
// //                     color: AppColors.backgroundColor)),
            
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Obx(() {
// //   // use .value so Obx actually depends on these reactive variables
// //   final String pin = userController.cupertinoPin.value;
// //   final bool hide = hideBackAccountPassword.value;

// //   final balance = data['currentBalance'];

// //   // If API didn't return balance -> show small text (no lock)
// //   if (balance == null) {
// //     return Text(
// //       "Balance not available",
// //       style: FontManager().getTextStyle(
// //         context,
// //         lWeight: FontWeight.w500,
// //         fontSize: 14,
// //         color: AppColors.backgroundColor,
// //       ),
// //     );
// //   }

// //   // compute showBalance inside Obx using reactive values
// //   final bool showBalance = (pin == "0" || pin == "00" || hide);

// //   return Text(
// //     '\u{20B9} ${showBalance ? formatMoneyIndian(balance, lock[randomIndex]) : lock[randomIndex]}',
// //     style: FontManager().getTextStyle(
// //       context,
// //       lWeight: FontWeight.bold,
// //       fontSize: 20,
// //       color: AppColors.backgroundColor,
// //     ),
// //   );
// // })
// // ,
// //               //  Obx(()=> 
// //               //  Text(
// //               //     '\u{20B9} ${(hideBackAccountPassword.value || userController.cupertinoPin.value == "0" || userController.cupertinoPin.value == "00") ? formatMoneyIndian(data['currentBalance'] ?? "null",lock[randomIndex]) : lock[randomIndex]}',
// //               //     style: FontManager().getTextStyle(context,
// //               //         lWeight: FontWeight.bold,
// //               //         fontSize: 20,
// //               //         color: AppColors.backgroundColor),
// //               //  )
// //               //  ),
// //                 //  locker(context),
// //                 setPinForAccountHide(context)
// //               ],
// //             ),
// //             SizedBox(height: Colorcodes.elevation5),
// //           ],
// //         ));
// //   }

//   Widget locker(context) {
//     return Row(
//       children: [
//         _buildPicker("firstDigit", context),
//          Container(
//         width: 1.2,
//         height: 20,
//         color: AppColors.backgroundColor,
//         margin: EdgeInsets.symmetric(horizontal: 2),
//       ),
//         _buildPicker("secondDigit", context),
//       ],
//     );
//   }

//   void setBack() {
//     setState(() {
//       firstDigit.value = 0;
//       secondDigit.value = 0;
//       firstDigitController.jumpToItem(0);
//       secondDigitController.jumpToItem(0);
//     });
//   }

//   Widget _buildPicker(String controllerValue, BuildContext context) {
//     double height = MediaQuery.of(context).size.height;

//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         color: Colors.transparent
//       ),
      
//       child: CupertinoPicker(
//         backgroundColor: Colors.transparent,
        
      
//         itemExtent: 30,
//         scrollController: controllerValue == "firstDigit"
//             ? firstDigitController
//             : secondDigitController,
//         onSelectedItemChanged: (index) {
//           if (controllerValue == "firstDigit") {
//             firstDigit.value = index;
//           } else {
//             secondDigit.value = index;
//           }
//           pinPasswordVerifyDebounced(
//               firstDigit.value.toString() + "" + secondDigit.value.toString(),
//               context,
//               setBack);
//         },
//         children: List<Widget>.generate(
//           10,
//           (index) => Center(
//             child: Text(
//               index.toString(),
//               style: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.normal,
//                   fontSize: 16,
//                   color: AppColors.backgroundColor),
//             ),
//           ),
//         ),
//       ),
//     );
  
//   }

// Widget setPinForAccountHide(context) {
//   return Obx(() {
//     if (userController.cupertinoPin.value == "0" || userController.cupertinoPin.value == "00" || userController.cupertinoPin.value.isEmpty ||  userController.cupertinoAttemptCount.value) { // Handle empty case too
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 5),
//         child: InkWell(
//           onTap: () {

//             if(userController.cupertinoAttemptCount.value)
//             {
//               resetCupertinoPin(context);
//               return;
//             }
//             showModalBottomSheet(
//               context: context,
//               backgroundColor: Colorcodes.appBarColor,
//               builder: (context) {
//                 return setPassword(context);
//               },
//             );
//           },
//          child:Stack(
//   alignment: Alignment.center,
//   children: [
//     AvatarProfileImageZero(
//       url: HomePageIcons.setPin,
//       width: 20,
//       height: 20,
//     ),

//     Text(
//       "Set Pin",
//       style: FontManager().getTextStyle(
//         context,
//         lWeight: FontWeight.bold,
//         fontSize: 16,           
//         color: Colors.white,   
//       ),
//       textAlign: TextAlign.center,
//     ),
//   ],
// )

//         ),
//       );
//     } else {
//       return Stack(
//   alignment: Alignment.center,
//   children: [
//     AvatarProfileImageZero(
//       url: HomePageIcons.setPin,
//       width: 20,
//       height: 20,
//     ),

//    locker(context),
//   ],
// );
      
//     }
//   });
// }
 
//   Widget setPassword(context) {
//     double height = MediaQuery.of(context).size.height;
//    RxInt selectedNumber1 = 0.obs; // Make first digit reactive
//     RxInt selectedNumber2 = 0.obs;  // Second selected number

//     return SafeArea(
//       child: Container(
//         //  color: AppColors.backgroundColor,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(16), topRight: Radius.circular(16)),
//           color: AppColors.backgroundColor,
//         ),
//         width: MediaQuery.of(context).size.width,
//         height: height > 0 ? height / 3.8 : 100, // Fallback height
//         padding: EdgeInsets.symmetric(horizontal: 30, vertical: AppSizes.p10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top:AppSizes.p20),
//               child: textStyle(
//                   context: context,
//                   text: HomepageStringsDart().setLockTitle,
//                   fontsize: 20,
//                   fontWeight: FontWeight.bold),
//             ),
//             // First Cupertino Picker
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width / 6,
//                       height: MediaQuery.of(context).size.height /
//                           16, // Adjust height as needed
//                       child: CupertinoPicker(
//                         itemExtent: 26.0, // Height of each item
//                         onSelectedItemChanged: (int index) {
//                           selectedNumber1.value = index; // Update first number
//                         },
//                         children: List<Widget>.generate(10, (int index) {
//                           return Center(child: Text(index.toString()));
//                         }), // Numbers 0-99
//                       ),
//                     ),
      
//                     // Second Cupertino Picker
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width / 6,
//                       height: MediaQuery.of(context).size.height /
//                           16, // Adjust height as needed
//                       child: CupertinoPicker(
//                         itemExtent: 26.0, // Height of each item
//                         onSelectedItemChanged: (int index) {
//                           selectedNumber2.value = index; // Update second number
//                         },
//                         children: List<Widget>.generate(10, (int index) {
//                           return Center(child: Text(index.toString()));
//                         }), // Numbers 0-99
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 30,
//                 ),
//                Obx(() {
//                   String combinedInput = '${selectedNumber1.value}${selectedNumber2.value}';
//                   bool isInvalidPin = combinedInput == "00";
                
//                   return InkWell(
//                     onTap: isInvalidPin
//                         ? null
//                         : () {
//                             setPasswordApiCalled(context, combinedInput);
//                           },
//                     child:  Container(
//                       width: MediaQuery.of(context).size.width / 1.1,
//                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: AppSizes.p20),
//                       decoration: BoxDecoration(
//                         color: isInvalidPin
//                             ? AppColors.bg3
//                             : AppColors.primaryColor, // Button color based on validity
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: Center(
//                         child: Text(
//                           HomepageStringsDart().confirmButton,
//                           style: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: AppColors.bg5,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

  
//   PopupMenuEntry<String> getItemOfListPopupMenuItem(
//       String bankName, String fipId, var data, String id) {
//     return PopupMenuItem<String>(
//       value: id, // Ensure value is of type String
//       child: Text(bankName),
//     );
//   }
  
//  Widget connectBankAccount(BuildContext context) {
//    return Container(
//   color: AppColors.backgroundColor,
//   padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//   child: Center(
//     child: InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ShareAccountLogin(),
//           ),
//         );
     
//       },
//       child: Column(
//         children: [
//             Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                               height: 30,
//                               width: 30,
//                               child: Lottie.asset("assets/splashScreen/fetchLoad.json"),
//                  ),
//                  textStyle(context: context, text: HomepageStringsDart().noBankLinked, fontsize: 11, fontWeight: FontWeight.bold),
//                 ],
//               ),
//           Card(
//             elevation: 2,
//             color: AppColors.primaryColor,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             child: Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   AvatarProfileImage(
//                     width: 2,
//                     height: 10,
//                     url: bankImage,
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "Securely connect your bank account",
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w500,
//                       fontSize: 15,
//                       color: Colorcodes.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   ),
// );

// }
// }


 
 
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/bankServices/bankSlider.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/resetPin.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:lottie/lottie.dart';
import '../Constants/core/app_component_sizes.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../backed_connections/bankServices/nextFetch.dart';
import '../components/shared_utils.dart';
import '../model/bank_model.dart';

RxInt firstDigit = 0.obs;
RxInt secondDigit = 0.obs;
RxBool digitLoad = false.obs;

class NumberPickerScreen extends StatefulWidget {
  @override
  State<NumberPickerScreen> createState() => _NumberPickerScreenState();
}

class _NumberPickerScreenState extends State<NumberPickerScreen> {
  final FixedExtentScrollController firstDigitController =
      FixedExtentScrollController(initialItem: 0);
  final FixedExtentScrollController secondDigitController =
      FixedExtentScrollController(initialItem: 0);



  

  List lock = HomepageStringsDart().lockPatterns;


late PageController _pageController;
int activeIndex = 0;
bool showFlipSlider = false;
int flipToIndex = 0;

@override
void initState() {
  super.initState();

  activeIndex = scrollBankPage.value;

  _pageController = PageController(
    initialPage: activeIndex,
  );
}

  @override
  Widget build(BuildContext context) {
   
    // Check for zero to avoid division by zero
    return Obx(() {
      if (loadBanks.value) return const BankSlider();
    
      return showFlipSlider
          ? avatarSlider2() // 🔥 flip UI
          : avatarSlider(); // 👈 normal swipe UI
    });
  }

Widget avatarSlider() {
  if (bankAccountLinkedList.isEmpty) return connectBankAccount(context);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        // color:  AppColors.redColor,
        height: AppComponentSizes.h4,
        child: PageView.builder(
          itemCount: bankAccountLinkedList.length,
          controller: PageController(
            viewportFraction: 1.0,
            initialPage: scrollBankPage.value,
          ), 
          onPageChanged: (index) {
            final account = bankAccountLinkedList[index];
            accountId.value = account.accountId;
            LastFetchDate.value = account.lastFetch;
            nextFecthDate.value = account.nextFetch;
            fetchCount.value = account.fetchCount.toString();
            BankName.value = account.bankName;
            BankUrl.value = account.bankLogo;
            scrollBankPage.value = index;
            calledFunctionToFetchData(context);
          },
          itemBuilder: (context, index) {
            final account = bankAccountLinkedList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: getListViewBankInfo(account),
            );
          },
        ),
      ),
  
       SizedBox(height: AppSizes.h6),
  
      Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          bankAccountLinkedList.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width:  8,  // active dot grows
            decoration: BoxDecoration(
              color: scrollBankPage.value == index
                  ? AppColors.primaryColor
                  : AppColors.accentColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      )),
  
      
    ],
  );
}


 Widget avatarSlider2() {
  if (bankAccountLinkedList.isEmpty) return connectBankAccount(context);
Future.microtask(() {
  _pageController.jumpToPage(flipToIndex);

  setState(() {
    activeIndex = flipToIndex;
    scrollBankPage.value = flipToIndex;
  });

  final account = bankAccountLinkedList[flipToIndex];
  accountId.value = account.accountId;
  LastFetchDate.value = account.lastFetch;
  nextFecthDate.value = account.nextFetch;
  fetchCount.value = account.fetchCount.toString();
  BankName.value = account.bankName;
  BankUrl.value = account.bankLogo;

  calledFunctionToFetchData(context);

  // 🔁 return to normal slider after flip
  Future.delayed(const Duration(milliseconds: 750), () {
    if (mounted) {
      setState(() {
        showFlipSlider = false;
      });
    }
  });
});

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        // color:  AppColors.redColor,
        height: MediaQuery.sizeOf(context).height/4,
        child:
       SizedBox(
  height: MediaQuery.sizeOf(context).height / 4,
  child: Stack(
    alignment: Alignment.center,
    children: [
      /// 🔥 MAIN CARD (VISIBLE)
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 650),
        transitionBuilder: (child, animation) {
         final rotate = Tween(begin: pi, end: 0.0).animate(
  CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOutCubic, // 🔥 much smoother
  ),
);


          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(-rotate.value),
                child: child,
              );
            },
          );
        },
        child: KeyedSubtree(
          key: ValueKey(activeIndex),
          child: getListViewBankInfo(
            bankAccountLinkedList[activeIndex],
          ),
        ),
      ),

      /// 🧠 HIDDEN PageView (LOGIC ONLY)
      IgnorePointer(
        ignoring: true,
        child: Opacity(
          opacity: 0,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bankAccountLinkedList.length,
            onPageChanged: (index) {
              setState(() {
                activeIndex = index;
                scrollBankPage.value = index;
              });
            },
            itemBuilder: (_, __) => const SizedBox(),
          ),
        ),
      ),
    ],
  ),
)

      ),

       SizedBox(height: AppSizes.h6),

      Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          bankAccountLinkedList.length,
          (index) => AnimatedContainer(
            duration:const  Duration(milliseconds: 250),
            margin:const  EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width:  8,  // active dot grows
            decoration: BoxDecoration(
              color: scrollBankPage.value == index
                  ? AppColors.primaryColor
                  : AppColors.accentColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      )),
  
      
    ],
  );
}

 
Widget getListViewBankInfo(BankAccountModel data) {
  int randomIndex = Random().nextInt(lock.length);
  if (randomIndex == lock.length) randomIndex = 0;

  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height / 3.6,
      child: Stack(
        children: [
          /// 🔵 BACKGROUND
          Positioned.fill(
            child: AvatarProfileImageZero(
              url: HomePageIcons.bankContainerBg,
              width: 1,
              height: 1,
            ),
          ),

          /// 🔤 MAIN CONTENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: AppSizes.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSizes.h40), // space for top-right logos

                /// NEXT FETCH
                Nextfetch(),
                
                SizedBox(height: AppSizes.h10),
                
                /// ACCOUNT NUMBER
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.network(
                      data.bankLogo,
                      width: 28,
                      height: 28,
                      fit: BoxFit.fitWidth,
                      errorBuilder: getErrorBankLogo(),
                    ),
                    SizedBox(width: AppSizes.w8),
                    Text(
                      data.maskedAccNumber,
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 16,
                        lWeight: FontWeight.w700,
                        color: AppColors.backgroundColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.h10),

                /// LABEL
                Text(
                  "Available balance",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 12,
                    lWeight: FontWeight.w500,
                    color: AppColors.grey,
                  ),
                ),

                SizedBox(height: AppSizes.h10),

                /// BALANCE
                Obx(() {
                  final String pin = userController.cupertinoPin.value;
                  final bool hide = hideBackAccountPassword.value;
                  final double balance = data.currentBalance;
                  final bool showBalance =
                      (pin == "0" || pin == "00" || hide);

                  return Text(
                    '\u{20B9} ${showBalance ? formatMoneyIndian(balance.toString(), lock[randomIndex]) : lock[randomIndex]}',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.backgroundColor,
                      lineHeight: 24/fontSize
                    ),
                  );
                }),

                SizedBox(height: AppSizes.h14),

                /// QUICK CHECK
                Row(
                  children: [
                    Image.network(
                      data.bankLogo,
                      width: 18,
                      height: 18,
                      errorBuilder: getErrorBankLogo(),
                    ),
                    const SizedBox(width: AppSizes.w6),
                    Text(
                      "Quick check",
                      style: FontManager()
                          .getTextStyle(
                            context,
                            fontSize: 12,
                            lWeight: FontWeight.w500,
                            color: AppColors.grey,
                            lineHeight: 18/fontSize
                          )
                          .copyWith(
                            decoration: TextDecoration.underline,
                            decorationThickness: 1.2,
                            decorationColor:
                                AppColors.grey,
                          ),
                    ),
                  ],
                ),
             
              ],
            ),
          ),

          /// 🔁 TOP-RIGHT OTHER BANK LOGOS (CORRECT POSITION)
          if (bankAccountLinkedList.length > 1)
            Positioned(
              top:AppSizes.p8,
              right: 0,
              child: Container(
                height: 40,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(6),
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                   ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: bankAccountLinkedList
                      .asMap()
                      .entries
                      .where((e) =>
                          e.value.accountId != data.accountId)
                      .map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            flipToIndex = entry.key;
                            showFlipSlider = true;
                          });
                        },
                        child: Image.network(
                          entry.value.bankLogo,
                          height: 22,
                          width: 22,
                          fit: BoxFit.contain,
                          errorBuilder: getErrorBankLogo(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          /// 🔐 SET PIN BUTTON
          Positioned(
            right:AppSizes.p16,
            bottom: 30,
            child: setPinForAccountHide(context),
          ),
        ],
      ),
    ),
  );
}

  Widget locker(context) {
    return Row(
      children: [
        _buildPicker("firstDigit", context),
         Container(
        width: 1.2,
        height: 15,
        color: AppColors.backgroundColor,
        margin: const EdgeInsets.symmetric(horizontal: 2),
      ),
        _buildPicker("secondDigit", context),
      ],
    );
  }

  void setBack() {
    setState(() {
      firstDigit.value = 0;
      secondDigit.value = 0;
      firstDigitController.jumpToItem(0);
      secondDigitController.jumpToItem(0);
    });
  }

  Widget _buildPicker(String controllerValue, BuildContext context) {

    return Container(
      width: 40,
      height:40,
      decoration:  BoxDecoration(
        color: AppColors.transparentColor,
      ),
      
      child: CupertinoPicker(
        backgroundColor: Colors.transparent,
        
      
        itemExtent: 30,
        scrollController: controllerValue == "firstDigit"
            ? firstDigitController
            : secondDigitController,
        onSelectedItemChanged: (index) {
          if (controllerValue == "firstDigit") {
            firstDigit.value = index;
          } else {
            secondDigit.value = index;
          }
          pinPasswordVerifyDebounced(
              firstDigit.value.toString() + "" + secondDigit.value.toString(),
              context,
              setBack);
        },
        children: List<Widget>.generate(
          10,
          (index) => Center(
            child: Text(
              index.toString(),
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.normal,
                  fontSize: 16,
                  color: AppColors.backgroundColor),
            ),
          ),
        ),
      ),
    );
  
  }

Widget setPinForAccountHide(context) {
  return Obx(() {
    if (userController.cupertinoPin.value == "0" || userController.cupertinoPin.value == "00" || userController.cupertinoPin.value.isEmpty ||  userController.cupertinoAttemptCount.value) { // Handle empty case too
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
        child: InkWell(
          onTap: () {

            if(userController.cupertinoAttemptCount.value)
            {
              resetCupertinoPin(context);
              return;
            }
            showModalBottomSheet(
              context: context,
              backgroundColor: Colorcodes.appBarColor,
              builder: (context) {
                return setPassword(context);
              },
            );
          },
         child:Stack(
  alignment: Alignment.center,
  children: [
    AvatarProfileImageZero(
      url: HomePageIcons.setPin,
      width: 20,
      height: 26,
    ),

    Text(
      "Set Pin",
      style: FontManager().getTextStyle(
        context,
        lWeight: FontWeight.w500,
        fontSize: 16,           
        color: AppColors.backgroundColor,
        lineHeight: 24/fontSize   
      ),
      textAlign: TextAlign.center,
    ),
  ],
)

        ),
      );
    } else {
      return Stack(
  alignment: Alignment.center,
  children: [
    AvatarProfileImageZero(
      url: HomePageIcons.setPin,
      width: 20,
      height: 20,
    ),

   locker(context),
  ],
);
      
    }
  });
}
 
  Widget setPassword(context) {
    double height = MediaQuery.of(context).size.height;
   RxInt selectedNumber1 = 0.obs; // Make first digit reactive
    RxInt selectedNumber2 = 0.obs;  // Second selected number

    return SafeArea(
      child: Container(
        //  color: AppColors.backgroundColor,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          color: AppColors.backgroundColor,
        ),
        width: MediaQuery.of(context).size.width,
        height: height > 0 ? height / 3.8 : 100, // Fallback height
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: AppSizes.p10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top:AppSizes.p20),
              child: textStyle(
                  context: context,
                  text: HomepageStringsDart().setLockTitle,
                  fontsize: 20,
                  fontWeight: FontWeight.bold),
            ),
            // First Cupertino Picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 6,
                      height: MediaQuery.of(context).size.height /
                          16, // Adjust height as needed
                      child: CupertinoPicker(
                        itemExtent: 26.0, // Height of each item
                        onSelectedItemChanged: (int index) {
                          selectedNumber1.value = index; // Update first number
                        },
                        children: List<Widget>.generate(10, (int index) {
                          return Center(child: Text(index.toString()));
                        }), // Numbers 0-99
                      ),
                    ),
      
                    // Second Cupertino Picker
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 6,
                      height: MediaQuery.of(context).size.height /
                          16, // Adjust height as needed
                      child: CupertinoPicker(
                        itemExtent: 26.0, // Height of each item
                        onSelectedItemChanged: (int index) {
                          selectedNumber2.value = index; // Update second number
                        },
                        children: List<Widget>.generate(10, (int index) {
                          return Center(child: Text(index.toString()));
                        }), // Numbers 0-99
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
               Obx(() {
                  String combinedInput = '${selectedNumber1.value}${selectedNumber2.value}';
                  bool isInvalidPin = combinedInput == "00";
                
                  return InkWell(
                    onTap: isInvalidPin
                        ? null
                        : () {
                            setPasswordApiCalled(context, combinedInput);
                          },
                    child:  Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: AppSizes.p20),
                      decoration: BoxDecoration(
                        color: isInvalidPin
                            ? AppColors.grey
                            : AppColors.primaryColor, // Button color based on validity
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          HomepageStringsDart().confirmButton,
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.backgroundColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  
  PopupMenuEntry<String> getItemOfListPopupMenuItem(
      String bankName, String fipId, var data, String id) {
    return PopupMenuItem<String>(
      value: id, // Ensure value is of type String
      child: Text(bankName),
    );
  }
  
 Widget connectBankAccount(BuildContext context) {
   return Container(
  color: AppColors.backgroundColor,
  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
  child: Center(
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShareAccountLogin(),
          ),
        );
     
      },
      child: Column(
        children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                              height: 30,
                              width: 30,
                              child: Lottie.asset("assets/splashScreen/fetchLoad.json"),
                 ),
                 textStyle(context: context, text: HomepageStringsDart().noBankLinked, fontsize: 11, fontWeight: FontWeight.bold),
                ],
              ),
          Card(
            elevation: 2,
            color: AppColors.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarProfileImage(
                    width: 2,
                    height: 10,
                    url: bankImage,
                  ),
                  SizedBox(height: AppSizes.h10),
                  Text(
                    "Securely connect your bank account",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 15,
                      color: AppColors.backgroundColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.h10),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

}
}
 
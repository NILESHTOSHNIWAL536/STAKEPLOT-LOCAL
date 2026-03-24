// import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
// import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
// import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/integration.dart';
// import 'package:flutter_application_code_stakeplot/loginservices/login.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
// import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
// import 'package:flutter_application_code_stakeplot/main.dart';
// import 'package:flutter_application_code_stakeplot/onboarding_screens/onboarding_screen.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// class Access extends StatefulWidget {
//   const Access({super.key});

//   @override
//   State<Access> createState() => _AccessState();
// }

// class _AccessState extends State<Access> {
//   RxBool flag = true.obs;
//   @override
//   void initState() {
//     super.initState();
//   }

//   String formatDate(String dateString) {
//     DateTime date = DateTime.parse(dateString);
//     return DateFormat('d MMM yyyy').format(date); // Format as Aug 2024
//   }

//   Widget topHeader() {
//     return Column(children: [
//       Padding(
//           padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 FinvuStrings().givePermission,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: AppColors.bg1,
//                 ),
//               ),
//               SizedBox(height: 10),
//               RichText(
//                 text: TextSpan(
//                   text:
//                       FinvuStrings().shareAccountsWithStakeplot, // Regular text
//                   style: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.w400,
//                     fontSize: 17,
//                     color: AppColors.bg1,
//                   ),
//                   children: [
//                     TextSpan(
//                       text: FinvuStrings()
//                           .smartFinanceInsights, // Highlighted text
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight:
//                             FontWeight.w600, // Make it bold or different weight
//                         fontSize: 17,
//                         color: AppColors.primaryColor, // Highlight color
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//             ],
//           ))
//     ]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         bottomNavigationBar: SafeArea(child: BottomBar()),
//         appBar: getAppBar(context),
//         // backgroundColor: AppColors.backgroundColor,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(10.0, 16, 16, 0),
//             child: Obx(
//               () => !flag.value
//                   ? Loader()
//                   : Container(
//                       height: MediaQuery.of(context).size.height / 1.2,
//                       width: MediaQuery.of(context).size.width,
//                       // color: Colorcodes.moneyOrange,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             children: [
//                               topHeader(),
//                               informationBankAccount(),
//                               pauseOrCancle(),
//                             ],
//                           ),
//                           givePermissionOrDecline(),
//                         ],
//                       ),
//                     ),
//             ),
//           ),
//         ));
//   }

//   Widget informationBankAccount() {
//     String range = formatDate(finvuConsentRequestDetailInfo
//             .consentDateTimeRange.from
//             .toString()) +
//         " to " +
//         formatDate(
//             finvuConsentRequestDetailInfo.consentDateTimeRange.to.toString());
//     return Container(
//       height: MediaQuery.of(context).size.height / 2,
//       width: MediaQuery.of(context).size.width,
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             accounts(
//                 FinvuStrings().accountsSharedTitle, // Direct access
//                 "${seletedAccountIds.length} ${FinvuStrings().accountsSharedValue}",
//                 Icons.account_balance_wallet_outlined),
//             accounts(FinvuStrings().permissionValidity, range,
//                 Icons.date_range_rounded), // Direct access
//             accounts(
//                 FinvuStrings().frequencyOfAccess,
//                 FinvuStrings().frequencyOfAccessSubText,
//                 Icons.access_time), // Direct access
//             getInfomationsAboutUserConsnt(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget accountLikedInfo() {
//     return Column(
//       children: seletedAccountInfomations
//           .map((data) => accountInfoDetailsUi(data))
//           .toList(),
//     );
//   }

//   Widget accountInfoDetailsUi(FinvuLinkedAccountDetailsInfo data) {
//     return Container(
//       // color: Colorcodes.billBody,
//       width: MediaQuery.of(context).size.width / 1.5,
//       child: Wrap(
//         runAlignment: WrapAlignment.spaceAround,
//         // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           textStyle(data.fipName),
//           const SizedBox(
//             width: 5,
//           ),
//           textStyle(data.accountType),
//           const SizedBox(
//             width: 5,
//           ),
//           textStyle(data.maskedAccountNumber),
//         ],
//       ),
//     );
//   }

//   Widget viewMore() {
//     return
//         // Section 4: View More Details
//         GestureDetector(
//       onTap: () {
//         // Add navigation or functionality here
//         showModalBottomSheet(
//             context: context,
//             builder: (BuildContext context) {
//               return getInfomationsAboutUserConsnt();
//             });
//       },
//       child: Center(
//         child: Text(
//           FinvuStrings().viewMoreDetails,
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.w600,
//             fontSize: 15,
//             color: AppColors.primaryColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget getInfomationsAboutUserConsnt() {

//     return Container(
//       width: MediaQuery.of(context).size.width / 1,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(20.0, 0, 16, 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(0.0, 0, 20, 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: Colorcodes.space),
//                   Text(
//                     FinvuStrings().approvalRequestedOn,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     formatDate(finvuConsentRequestDetailInfo
//                         .consentDateTimeRange.from
//                         .toString()),
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w600,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                   SizedBox(height: Colorcodes.space),
//                   Text(
//                     FinvuStrings().purpose,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     finvuConsentRequestDetailInfo.consentPurposeInfo.text,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w600,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                   SizedBox(height: Colorcodes.space),
//                   Text(
//                     FinvuStrings().accountDetails,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     FinvuStrings().profileSummaryTransactions,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w600,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                   SizedBox(height: Colorcodes.space),
//                   Text(
//                     FinvuStrings().dataLife,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     finvuConsentRequestDetailInfo.consentDataLifePeriod.value
//                             .toString() +
//                         " " +
//                         finvuConsentRequestDetailInfo.consentDataLifePeriod.unit
//                             .toString(),
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w600,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                   SizedBox(height: Colorcodes.space),
//                   Text(
//                     FinvuStrings().approvalExpiry,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     formatDate(finvuConsentRequestDetailInfo
//                         .consentDateTimeRange.to
//                         .toString()),
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w600,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                   SizedBox(height: Colorcodes.space),
//                   Text(
//                     FinvuStrings().accountTypes,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Wrap(
//                       children: finvuConsentRequestDetailInfo.fiTypes!
//                           .map((e) => Text(
//                                 e + ",",
//                                 style: FontManager().getTextStyle(
//                                   context,
//                                   lWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                   color: AppColors.bg1,
//                                 ),
//                               ))
//                           .toList()),
//                   SizedBox(height: 20),
//                   // InkWell(
//                   //     onTap: () {
//                   //       Navigator.pop(context);
//                   //     },
//                   //     child: getButton(context, "Understand")),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget accounts(String title, String value, IconData icon) {
//     return Container(
//       // width: MediaQuery.of(context).size.width,
//       padding: const EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 20),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Container(
//             padding: EdgeInsets.all(AppSizes.p4),
//             decoration: BoxDecoration(
//                 color: AppColors.backgroundColor,
//                 borderRadius: BorderRadius.circular(10)),
//             child: Icon(
//               icon,
//               color: AppColors.primaryColor,
//               size: 30,
//             ),
//           ),
//           const SizedBox(
//             width: 10,
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: AppColors.bg1,
//                 ),
//               ),
//               const SizedBox(
//                 height: 5,
//               ),
//               Container(
//                 width: MediaQuery.of(context).size.width / 1.7,
//                 child: Text(
//                   value,
//                   style: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.w400,
//                     fontSize: 14,
//                     color: AppColors.bg1,
//                   ),
//                   overflow: TextOverflow.clip,
//                 ),
//               ),
//               title == "Accounts Shared"
//                   ? accountLikedInfo()
//                   : SizedBox.shrink()
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget viewInfo() {
//     return InkWell(
//       onTap: () {
//         // showModalBottomSheet(
//         //     context: context,
//         //     builder: (context) {
//         //       return Container(
//         //         child: accountInfo(),
//         //       );
//         //     });
//       },
//       child: Padding(
//         padding: const EdgeInsets.only(left: 3, top: 5),
//         child: Text(
//           FinvuStrings().viewMore,
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.w400,
//             fontSize: 14,
//             color: Colorcodes.blue,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget accountInfo() {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height / 3,
//       padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p4),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(AppSizes.p8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   textStyle(FinvuStrings().linkedBankAccount, 15,
//                       AppColors.primaryColor, FontWeight.bold),
//                   InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Icon(Icons.close)),
//                 ],
//               ),
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: fetchAccountData.map((e) {
//                 String url = bankImageAndid.containsKey(e.fipId)
//                     ? bankImageAndid[e.fipId].toString()
//                     : "".toString();
//                 //  var d=await finvuManager.fetchFIPDetails(e.fipId);
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 5),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Container(
//                           width: 40,
//                           height: 30,
//                           child: Image.network(
//                             url,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                       textStyle(e.fipName),
//                       const SizedBox(
//                         width: 5,
//                       ),
//                       textStyle(e.accountType),
//                       const SizedBox(
//                         width: 5,
//                       ),
//                       textStyle(e.maskedAccountNumber),
//                       Obx(() => addAccount.value
//                           ? getcheckBox(e.accountReferenceNumber)
//                           : getcheckBox(e.accountReferenceNumber))
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget getcheckBox(String fipId) {
//     return Padding(
//       padding: const EdgeInsets.only(left:AppSizes.p10),
//       child: Container(
//         width: 50,
//         height: 50,
//         child: Checkbox(
//             value: seletedAccountIds.contains(fipId),
//             onChanged: (value) {
//               if (seletedAccountIds.contains(fipId)) {
//                 seletedAccountIds.remove(fipId);
//               } else {
//                 seletedAccountIds.add(fipId);
//               }
//               addAccount.value = !addAccount.value;
//             }),
//       ),
//     );
//   }

//   Widget textStyle(text,
//       [double fontsize = 12,
//       Color c = AppColors.bg1,
//       FontWeight fontWeight = FontWeight.w500]) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: AppSizes.p6),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(
//             width: 7,
//           ),
//           Text(
//             text.toString(),
//             style: FontManager().getTextStyle(context,
//                 lWeight: fontWeight, fontSize: fontsize, color: c),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget pauseOrCancle() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: AppSizes.p20),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(Icons.info_outline, color: Colors.grey),
//           SizedBox(width: 10),
//           Container(
//             width: MediaQuery.of(context).size.width / 1.2,
//             child: Text(
//               FinvuStrings().pauseOrCancelSharing,
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.w400,
//                 fontSize: 15,
//                 color: AppColors.bg3,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget givePermissionOrDecline() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           InkWell(
//             onTap: () {
//               approveConsentRequest();
//             },
//             child: Container(
//               width: MediaQuery.of(context).size.width / 1.1,
//               padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p14),
//               decoration: BoxDecoration(
//                 color: AppColors.accentColor,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Center(
//                 child: Text(
//                   FinvuStrings().givePermission,
//                   style: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: AppColors.bg5,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           InkWell(
//             onTap: () async {
//               showDialogBoxForDecline(context);
//             },
//             child: Container(
//               width: MediaQuery.of(context).size.width / 1.1,
//               padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p20),
//               decoration: BoxDecoration(
//                 //color: AppColors.accentColor,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Center(
//                 child: Text(
//                   FinvuStrings().decline,
//                   style: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: AppColors.bg1,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void approveConsentRequest() async {
//     try {
//       FinvuConsentRequestDetailInfo finvuConsentRequestDetailInfo =
//           await finvuManager.getConsentRequestDetails(handleId.value);

//       FinvuProcessConsentRequestResponse response =
//           await finvuManager.approveConsentRequest(
//               finvuConsentRequestDetailInfo, seletedAccountInfomations);

//       snackBarCalled(context, SnackbarData().consentApproved);

//       FetchTransactionFromFinvuApi(context);
//     } catch (e) {
//       skipOrLets.value = "Skip";
//       snackBarCalledfail(context, SnackbarData().consentApproveError);
//     }
//   }

//   Widget getcheckBox2(String fipId) {
//     return Padding(
//       padding: const EdgeInsets.only(left:AppSizes.p10),
//       child: Container(
//         width: 50,
//         height: 50,
//         child: Checkbox(
//             value: seletedAccountIds.contains(fipId),
//             onChanged: (value) {
//               if (seletedAccountIds.contains(fipId)) {
//                 seletedAccountIds.remove(fipId);
//               } else {
//                 seletedAccountIds.add(fipId);
//               }
//               addAccount.value = !addAccount.value;
//             }),
//       ),
//     );
//   }

//   void showDialogBoxForDecline(BuildContext context) {
//     showDialog(
//       context: context,
//       useRootNavigator: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(10)), // Optional: rounded corners
//           child: Container(
//             width: 300, // Set width
//             height: 180, // Set height
//             padding: EdgeInsets.all(AppSizes.p16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment:
//                   CrossAxisAlignment.start, // Prevent excessive height
//               children: [
//                 textStyle(FinvuStrings().areYouSure, 20, AppColors.primaryColor,
//                     FontWeight.bold),
//                 SizedBox(height: 10),
//                 textStyle(FinvuStrings().declineConfirmation, 15),
//                 Spacer(),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       style: TextButton.styleFrom(
//                         side: BorderSide(color: AppColors.bg1), // Add border
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                               8), // Optional: Rounded corners
//                         ),
//                       ),
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: textStyle(FinvuStrings().no, 15),
//                     ),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     TextButton(
//                       style: TextButton.styleFrom(
//                         side: BorderSide(
//                             color: AppColors.primaryColor), // Add border
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                               8), // Optional: Rounded corners
//                         ),
//                       ),
//                       onPressed: () {
//                         decline();
//                       },
//                       child: textStyle(FinvuStrings().yes, 15),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void decline() async {
//     try {
//       FinvuConsentRequestDetailInfo consentInfo =
//           await finvuManager.getConsentRequestDetails(handleId.value);
//       finvuManager.denyConsentRequest(consentInfo);
//       logoutAndDisconnect();
//       Navigator.of(context).pushNamedAndRemoveUntil(
//           '/ShareAccountLogin', (Route<dynamic> route) => false);
//       Navigator.pushNamed(context, "/ShareAccountLogin");
//       snackBarCalledfail(context, SnackbarData().consentDeclined);
//     } catch (e) {
//       snackBarCalledfail(context, SnackbarData().consentDisapproveError);
//     }
//   }
// }


import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/integration.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/loginservices/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:flutter_application_code_stakeplot/onboarding_screens/onboarding_screen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../Constants/app_styles.dart';
import '../Constants/core/app_padding_sizes.dart';
import 'skipFInvuProcess.dart';

class Access extends StatefulWidget {
  const Access({super.key});

  @override
  State<Access> createState() => _AccessState();
}

class _AccessState extends State<Access> {
  RxBool flag = true.obs;
  RxBool showDetails = false.obs;

  @override
  void initState() {
    super.initState();
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMM yyyy').format(date); // Format as Aug 2024
  }
 double spaceSmall = 8;
 double spaceMedium = 10;
 double spaceLarge = 30;

  Widget topHeader() {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              RichText(
                text: TextSpan(
                  text:
                      FinvuStrings().shareAccountsWithStakeplot, // Regular text
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 16,
                    color: AppColors.accentColor,
                    lineHeight: 2.0
                  ),
                  children: [
                    TextSpan(
                      text: FinvuStrings()
                          .smartFinanceInsights, // Highlighted text
                      style: FontManager().getTextStyle(
                        context,
                        lWeight:
                            FontWeight.w500, // Make it bold or different weight
                        fontSize: 16,
                        color: AppColors.primaryColor, // Highlight color
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbg,
        bottomNavigationBar: SafeArea(child: BottomBar()),
        appBar:  AppBar(
    backgroundColor: AppColors.newbg,
    toolbarHeight: 40,
    actions: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
        child: GestureDetector(
          onTap: () {
            showSkipModal2(context);
          },
          child: Icon(
            Icons.login,
            color: AppColors.bg1,
            size: 30,
          ),
        ),
      ),
    ],
    leading: IconButton(
      icon: Icon(Icons.arrow_back_sharp),
      color: AppColors.bg1,
      onPressed: () {
        if(showDetails.value){
           showDetails.value=false;
        }
        else{
        Navigator.pop(context);
        }
      },
    ),
  ),
        // backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child:SingleChildScrollView(
              
              padding: const EdgeInsets.fromLTRB(10.0, 16, 16, 0),
              child: Obx(() {
                if (!flag.value) {
                  return Loader();
                }
            
                // 👇 THIS IS THE KEY
                if (showDetails.value) {
                 
                  return getInfomationsAboutUserConsnt();
                }
                return Container(
                        height: MediaQuery.of(context).size.height / 1.2,
                        width: MediaQuery.of(context).size.width,
                        // color: Colorcodes.moneyOrange,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                topHeader(),
                                informationBankAccount(),
                                pauseOrCancle(),
                              ],
                            ),
                            givePermissionOrDecline(),
                          ],
                        ),
                      );
              }
              ),
            ),
          
        ));
  }
Widget vSpace(double height) => SizedBox(height: height);
Widget dateRangeWidget() {
  final fromDate = formatDate(
    finvuConsentRequestDetailInfo.consentDateTimeRange.from.toString(),
  );

  final toDate = formatDate(
    finvuConsentRequestDetailInfo.consentDateTimeRange.to.toString(),
  );

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // FROM
       Icon(
        Icons.calendar_month_outlined,
        size: 16,
        color: AppColors.grey,
      ),
      const SizedBox(width: 6),
      Text(
        fromDate,
        style: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.bg1,
        ),
      ),

      const SizedBox(width: 8),

      // ARROW
       Icon(
        Icons.arrow_forward,
        size: 14,
        color: AppColors.grey,
      ),

      const SizedBox(width: 8),

      // TO
       Icon(
        Icons.calendar_month_outlined,
        size: 16,
        color: AppColors.grey,
      ),
      const SizedBox(width: 6),
      Text(
        toDate,
        style: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.accentColor,
        ),
      ),
    ],
  );
}

  Widget informationBankAccount() {
    String range = formatDate(finvuConsentRequestDetailInfo
            .consentDateTimeRange.from
            .toString()) +
        " to" +
        formatDate(
            finvuConsentRequestDetailInfo.consentDateTimeRange.to.toString());
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: AppSizes.p20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8)
              ),
              child: accounts(
                  FinvuStrings().accountsSharedTitle, // Direct access
                  "${seletedAccountIds.length} ${FinvuStrings().accountsSharedValue}",
                  Sign.accsShared),
            ),
            SizedBox(height: 12,),
            Container(
               decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8)
              ),
              child: accountsWithWidget(FinvuStrings().permissionValidity, dateRangeWidget(),
                  Sign.permissionValidity),
            ), // Direct access
            SizedBox(height: 12,),
            Container(
               decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8)
              ),
              child: accounts(
                  FinvuStrings().frequencyOfAccess,
                  FinvuStrings().frequencyOfAccessSubText,
                  Sign.frequencyOfAccess),
            ), // Direct access
            SizedBox(height: 22,),
                 viewMoreDetailsButton(),
            // getInfomationsAboutUserConsnt(),
          ],
        ),
      ),
    );
  }

Widget viewMoreDetailsButton() {
  return GestureDetector(
    onTap: () {
      showDetails.value = true; 
    },
    child: Center(
      child: Text(
        FinvuStrings().viewMoreDetails,
        style: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.primaryColor,
        ),
      ),
    ),
  );
}

  Widget accountLikedInfo() {
    return Column(
      children: seletedAccountInfomations
          .map((data) => accountInfoDetailsUi(data))
          .toList(),
    );
  }

  Widget accountInfoDetailsUi(FinvuLinkedAccountDetailsInfo data) {
    return Container(
      // color: Colorcodes.billBody,
      width: MediaQuery.of(context).size.width / 1.5,
      child: Wrap(
        runAlignment: WrapAlignment.spaceAround,
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          
          textStyle(data.fipName, 14, AppColors.bg3),
          const SizedBox(
            width: 5,
          ),
          textStyle(data.accountType, 14, AppColors.bg3),
          const SizedBox(
            width: 5,
          ),
          textStyle(data.maskedAccountNumber, 14, AppColors.bg3),
        ],
      ),
    );
  }

 
  Widget sectionHeader(String title, IconData icon) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.w400,
          fontSize: 16,
          color: AppColors.grey,
        ),
      ),
      squareIcon(icon),
    ],
  );
}

Widget sectionValue(String value) {
  return Text(
    value,
    style: FontManager().getTextStyle(
      context,
      lWeight: FontWeight.w500,
      fontSize: 16,
      color: AppColors.accentColor,
    ),
  );
}

Widget getInfomationsAboutUserConsnt() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.border),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                vSpace(spaceMedium),
                Text(
    "Details Of Shared Accounts",
    style: FontManager().getTextStyle(
      context,
      lWeight: FontWeight.w500,
      fontSize: 16,
      color: AppColors.primaryColor,
    ),
  ),
          vSpace(Colorcodes.space),
                sectionHeader(
                  FinvuStrings().approvalRequestedOn,
                  Icons.calendar_month_outlined,
                ),
                vSpace(spaceSmall),
                sectionValue(
                  formatDate(finvuConsentRequestDetailInfo
                      .consentDateTimeRange.from
                      .toString()),
                ),
        
                vSpace(spaceMedium),
        
                sectionHeader(
                  FinvuStrings().purpose,
                  Icons.description,
                ),
                vSpace(spaceSmall),
                sectionValue(
                  finvuConsentRequestDetailInfo.consentPurposeInfo.text,
                ),
        
                vSpace(spaceMedium),
        
                sectionHeader(
                  FinvuStrings().accountDetails,
                  Icons.person,
                ),
                vSpace(spaceSmall),
                sectionValue(
                  FinvuStrings().profileSummaryTransactions,
                ),
        
                vSpace(spaceMedium),
        
                sectionHeader(
                  FinvuStrings().dataLife,
                  Icons.access_time_filled,
                ),
                vSpace(spaceSmall),
                sectionValue(
                  "${finvuConsentRequestDetailInfo.consentDataLifePeriod.value} "
                  "${finvuConsentRequestDetailInfo.consentDataLifePeriod.unit}",
                ),
        
                vSpace(spaceMedium),
        
                sectionHeader(
                  FinvuStrings().approvalExpiry,
                  Icons.event_busy,
                ),
                vSpace(spaceSmall),
                sectionValue(
                  formatDate(finvuConsentRequestDetailInfo
                      .consentDateTimeRange.to
                      .toString()),
                ),
        
                vSpace(spaceMedium),
        
                sectionHeader(
                  FinvuStrings().accountTypes,
                  Icons.android_sharp,
                ),
                vSpace(spaceSmall),
        
                Wrap(
                  children: finvuConsentRequestDetailInfo.fiTypes!
                      .map(
                        (e) => Text(
                          "$e, ",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.accentColor,
                          ),
                        ),
                      )
                      .toList(),
                ),
        
                vSpace(spaceLarge),
              ],
            ),
          ),
        ),
                
                SizedBox(height: 50),
                InkWell(
            onTap: () {
              showDetails.value=false;
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 1.1,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p14),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "Got it",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.backgroundColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

  // Widget getInfomationsAboutUserConsnt() {

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
  //     child: Container(
  //       width: MediaQuery.of(context).size.width / 1,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(5),
  //         border: Border.all(color: AppColors.border)
  //       ),
  //       child: SingleChildScrollView(
  //         padding: const EdgeInsets.fromLTRB(20.0, 0, 16, 10),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.fromLTRB(0.0, 0, 20, 0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   SizedBox(height: Colorcodes.space),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         FinvuStrings().approvalRequestedOn,
  //                         style: FontManager().getTextStyle(
  //                           context,
  //                           lWeight: FontWeight.w400,
  //                           fontSize: 16,
  //                           color: AppColors.grey,
  //                         ),
  //                       ),
  //                       squareIcon(Icons.calendar_month_outlined), // calendar
   
  //                     ],
  //                   ),
  //                   SizedBox(height: 16),
  //                   Text(
  //                     formatDate(finvuConsentRequestDetailInfo
  //                         .consentDateTimeRange.from
  //                         .toString()),
  //                     style: FontManager().getTextStyle(
  //                       context,
  //                       lWeight: FontWeight.w500,
  //                       fontSize: 16,
  //                       color: AppColors.accentColor,
  //                     ),
  //                   ),
  //                   SizedBox(height: 22),
  //                   Row(
  //                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         FinvuStrings().purpose,
  //                         style: FontManager().getTextStyle(
  //                           context,
  //                           lWeight: FontWeight.w400,
  //                          fontSize: 16,
  //                           color: AppColors.grey,
  //                         ),
  //                       ),
                      
  //   squareIcon(Icons.description),    // document
   
  //                     ],
  //                   ),
  //                   SizedBox(height: 16),
  //                   Text(
  //                     finvuConsentRequestDetailInfo.consentPurposeInfo.text,
  //                     style: FontManager().getTextStyle(
  //                       context,
  //                      lWeight: FontWeight.w500,
  //                       fontSize: 16,
  //                       color: AppColors.accentColor,
  //                     ),
  //                   ),
  //                   SizedBox(height: 22),
  //                   Row(
  //                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         FinvuStrings().accountDetails,
  //                         style: FontManager().getTextStyle(
  //                           context,
  //                           lWeight: FontWeight.w400,
  //                          fontSize: 16,
  //                           color: AppColors.grey,
  //                         ),
  //                       ),
  //                        squareIcon(Icons.person),          // user
  
  //                     ],
  //                   ),
  //                   SizedBox(height: 16),
  //                   Text(
  //                     FinvuStrings().profileSummaryTransactions,
  //                     style: FontManager().getTextStyle(
  //                       context,
  //                       lWeight: FontWeight.w500,
  //                       fontSize: 16,
  //                       color: AppColors.accentColor,
  //                     ),
  //                   ),
  //                   SizedBox(height: 22),
  //                   Row(
  //                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         FinvuStrings().dataLife,
  //                         style: FontManager().getTextStyle(
  //                           context,
  //                           lWeight: FontWeight.w400,
  //                          fontSize: 16,
  //                           color: AppColors.grey,
  //                         ),
  //                       ),
  //                         squareIcon(Icons.access_time_filled),    // clock
    
  //                     ],
  //                   ),
  //                   SizedBox(height: 16),
  //                   Text(
  //                     finvuConsentRequestDetailInfo.consentDataLifePeriod.value
  //                             .toString() +
  //                         " " +
  //                         finvuConsentRequestDetailInfo.consentDataLifePeriod.unit
  //                             .toString(),
  //                     style: FontManager().getTextStyle(
  //                       context,
  //                       lWeight: FontWeight.w500,
  //                       fontSize: 16,
  //                       color: AppColors.accentColor,
  //                     ),
  //                   ),
  //                   SizedBox(height: 22),
  //                   Row(
  //                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         FinvuStrings().approvalExpiry,
  //                         style: FontManager().getTextStyle(
  //                           context,
  //                           lWeight: FontWeight.w400,
  //                           fontSize: 16,
  //                           color: AppColors.grey,
  //                         ),
  //                       ),
  //                       squareIcon(Icons.event_busy),     // calendar with X
    
  //                     ],
  //                   ),
  //                   SizedBox(height: 16),
  //                   Text(
  //                     formatDate(finvuConsentRequestDetailInfo
  //                         .consentDateTimeRange.to
  //                         .toString()),
  //                     style: FontManager().getTextStyle(
  //                       context,
  //                        lWeight: FontWeight.w500,
  //                       fontSize: 16,
  //                       color: AppColors.accentColor,
  //                     ),
  //                   ),
  //                   SizedBox(height: 22),
  //                   Row(
  //                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         FinvuStrings().accountTypes,
  //                         style: FontManager().getTextStyle(
  //                           context,
  //                           lWeight: FontWeight.w400,
  //                          fontSize: 16,
  //                           color: AppColors.grey,
  //                         ),
  //                       ),
  //                       squareIcon(Icons.android_sharp),
  //                     ],
  //                   ),
  //                   SizedBox(height: 16),
  //                   Wrap(
  //                       children: finvuConsentRequestDetailInfo.fiTypes!
  //                           .map((e) => Text(
  //                                 e + ",",
  //                                 style: FontManager().getTextStyle(
  //                                   context,
  //                                    lWeight: FontWeight.w500,
  //                       fontSize: 16,
  //                       color: AppColors.accentColor,
  //                                 ),
  //                               ))
  //                           .toList()),
  //                   SizedBox(height: 20),
  //                   // InkWell(
  //                   //     onTap: () {
  //                   //       Navigator.pop(context);
  //                   //     },
  //                   //     child: getButton(context, "Understand")),
  //                 ],
  //               ),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

Widget squareIcon(IconData icon) {
  return Container(
    width: 40,
    height: 40,
  
    decoration: BoxDecoration(
      color: const Color(0xFFF7F6F2), // light beige bg
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      icon,
      size: 22,
      color: const Color(0xFF4A4F8C), // dark bluish icon color
    ),
  );
}
  Widget accountsWithWidget(
  String title,
  Widget valueWidget,
  String icon,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AvatarProfileImageZero(url: icon, width: 40, height: 40),
        
    const SizedBox(width: 10),
            Text(
              title,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.primaryColor

              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
            padding: const EdgeInsets.only(left: 38),
            child: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              child: valueWidget),)
      ],
    ),
  );
}

  Widget accounts(String title, String value, String url) {
    return Container(
      // width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarProfileImageZero(url: url, width: 40, height: 40),
          //        Icon(
          //   icon,
          //   color: AppColors.primaryColor,
          //   size: 20,
          // ),
          const SizedBox(
            width: 10,
          ),
              Text(
                title,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              child: Text(
                value,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 16,
                  color: AppColors.accentColor,
                ),
                overflow: TextOverflow.clip,
              ),
            ),
          ),
          Padding(
               padding: const EdgeInsets.only(left:38),
            child: title == "Accounts Shared"
                ? accountLikedInfo()
                : SizedBox.shrink(),
          )
        ],
      ),
    );
  }

  Widget viewInfo() {
    return InkWell(
      onTap: () {
        // showModalBottomSheet(
        //     context: context,
        //     builder: (context) {
        //       return Container(
        //         child: accountInfo(),
        //       );
        //     });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 3, top: 5),
        child: Text(
          FinvuStrings().viewMore,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w400,
            fontSize: 16,
            color: Colorcodes.blue,
          ),
        ),
      ),
    );
  }

  Widget accountInfo() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p4),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.p8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  textStyle(FinvuStrings().linkedBankAccount, 15,
                      AppColors.primaryColor, FontWeight.bold),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close)),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fetchAccountData.map((e) {
                String url = bankImageAndid.containsKey(e.fipId)
                    ? bankImageAndid[e.fipId].toString()
                    : "".toString();
                //  var d=await finvuManager.fetchFIPDetails(e.fipId);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: 40,
                          height: 30,
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      textStyle(e.fipName),
                      const SizedBox(
                        width: 5,
                      ),
                      textStyle(e.accountType),
                      const SizedBox(
                        width: 5,
                      ),
                      textStyle(e.maskedAccountNumber),
                      Obx(() => addAccount.value
                          ? getcheckBox(e.accountReferenceNumber)
                          : getcheckBox(e.accountReferenceNumber))
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget getcheckBox(String fipId) {
    return Padding(
      padding: const EdgeInsets.only(left:AppSizes.p10),
      child: Container(
        width: 50,
        height: 50,
        child: Checkbox(
            value: seletedAccountIds.contains(fipId),
            onChanged: (value) {
              if (seletedAccountIds.contains(fipId)) {
                seletedAccountIds.remove(fipId);
              } else {
                seletedAccountIds.add(fipId);
              }
              addAccount.value = !addAccount.value;
            }),
      ),
    );
  }

  Widget textStyle(text,
      [double fontsize = 12,
      Color c = AppColors.bg1,
      FontWeight fontWeight = FontWeight.w500]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 7,
          ),
          Text(
            text.toString(),
            style: FontManager().getTextStyle(context,
                lWeight: fontWeight, fontSize: fontsize, color: c),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget pauseOrCancle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p20, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.grey),
          SizedBox(width: 10),
          Container(
            width: MediaQuery.of(context).size.width / 1.3,
            child: Text(
              FinvuStrings().pauseOrCancelSharing,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w400,
                fontSize: 15,
                color: AppColors.bg3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget givePermissionOrDecline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                approveConsentRequest();
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p14),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    FinvuStrings().givePermission,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.backgroundColor,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                showDialogBoxForDecline(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p20),
                decoration: BoxDecoration(
                  //color: AppColors.accentColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    FinvuStrings().decline,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.redColor,
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

  void approveConsentRequest() async {
    try {
      FinvuConsentRequestDetailInfo finvuConsentRequestDetailInfo =
          await finvuManager.getConsentRequestDetails(handleId.value);

      FinvuProcessConsentRequestResponse response =
          await finvuManager.approveConsentRequest(
              finvuConsentRequestDetailInfo, seletedAccountInfomations);

      snackBarCalled(context, SnackbarData().consentApproved);

      FetchTransactionFromFinvuApi(context);
    } catch (e) {
      skipOrLets.value = "Skip";
      snackBarCalledfail(context, SnackbarData().consentApproveError);
    }
  }

  Widget getcheckBox2(String fipId) {
    return Padding(
      padding: const EdgeInsets.only(left:AppSizes.p10),
      child: Container(
        width: 50,
        height: 50,
        child: Checkbox(
            value: seletedAccountIds.contains(fipId),
            onChanged: (value) {
              if (seletedAccountIds.contains(fipId)) {
                seletedAccountIds.remove(fipId);
              } else {
                seletedAccountIds.add(fipId);
              }
              addAccount.value = !addAccount.value;
            }),
      ),
    );
  }

  void showDialogBoxForDecline(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10)), // Optional: rounded corners
          child: Container(
            width: 300, // Set width
            height: 180, // Set height
            padding: EdgeInsets.all(AppSizes.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Prevent excessive height
              children: [
                textStyle(FinvuStrings().areYouSure, 20, AppColors.primaryColor,
                    FontWeight.bold),
                SizedBox(height: 10),
                textStyle(FinvuStrings().declineConfirmation, 15),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        side: BorderSide(color: AppColors.bg1), // Add border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Optional: Rounded corners
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: textStyle(FinvuStrings().no, 15),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.primaryColor), // Add border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Optional: Rounded corners
                        ),
                      ),
                      onPressed: () {
                        decline();
                      },
                      child: textStyle(FinvuStrings().yes, 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void decline() async {
    try {
      FinvuConsentRequestDetailInfo consentInfo =
          await finvuManager.getConsentRequestDetails(handleId.value);
      finvuManager.denyConsentRequest(consentInfo);
      logoutAndDisconnect();
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/ShareAccountLogin', (Route<dynamic> route) => false);
      Navigator.pushNamed(context, "/ShareAccountLogin");
      snackBarCalledfail(context, SnackbarData().consentDeclined);
    } catch (e) {
      snackBarCalledfail(context, SnackbarData().consentDisapproveError);
    }
  }
}

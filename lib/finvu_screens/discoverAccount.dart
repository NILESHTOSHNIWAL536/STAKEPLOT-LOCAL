// // import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// // import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
// // import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
// // import 'package:flutter_application_code_stakeplot/finvu_screens/integration.dart';
// // import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// // import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
// // import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
// // import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
// // import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// // import 'package:flutter_application_code_stakeplot/main.dart';
// // import 'package:get/get.dart';

// // import '../Constants/core/app_padding_sizes.dart';

// // class DiscoverAccount extends StatefulWidget {
// //    DiscoverAccount({Key? key}) : super(key: key);

// //   @override
// //   _DiscoverAccountState createState() => _DiscoverAccountState();
// // }

// // class _DiscoverAccountState extends State<DiscoverAccount> {
// //   TextEditingController search = TextEditingController();

// //   @override
// //   void initState() {
// //     super.initState();
// //     bankImageAndid.clear();
// //     getData();
// //     getFetch.value = false;
// //   }
// //   List<FinvuFIPInfo> getPopularBanksList() {
// //   if (fipDisOrginal.isEmpty) return [];

// //   // ✅ Take first 4 banks from backend list
// //   return fipDisOrginal.take(4).toList();
// // }

// //   @override
// //   void dispose() {
// //     search.dispose(); // Add this
// //     super.dispose();
// //   }

// //   void getData() async {
// //     fipDis = await finvuManager.fipsAllFIPOptions();
// //     fipDisOrginal.clear();
// //     fipDisOrginal.addAll(fipDis);

// //     fipDis.forEach((FinvuFIPInfo bankData){
// //       bankImageAndid[bankData.fipId]=bankData.productIconUri.toString();
// //     });

// //     getBanks.value = !getBanks.value;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppColors.newbg,
// //       bottomNavigationBar: SafeArea(child: BottomBar()),
// //       extendBody: true,
// //       appBar: getAppBar(context),
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
// //           child: SingleChildScrollView(
// //             child: Container(
// //               width: MediaQuery.of(context).size.width,
// //               height: MediaQuery.of(context).size.height/1.22,
// //               // color: Colorcodes.barGraphOrange,
// //               child: Column(
// //                 // mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 crossAxisAlignment: CrossAxisAlignment.center,
// //                 children: [
// //                   bankAccountAndSearchBar(),
// //                 InkWell(
// //                   onTap: () {
// //                     count.value=0;
// //                     count.refresh();
// //                     getBankAccount();
// //                   },
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(vertical: 0.0),
// //                     child: getButton(context, "Continue"),
// //                   ),
// //                 ),
// //               ]),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// // Widget getPopularBanks() {
// //   final popularBanks = getPopularBanksList();

// //   if (popularBanks.isEmpty) return const SizedBox.shrink();

// //   return Container(
// //     width: MediaQuery.of(context).size.width,
// //     margin: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p6),
// //     padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),

// //     child: Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [

// //         /// HEADER
// //         Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 4, vertical: AppSizes.p6),
// //           child: Text(
// //             "Popular Banks",
// //             style: FontManager().getTextStyle(
// //               context,
// //               lWeight: FontWeight.w600,
// //               fontSize: 18,
// //               color: AppColors.accentColor,
// //             ),
// //           ),
// //         ),

// //         /// BANK LIST
// //        GridView.builder(
// //   shrinkWrap: true,
// //   physics: const NeverScrollableScrollPhysics(),
// //   itemCount: popularBanks.length,
// //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //     crossAxisCount: 4, // 4 banks per row
// //     mainAxisSpacing: 8,
// //     crossAxisSpacing: 8,
// //     childAspectRatio: 0.8,
// //   ),
// //   itemBuilder: (context, index) {
// //     return bankGridItem(popularBanks[index]);
// //   },
// // )

// //       ],
// //     ),
// //   );
// // }

// // Widget bankGridItem(FinvuFIPInfo bankData) {
// //   return Obx(() {
// //     final bool isSelected =
// //         isSeletedBankAccout.contains(bankData.fipId);

// //     return InkWell(
// //       borderRadius: BorderRadius.circular(8),
// //       onTap: () {
// //         // toggle select / deselect
// //         addBackToList(!isSelected, bankData);
// //       },
// //       child: Container(

// //         padding: const EdgeInsets.all(AppSizes.p6),
// //         decoration: BoxDecoration(
// //           color: isSelected
// //               ? AppColors.primaryColor.withOpacity(0.08)
// //               : Colors.transparent,
// //           borderRadius: BorderRadius.circular(8),
// //           border: Border.all(
// //             color: isSelected
// //                 ? AppColors.primaryColor
// //                 : AppColors.border,
// //             width: isSelected ? 1.5 : 1,
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           mainAxisSize: MainAxisSize.min,
// //           children: [

// //             /// BANK LOGO
// //             SizedBox(
// //               width: 38,
// //               height: 38,
// //               child: Image.network(
// //                 (bankData.productIconUri != null &&
// //                         bankData.productIconUri.toString().isNotEmpty)
// //                     ? bankData.productIconUri.toString()
// //                     : bankImage,
// //                 fit: BoxFit.contain,
// //               ),
// //             ),

// //              SizedBox(height: AppSizes.h8),

// //             /// BANK NAME
// //             Text(
// //               bankData.productName.toString(),
// //               maxLines: 2,
// //               textAlign: TextAlign.center,
// //               overflow: TextOverflow.ellipsis,
// //               style: FontManager().getTextStyle(
// //                 context,
// //                 lWeight: FontWeight.w500,
// //                 fontSize: 12,
// //                 color: AppColors.bg1,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   });
// // }

// //   Widget bankAccountAndSearchBar(){
// //     return Column(
// //         children: [
// //                  Padding(
// //                   padding:const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //                   child: Align(
// //                     alignment: Alignment.topLeft,
// //                     child: Text(
// //                       FinvuStrings().pickAtLeastOne,
// //                       style: FontManager().getTextStyle(context,
// //                           lWeight: FontWeight.bold,
// //                           fontSize: 18,
// //                           color: AppColors.bg1),
// //                     ),
// //                   ),
// //                 ),
// //                  Padding(
// //                   padding:const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //                   child: Align(
// //                     alignment: Alignment.topLeft,
// //                     child: Row(
// //                       children: [
// //                         Icon(Icons.info_outline),
// //                         SizedBox(width: AppSizes.w10),
// //                         Text(
// //                           FinvuStrings().unableToSupport,
// //                           style: FontManager().getTextStyle(context,
// //                               lWeight: FontWeight.w400,
// //                               fontSize: 12,
// //                               color: AppColors.grey),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),

// //                 InputDate(FinvuStrings().searchForBanks, TextInputType.name, search),
// //                  Obx(() => getBanks.value ? getPopularBanks() : getPopularBanks()),
// //                 Obx(() => getBanks.value
// //                     ? getListOfFinvuBanks()
// //                     : getListOfFinvuBanks()),
// //         ],
// //     );
// //   }

// //   Widget getListOfFinvuBanks() {

// //     return Container(
// //       width: MediaQuery.of(context).size.width,
// //       height: MediaQuery.of(context).size.height / 2.5,
// //       margin: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p10),
// //       padding: EdgeInsets.symmetric(horizontal: 4, vertical: AppSizes.p16),
// //       decoration: BoxDecoration(
// //         // color:  AppColors.redColor,
// //         border: Border.all(color: AppColors.border)
// //       ),
// //       child: ListView.builder(
// //         itemCount: fipDis.length,
// //         itemBuilder: (context, index) {
// //           return getBackUi(fipDis[index]);
// //         },
// //       ),
// //     );
// //   }

// //   //modified code for checkbox
// //   void addBackToList(bool? boolVale, FinvuFIPInfo bankData) {
// //     if (boolVale == true) {
// //       // Add to the selected list
// //       if (!isSeletedBankAccout.contains(bankData.fipId)) {
// //         isSeletedBankAccout.add(bankData.fipId);
// //         listOfBankAccount.add(bankData);
// //       }
// //     } else
// //     {
// //       // Remove from the selected list
// //       isSeletedBankAccout.remove(bankData.fipId);
// //       listOfBankAccount.removeWhere((item) => item.fipId == bankData.fipId);
// //     }
// //     addBank.value = !addBank.value; // Trigger UI update
// //     addCheck.value = !addCheck.value; // Trigger UI update
// //   }

// // Widget getBackUi(FinvuFIPInfo bankData) {
// //   bankImageAndid[bankData.fipId] =
// //       bankData.productIconUri.toString();

// //   return Obx(() {
// //     final bool isSelected =
// //         isSeletedBankAccout.contains(bankData.fipId);

// //     return InkWell(
// //       onTap: () {
// //         // ✅ Toggle on full row tap
// //         addBackToList(!isSelected, bankData);
// //       },
// //       child: Container(
// //         width: MediaQuery.of(context).size.width,
// //         padding: const EdgeInsets.symmetric(vertical: AppSizes.p8, horizontal: AppSizes.p12),
// //         decoration: BoxDecoration(
// //           color:
// //                Colors.transparent,
// //           borderRadius: BorderRadius.circular(8),
// //         ),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [

// //             /// BANK ICON
// //             SizedBox(
// //               width: 50,
// //               height: 50,
// //               child: Image.network(
// //                 (bankData.productIconUri != null &&
// //                         bankData.productIconUri.toString().isNotEmpty)
// //                     ? bankData.productIconUri.toString()
// //                     : bankImage,
// //                 fit: BoxFit.contain,
// //               ),
// //             ),

// //             SizedBox(width: AppSizes.w12),

// //             /// BANK NAME
// //             Expanded(
// //               child: Text(
// //                 bankData.productName.toString(),
// //                 overflow: TextOverflow.ellipsis,
// //                 style: FontManager().getTextStyle(
// //                   context,
// //                   lWeight: FontWeight.w400,
// //                   fontSize: 15,
// //                   color: AppColors.bg1,
// //                 ),
// //               ),
// //             ),

// //             /// ✅ TICK (tap again to deselect)
// //             AnimatedSwitcher(
// //               duration: const Duration(milliseconds: 200),
// //               child: isSelected
// //                   ? Icon(
// //                       Icons.check,
// //                       key: ValueKey(bankData.fipId),
// //                       color: AppColors.primaryColor,
// //                       size: 22,
// //                     )
// //                   : const SizedBox(
// //                       key: ValueKey('empty'),
// //                       width: 22,
// //                     ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   });
// // }

// // //   //modified code for checkbox
// // //   Widget getBackUi(FinvuFIPInfo bankData) {
// // //      bankImageAndid[bankData.fipId]=bankData.productIconUri.toString();

// // //     return Container(
// // //       width: MediaQuery.of(context).size.width,
// // //       padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
// // //       child: Row(
// // //         mainAxisAlignment: MainAxisAlignment.start,
// // //         crossAxisAlignment: CrossAxisAlignment.center,
// // //         children: [

// // //           InkWell(
// // //             onTap: (){
// // //                addBackToList(!isSeletedBankAccout.contains(bankData.fipId), bankData);
// // //             },
// // //             child: Padding(
// // //               padding: const EdgeInsets.symmetric(horizontal: 10),
// // //               child: Container(
// // //                 width: 50,
// // //                 height: 50,
// // //                 child: Image.network(
// // //                  (bankData.productIconUri.toString().isNotEmpty && bankData.productIconUri !=null )?   bankData.productIconUri.toString():bankImage,
// // //                   fit: BoxFit.contain,
// // //                 ),
// // //               ),
// // //             ),
// // //           ),

// // //           Expanded(
// // //             child:   InkWell(
// // //             onTap: (){
// // //                addBackToList(!isSeletedBankAccout.contains(bankData.fipId), bankData);
// // //             },
// // //               child: Text(
// // //                 bankData.productName.toString(),
// // //                 style: FontManager().getTextStyle(context,
// // //                           lWeight: FontWeight.w400,
// // //                           fontSize: 15,
// // //                           color: AppColors.bg1,
// // //                           overflow: TextOverflow.ellipsis)
// // //               ),
// // //             ),
// // //           ),
// // // //getCheck(bankData),
// // //            Obx(() => addCheck.value?getCheck(bankData):getCheck(bankData)),

// // //         ],
// // //       ),
// // //     );
// // //   }

// //   Widget getCheck(bankData){
// //      return Checkbox(
// //                 value: isSeletedBankAccout.contains(bankData.fipId),
// //                 activeColor: AppColors.primaryColor,
// //                  shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(2), // Apply border radius
// //                 ),
// //                 onChanged: (bool? boolVale) {
// //                   // Toggle the checkbox selection
// //                   addBackToList(boolVale, bankData);
// //                 },
// //           );
// //   }

// //   void searchFinvuAccount() async {
// //     if (search.text.isEmpty) {
// //       fipDis.clear();
// //       fipDis.addAll(fipDisOrginal);
// //     } else {
// //       fipDis.clear();

// //       fipDisOrginal.forEach((fipAccount) {

// //         if (fipAccount.productName
// //             .toString()
// //             .toLowerCase()
// //             .contains(search.text.toLowerCase())) {
// //           fipDis.add(fipAccount);
// //         }
// //       });
// //     }
// //     getBanks.value = !getBanks.value;
// //   }

// //   Widget InputDate(lableText, keyBoard, Textcontroller) {
// //     return Padding(
// //       padding: const EdgeInsets.only(top:4,bottom: 10),
// //       child: Center(
// //         child: Container(
// //           // margin: EdgeInsets.symmetric(vertical: 5),
// //           // color:  Color.fromRGBO(246, 246, 246, 1),
// //           // height: 50,
// //           width: MediaQuery.of(context).size.width / 1.1,
// //           child: Center(
// //             child: TextFormField(
// //               keyboardType: keyBoard,
// //               controller: Textcontroller,
// //               onChanged: (value) {
// //                 Future.delayed(const Duration(milliseconds: 300), () {
// //                   searchFinvuAccount();
// //                 });
// //               },
// //               decoration: InputDecoration(
// //                 prefixIcon: Icon(Icons.search),
// //                 prefixIconColor: AppColors.primaryColor,
// //                 //prefixIconColor: Colorcodes.budgetDarkGreen,
// //                 filled: true,
// //                 contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: AppSizes.p14),
// //                 hintText: lableText,
// //                 hintStyle:  FontManager().getTextStyle(context,
// //                           lWeight: FontWeight.w400,
// //                           fontSize: 14,
// //                           color: AppColors.bg3),
// //                 enabledBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(8),
// //                   borderSide: BorderSide(color: AppColors.border
// //                       // color: Color.fromRGBO(249, 246, 238, 1)
// //                       )
// //                 ),
// //                 focusedBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(8),
// //                   borderSide: BorderSide(color: AppColors.border)
// //                 ),
// //                 fillColor: AppColors.newbg,
// //                 border: InputBorder.none,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   void getBankAccount() {
// //     if (listOfBankAccount.isEmpty) {
// //       snackBarCalledfail(context,SnackbarData().pickOneBank, Colorcodes.red);
// //       return;
// //     } else {

// //       storeMapOfImagesInBackend();
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => LinkingAccount(
// //             listOfBankAccount: listOfBankAccount,
// //           ),
// //         ),
// //       );
// //     }
// //   }
// // }

// import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
// import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
// import 'package:flutter_application_code_stakeplot/main.dart';
// import 'package:get/get.dart';

// import '../controllers/fipmetrics-controller.dart';
// import 'integration.dart';
// import 'shareAccountLogin.dart';

// class DiscoverAccount extends StatefulWidget {
//   const DiscoverAccount({Key? key}) : super(key: key);

//   @override
//   _DiscoverAccountState createState() => _DiscoverAccountState();
// }

// class _DiscoverAccountState extends State<DiscoverAccount> {
//   final TextEditingController search = TextEditingController();

//   // Lazy reference — null-safe if controller wasn't registered
//   FipMetricsController? get _metrics =>
//       Get.isRegistered<FipMetricsController>() ? FipMetricsController.to : null;

//   @override
//   void initState() {
//     super.initState();
//     bankImageAndid.clear();
//     getData();
//     getFetch.value = false;
//   }

//   @override
//   void dispose() {
//     search.dispose();
//     super.dispose();
//   }

//   void getData() async {
//     fipDis = await finvuManager.fipsAllFIPOptions();
//     fipDisOrginal
//       ..clear()
//       ..addAll(fipDis);

//     for (final bankData in fipDis) {
//       bankImageAndid[bankData.fipId] = bankData.productIconUri.toString();
//     }
//     getBanks.value = !getBanks.value;
//   }

//   // ── Health badge ────────────────────────────────────────────────────────────

//   Widget _healthBadge(String fipId) {
//     final status = _metrics?.healthFor(fipId) ?? FipHealthStatus.unknown;
//     final latency = _metrics?.avgLatencyFor(fipId) ?? 0;

//     final config = _badgeConfig(status);
//     if (status == FipHealthStatus.unknown) return const SizedBox.shrink();

//     return Tooltip(
//       message:'${config.label}',
//       preferBelow: false,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//         decoration: BoxDecoration(
//           color: config.bg,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: config.border, width: 0.8),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 6,
//               height: 6,
//               decoration: BoxDecoration(
//                 color: config.dot,
//                 shape: BoxShape.circle,
//               ),
//             ),
//             const SizedBox(width: 4),
//             Text(
//               `${config.label| •  avg ${latency.toStringAsFixed(0)} ms}`,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w500,
//                 color: config.text,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   _BadgeConfig _badgeConfig(FipHealthStatus status) {
//     switch (status) {
//       case FipHealthStatus.healthy:
//         return _BadgeConfig(
//           label: 'Live',
//           bg: const Color(0xFFE8F5E9),
//           border: const Color(0xFFA5D6A7),
//           dot: const Color(0xFF43A047),
//           text: const Color(0xFF2E7D32),
//         );
//       case FipHealthStatus.degraded:
//         return _BadgeConfig(
//           label: 'Slow',
//           bg: const Color(0xFFFFF8E1),
//           border: const Color(0xFFFFCC80),
//           dot: const Color(0xFFFB8C00),
//           text: const Color(0xFFE65100),
//         );
//       case FipHealthStatus.down:
//         return _BadgeConfig(
//           label: 'Down',
//           bg: const Color(0xFFFFEBEE),
//           border: const Color(0xFFEF9A9A),
//           dot: const Color(0xFFE53935),
//           text: const Color(0xFFC62828),
//         );
//       case FipHealthStatus.unknown:
//         return _BadgeConfig(
//           label: '',
//           bg: Colors.transparent,
//           border: Colors.transparent,
//           dot: Colors.transparent,
//           text: Colors.transparent,
//         );
//     }
//   }

//   // ── Build ───────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       bottomNavigationBar: const SafeArea(child: BottomBar()),
//       extendBody: true,
//       appBar: getAppBar(context),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
//           child: SingleChildScrollView(
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height / 1.22,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   _bankAccountAndSearchBar(),
//                   InkWell(
//                     onTap: () {
//                       count.value = 0;
//                       count.refresh();
//                       _getBankAccount();
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 0),
//                       child: getButton(context, "Continue"),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _bankAccountAndSearchBar() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: Text(
//               FinvuStrings().pickAtLeastOne,
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: AppColors.bg1,
//               ),
//             ),
//           ),
//         ),
//         _searchBar(),
//         Obx(() => getBanks.value ? _bankList() : _bankList()),
//       ],
//     );
//   }

//   Widget _bankList() {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height / 1.59,
//       child: ListView.builder(
//         itemCount: fipDis.length,
//         itemBuilder: (_, index) => _bankRow(fipDis[index]),
//       ),
//     );
//   }

//   // ── Bank row ────────────────────────────────────────────────────────────────

//   Widget _bankRow(FinvuFIPInfo bankData) {
//     bankImageAndid[bankData.fipId] = bankData.productIconUri.toString();

//     return Container(
//       width: MediaQuery.of(context).size.width,
//       padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 7),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Logo
//           InkWell(
//             onTap: () => _toggle(
//                 !isSeletedBankAccout.contains(bankData.fipId), bankData),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: SizedBox(
//                 width: 50,
//                 height: 50,
//                 child: Image.network(
//                   (bankData.productIconUri?.toString().isNotEmpty == true)
//                       ? bankData.productIconUri.toString()
//                       : bankImage,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ),

//           // Name
//           Expanded(
//             child: InkWell(
//               onTap: () => _toggle(
//                   !isSeletedBankAccout.contains(bankData.fipId), bankData),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     bankData.productName.toString(),
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 15,
//                       color: AppColors.bg1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   const SizedBox(height: 3),
//                   // ← health badge lives here, under the bank name
//                   _healthBadge(bankData.fipId),
//                 ],
//               ),
//             ),
//           ),

//           // Checkbox
//           Obx(() => addCheck.value ? _checkbox(bankData) : _checkbox(bankData)),
//         ],
//       ),
//     );
//   }

//   Widget _checkbox(FinvuFIPInfo bankData) {
//     return Checkbox(
//       value: isSeletedBankAccout.contains(bankData.fipId),
//       activeColor: AppColors.primaryColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
//       onChanged: (val) => _toggle(val, bankData),
//     );
//   }

//   // ── Selection logic ─────────────────────────────────────────────────────────

//   void _toggle(bool? value, FinvuFIPInfo bankData) {
//     if (value == true) {
//       if (!isSeletedBankAccout.contains(bankData.fipId)) {
//         isSeletedBankAccout.add(bankData.fipId);
//         listOfBankAccount.add(bankData);
//       }
//     } else {
//       isSeletedBankAccout.remove(bankData.fipId);
//       listOfBankAccount.removeWhere((item) => item.fipId == bankData.fipId);
//     }
//     addBank.value = !addBank.value;
//     addCheck.value = !addCheck.value;
//   }

//   // ── Search ──────────────────────────────────────────────────────────────────

//   void _search() {
//     if (search.text.isEmpty) {
//       fipDis
//         ..clear()
//         ..addAll(fipDisOrginal);
//     } else {
//       final query = search.text.toLowerCase();
//       fipDis
//         ..clear()
//         ..addAll(fipDisOrginal.where(
//           (f) => f.productName.toString().toLowerCase().contains(query),
//         ));
//     }
//     getBanks.value = !getBanks.value;
//   }

//   Widget _searchBar() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 4, bottom: 10),
//       child: Center(
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width / 1.1,
//           child: TextFormField(
//             keyboardType: TextInputType.name,
//             controller: search,
//             onChanged: (_) =>
//                 Future.delayed(const Duration(milliseconds: 300), _search),
//             decoration: InputDecoration(
//               prefixIcon: const Icon(Icons.search),
//               prefixIconColor: AppColors.primaryColor,
//               filled: true,
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
//               hintText: FinvuStrings().searchForBanks,
//               hintStyle: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.w400,
//                 fontSize: 14,
//                 color: AppColors.bg3,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(24),
//                 borderSide: BorderSide(color: AppColors.border),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(24),
//                 borderSide: BorderSide(color: AppColors.border),
//               ),
//               fillColor: AppColors.button,
//               border: InputBorder.none,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Continue ────────────────────────────────────────────────────────────────

//   void _getBankAccount() {
//     if (listOfBankAccount.isEmpty) {
//       snackBarCalledfail(context, SnackbarData().pickOneBank, Colorcodes.red);
//       return;
//     }
//     storeMapOfImagesInBackend();
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => LinkingAccount(listOfBankAccount: listOfBankAccount),
//       ),
//     );
//   }
// }

// // ── Internal helper ──────────────────────────────────────────────────────────

// class _BadgeConfig {
//   final String label;
//   final Color bg, border, dot, text;
//   const _BadgeConfig({
//     required this.label,
//     required this.bg,
//     required this.border,
//     required this.dot,
//     required this.text,
//   });
// }

import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';

import '../controllers/fipmetrics-controller.dart';
import 'integration.dart';
import 'shareAccountLogin.dart';

// ── Filter options ─────────────────────────────────────────────────────────

enum _StatusFilter { all, live, slow, down }

extension _StatusFilterLabel on _StatusFilter {
  String get label {
    switch (this) {
      case _StatusFilter.all:
        return 'All';
      case _StatusFilter.live:
        return 'Live';
      case _StatusFilter.slow:
        return 'Slow';
      case _StatusFilter.down:
        return 'Down';
    }
  }

  Color? get dotColor {
    switch (this) {
      case _StatusFilter.all:
        return null;
      case _StatusFilter.live:
        return const Color(0xFF43A047);
      case _StatusFilter.slow:
        return const Color(0xFFFB8C00);
      case _StatusFilter.down:
        return const Color(0xFFE53935);
    }
  }

  bool matchesStatus(FipHealthStatus status) {
    switch (this) {
      case _StatusFilter.all:
        return true;
      case _StatusFilter.live:
        return status == FipHealthStatus.healthy;
      case _StatusFilter.slow:
        return status == FipHealthStatus.degraded;
      case _StatusFilter.down:
        return status == FipHealthStatus.down;
    }
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────

class DiscoverAccount extends StatefulWidget {
  const DiscoverAccount({Key? key}) : super(key: key);

  @override
  _DiscoverAccountState createState() => _DiscoverAccountState();
}

class _DiscoverAccountState extends State<DiscoverAccount> {
  final TextEditingController _search = TextEditingController();
  final Rx<_StatusFilter> _activeFilter = _StatusFilter.all.obs;

  FipMetricsController? get _metrics =>
      Get.isRegistered<FipMetricsController>() ? FipMetricsController.to : null;

  // Derived list after search + status filter applied
  List<FinvuFIPInfo> get _filteredList {
    final query = _search.text.toLowerCase();
    return fipDis.where((b) {
      final matchQ = query.isEmpty ||
          b.productName.toString().toLowerCase().contains(query) ||
          b.fipId.toLowerCase().contains(query);
      final status = _metrics?.healthFor(b.fipId) ?? FipHealthStatus.unknown;
      final matchS = _activeFilter.value.matchesStatus(status);
      return matchQ && matchS;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    bankImageAndid.clear();
    _loadBanks();
    getFetch.value = false;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _loadBanks() async {
    fipDis = await finvuManager.fipsAllFIPOptions();
    fipDisOrginal
      ..clear()
      ..addAll(fipDis);
    for (final b in fipDis) {
      bankImageAndid[b.fipId] = b.productIconUri.toString();
    }
    getBanks.value = !getBanks.value;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: getAppBar(context),
      extendBody: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Heading ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(
                FinvuStrings().pickAtLeastOne,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.bg1,
                ),
              ),
            ),

            // ── Search bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(
                controller: _search,
                onChanged: (_) {
                  Future.delayed(const Duration(milliseconds: 250), () {
                    getBanks.value = !getBanks.value;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // ── Filter pills ──────────────────────────────────────────────
            Obx(() => _FilterPills(
                  active: _activeFilter.value,
                  onTap: (f) => _activeFilter.value = f,
                )),

            const SizedBox(height: 8),

            // ── Bank list ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                // Touch both observables so list re-renders on search OR getBanks toggle
                getBanks.value;
                addCheck.value;
                final list = _filteredList;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'No banks found',
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 14,
                        color: AppColors.bg3,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _BankRow(
                    bankData: list[i],
                    isSelected: isSeletedBankAccout.contains(list[i].fipId),
                    metrics: _metrics,
                    onTap: () => _toggle(
                      !isSeletedBankAccout.contains(list[i].fipId),
                      list[i],
                    ),
                    onCheckChanged: (val) => _toggle(val, list[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),

      // ── Bottom bar with selection count + Continue ─────────────────────
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected count label
            Obx(() {
              addBank.value;
              final n = isSeletedBankAccout.length;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: n > 0
                    ? Padding(
                        key: ValueKey(n),
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          '$n bank${n > 1 ? 's' : ''} selected',
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 12,
                            color: AppColors.bg3,
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey(0), height: 8),
              );
            }),

            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    count.value = 0;
                    count.refresh();
                    _onContinue();
                  },
                  child: getButton(context, 'Continue'),
                ),
              ),
            ),

            const BottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Selection ──────────────────────────────────────────────────────────────

  void _toggle(bool? value, FinvuFIPInfo bankData) {
    if (value == true) {
      if (!isSeletedBankAccout.contains(bankData.fipId)) {
        isSeletedBankAccout.add(bankData.fipId);
        listOfBankAccount.add(bankData);
      }
    } else {
      isSeletedBankAccout.remove(bankData.fipId);
      listOfBankAccount.removeWhere((item) => item.fipId == bankData.fipId);
    }
    addBank.value = !addBank.value;
    addCheck.value = !addCheck.value;
  }

  void _onContinue() {
    if (listOfBankAccount.isEmpty) {
      snackBarCalledfail(context, SnackbarData().pickOneBank, Colorcodes.red);
      return;
    }
    storeMapOfImagesInBackend();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LinkingAccount(listOfBankAccount: listOfBankAccount),
      ),
    );
  }
}

// ── Search bar widget ───────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.name,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.bg1,
              ),
              decoration: InputDecoration(
                hintText: FinvuStrings().searchForBanks,
                hintStyle: TextStyle(fontSize: 14, color: AppColors.bg3),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

// ── Filter pills ─────────────────────────────────────────────────────────────

class _FilterPills extends StatelessWidget {
  final _StatusFilter active;
  final ValueChanged<_StatusFilter> onTap;
  const _FilterPills({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _StatusFilter.values.map((f) {
          final isActive = f == active;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryColor : AppColors.button,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primaryColor : AppColors.border,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f.dotColor != null) ...[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white70 : f.dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      f.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : AppColors.bg2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Bank row card ────────────────────────────────────────────────────────────

class _BankRow extends StatelessWidget {
  final FinvuFIPInfo bankData;
  final bool isSelected;
  final FipMetricsController? metrics;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckChanged;

  const _BankRow({
    required this.bankData,
    required this.isSelected,
    required this.metrics,
    required this.onTap,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        metrics?.healthFor(bankData.fipId) ?? FipHealthStatus.unknown;
    final latency = metrics?.avgLatencyForEvent(bankData.fipId) ?? 0;
    final cfg = _BadgeConfig.from(status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.4)
                : const Color(0xFFE5E5EA),
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          children: [
            // ── Logo / Initials ─────────────────────────────────────────
            _Logo(bankData: bankData),

            const SizedBox(width: 12),

            // ── Name + badge + latency ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankData.productName.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  if (status != FipHealthStatus.unknown) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cfg.bg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cfg.border, width: 0.7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: cfg.dot,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                cfg.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: cfg.text,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Latency (only when alive/slow)
                        if (latency > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${latency.toStringAsFixed(0)} ms avg',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Custom checkbox ─────────────────────────────────────────
            _CheckBox(
              value: isSelected,
              onChanged: onCheckChanged,
              activeColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logo with image + initials fallback ──────────────────────────────────────

class _Logo extends StatelessWidget {
  final FinvuFIPInfo bankData;
  const _Logo({required this.bankData});

  // Generate a consistent color pair from the fipId string
  static const _pairs = [
    [Color(0xFFE8F0FE), Color(0xFF1A56C4)],
    [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    [Color(0xFFFCE4EC), Color(0xFF880E4F)],
    [Color(0xFFFFF3E0), Color(0xFFE65100)],
    [Color(0xFFEDE7F6), Color(0xFF4527A0)],
    [Color(0xFFE0F2F1), Color(0xFF00695C)],
    [Color(0xFFFCE8E6), Color(0xFFC5221F)],
  ];

  List<Color> _colorPair() {
    final hash = bankData.fipId.codeUnits.fold(0, (a, b) => a + b);
    return _pairs[hash % _pairs.length];
  }

  String _initials() {
    final name = bankData.productName?.toString() ?? bankData.fipId;
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final uri = bankData.productIconUri?.toString() ?? '';
    final colors = _colorPair();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 46,
        height: 46,
        child: uri.isNotEmpty
            ? Image.network(
                uri,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _fallback(colors),
              )
            : _fallback(colors),
      ),
    );
  }

  Widget _fallback(List<Color> colors) {
    return Container(
      color: colors[0],
      alignment: Alignment.center,
      child: Text(
        _initials(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors[1],
        ),
      ),
    );
  }
}

// ── Custom checkbox ──────────────────────────────────────────────────────────

class _CheckBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color activeColor;
  const _CheckBox(
      {required this.value,
      required this.onChanged,
      required this.activeColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value ? activeColor : const Color(0xFFD1D1D6),
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
            : null,
      ),
    );
  }
}

// ── Badge config ─────────────────────────────────────────────────────────────

class _BadgeConfig {
  final String label;
  final Color bg, border, dot, text;

  const _BadgeConfig({
    required this.label,
    required this.bg,
    required this.border,
    required this.dot,
    required this.text,
  });

  factory _BadgeConfig.from(FipHealthStatus status) {
    switch (status) {
      case FipHealthStatus.healthy:
        return const _BadgeConfig(
          label: 'Live',
          bg: Color(0xFFE8F5E9),
          border: Color(0xFFA5D6A7),
          dot: Color(0xFF43A047),
          text: Color(0xFF2E7D32),
        );
      case FipHealthStatus.degraded:
        return const _BadgeConfig(
          label: 'Slow',
          bg: Color(0xFFFFF8E1),
          border: Color(0xFFFFCC80),
          dot: Color(0xFFFB8C00),
          text: Color(0xFFE65100),
        );
      case FipHealthStatus.down:
        return const _BadgeConfig(
          label: 'Down',
          bg: Color(0xFFFFEBEE),
          border: Color(0xFFEF9A9A),
          dot: Color(0xFFE53935),
          text: Color(0xFFC62828),
        );
      case FipHealthStatus.unknown:
        return const _BadgeConfig(
          label: 'Unknown',
          bg: Color(0xFFF5F5F5),
          border: Color(0xFFE0E0E0),
          dot: Color(0xFFBDBDBD),
          text: Color(0xFF9E9E9E),
        );
    }
  }
}

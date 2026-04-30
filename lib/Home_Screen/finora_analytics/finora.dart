// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/controllers/finora_controller.dart';
// import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
// import 'package:get/get.dart';
// import '../../Constants/core/app_padding_sizes.dart';
// import '../../components/shared_utils.dart';
// import '../../controllers/controllerManagement.dart';

// final RxString selectedPeriod = 'Month'.obs;
// class SwipeableCardsScreen extends StatelessWidget {
//   const SwipeableCardsScreen({super.key});
 
//   @override
//   Widget build(BuildContext context) {
    
//     final screenSize = MediaQuery.of(context).size;
//     final padding = screenSize.width * 0.04;

//     return Container(
//       decoration: BoxDecoration(
//         // color: AppColors.redColor,
//         borderRadius: BorderRadius.circular(padding),
        
//       ),
//       padding: EdgeInsets.symmetric(
//         horizontal: padding / 2,
//         vertical: padding * 0.2,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// TITLE
//           Row(
//             children: [
//               AvatarProfileImageZero(url: HomePageIcons.finoraIcon, width: 30, height: 40),
//               SizedBox(width: AppSizes.w10),
//               Text( HomepageStringsDart().finora,
//               style: FontManager().getTextStyle(context, color: AppColors.primaryColor, letterSpacing: 2.2, fontSize: 16, lWeight: FontWeight.w500),
//               )
             
//             ],
//           ),

//        const   SizedBox(height: AppSizes.h16),

          
//           SizedBox(
//             height: screenSize.height * 0.14,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               child: Row(
//                 children: [
//                   _buildCardWrapper(
//                     context,
//                     screenSize,
//                     TotalSpendingCard(),
//                   ),
//                   _buildCardWrapper(
//                     context,
//                     screenSize,
//                     OverspentCategoriesCard(),
//                   ),
//                   _buildCardWrapper(
//                     context,
//                     screenSize,
//                     FrequentTransactionCard(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//  Widget _buildCardWrapper(
//   BuildContext context,
//   Size screenSize,
//   Widget card,
// ) {
//   return Padding(
//     padding: const EdgeInsets.only(right:AppSizes.p12), 
//     child: Container(
//       width: screenSize.width * 0.8, // 👈 KEY CHANGE (peek effect)
//       height: screenSize.height * 0.14,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(screenSize.width * 0.03),
//         border: Border.all(
//           color: AppColors.border,
//           width: 1,
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(screenSize.width * 0.03),
//         child: card,
//       ),
//     ),
//   );
// }

// }

// class TotalSpendingCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     // final padding = screenSize.width * 0.03;

//     return Obx(
//       () => Container(
//         height: MediaQuery.of(context).size.height / 4,
//         decoration: BoxDecoration(
//           color: AppColors.backgroundColor,
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p4),
//         child: Center(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Row(
//                 children: [
//                  Container(
//                    padding: EdgeInsets.all(AppSizes.p2),
//                     decoration: BoxDecoration(
                      
//                        color: const Color.fromRGBO(75, 77, 115, 0.04),
//     borderRadius: BorderRadius.circular(13),
//                     ),
//                   child: Icon(Icons.sunny, color: AppColors.primaryColor,size: 24,)),
//                  SizedBox(width: AppSizes.w8),
//                   Text(
//                     'Monthly Summary',
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 16,
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: AppSizes.h20,
//               ),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Total Spending',
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w400,
//                           fontSize: 14,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                       SizedBox(
//                         height: AppSizes.h8,
//                       ),
//                       Container(
//                         width: MediaQuery.sizeOf(context).width / 2.6,
//                         child: Text(
//                           '₹${formatMoneyIndian(totalDebitThisMonth.value.toStringAsFixed(0))}',
//                           style: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.w500,
//                             fontSize:20,
                               
//                             color: AppColors.primaryColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Average/Day',
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w400,
//                           fontSize: 14,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                       SizedBox(
//                         height: AppSizes.h8,
//                       ),
//                       Container(
//                         width: MediaQuery.sizeOf(context).width / 2.9,
//                         child: Text(
//                           '₹${formatMoneyIndian(((totalDebitThisMonth.value / (DateTime.now().day == 0 ? 1 : DateTime.now().day)).toStringAsFixed(0)))}',
//                           style: FontManager().getTextStyle(context,
//                               lWeight: FontWeight.w500,
//                               fontSize:20,
                                 
//                               color: AppColors.primaryColor,
//                               overflow: TextOverflow.ellipsis),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class OverspentCategoriesCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final padding = screenSize.width * 0.03;

//     return Obx(
//       () => Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundColor,
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p4),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Overspent Categories',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.bold,
//                         fontSize: screenSize.width * 0.04,
//                         color: AppColors.primaryColor,
//                       ),
//                     ),
//                     SizedBox(height: AppSizes.h4),
//                     Text(
//                       '(${selectedPeriod.value}ly)',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w500,
//                         fontSize: screenSize.width * 0.02,
//                         color: AppColors.bg3,
//                       ),
//                     ),
//                   ],
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     selectedPeriod.value =
//                         selectedPeriod.value == 'Week' ? 'Month' : 'Week';
//                   },
//                   child: Icon(
//                     Icons.swap_horiz,
//                     color: AppColors.primaryColor,
//                     size: screenSize.width * 0.06,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: AppSizes.h5),
//             _buildCategoryList(screenSize, padding, context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryList(
//       Size screenSize, double padding, BuildContext context) {
//     // Check if lists are null or empty
//     final isMonthPeriod = selectedPeriod.value == 'Month';
//     final categoryList =
//         isMonthPeriod ? moreDrasticChange : moreDrasticChangeWeek;

//     if (categoryList == null || categoryList.isEmpty) {
//       return Center(
//         child: Text(
//           'No Data',
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.w500,
//             fontSize: screenSize.width * 0.035,
//             color: AppColors.primaryColor.withOpacity(0.8),
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: categoryList.take(2).map((category) {
//         // Null checks for category map entries
//         final categoryName = category != null && category['category'] != null
//             ? category['category'].toString().capitalize ?? 'Unknown'
//             : 'Unknown';
//         final debitDiff = category != null && category['debit_diff'] != null
//             ? formatMoneyIndian(category['debit_diff'].toStringAsFixed(2))
//             : '0.00';

//         return Padding(
//           padding: EdgeInsets.only(bottom: padding * 0.4),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 categoryName,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.w600,
//                   fontSize: screenSize.width * 0.035,
//                   color: AppColors.accentColor,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               Text(
//                 '₹$debitDiff',
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.w500,
//                   fontSize: screenSize.width * 0.033,
//                   color: AppColors.accentColor,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// class FrequentTransactionCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final padding = screenSize.width * 0.03;

//     return Obx(() {
//       return Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundColor,
//         ),
//         padding: EdgeInsets.all(padding),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                   Container(
//                     padding: EdgeInsets.all(AppSizes.p2),
//                     decoration: BoxDecoration(
                      
//                        color: const Color.fromRGBO(75, 77, 115, 0.04),
//     borderRadius: BorderRadius.circular(13),
//                     ),
//                     child: Icon(Icons.graphic_eq, color: AppColors.primaryColor,size: 24,)),
//                  SizedBox(width: AppSizes.w8),
//                   Text(
//                     'Most Frequent Payment',
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 16,
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
              
//               ],
//             ),
//             frequentPayments.isEmpty
//                 ? Text(
//                     'No Data',
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w600,
//                       fontSize: screenSize.width * 0.045,
//                       color: AppColors.accentColor,
//                     ),
//                   )
//                 :
//                  Text(
//                     frequentPayments[0]['name'].toString(),
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w600,
//                       fontSize: screenSize.width * 0.04,
//                       color: AppColors.accentColor,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//             frequentPayments.isEmpty
//                 ? SizedBox.shrink()
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '${frequentPayments[0]['count']} Transactions',
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w400,
//                           fontSize: screenSize.width * 0.035,
//                           color: AppColors.bg3,
//                         ),
//                       ),
//                       Text(
//                         '₹${formatMoneyIndian(frequentPayments[0]['totalAmount'].toStringAsFixed(2))}',
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w500,
//                           fontSize: screenSize.width * 0.05,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//           ],
//         ),
//       );
//     });
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/controllers/finora_controller.dart';
// import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
// import 'package:get/get.dart';
// import '../../Constants/core/app_padding_sizes.dart';
// import '../../components/shared_utils.dart';
// import '../../controllers/controllerManagement.dart';

// final RxString selectedPeriod = 'Month'.obs;
// class SwipeableCardsScreen extends StatelessWidget {
//   const SwipeableCardsScreen({super.key});
 
//   @override
//   Widget build(BuildContext context) {
    
//     final screenSize = MediaQuery.of(context).size;
//     final padding = screenSize.width * 0.04;

//     return Container(
//       decoration: BoxDecoration(
//         // color: AppColors.redColor,
//         borderRadius: BorderRadius.circular(padding),
        
//       ),
//       padding: EdgeInsets.symmetric(
//         horizontal: padding / 2,
//         vertical: padding * 0.2,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// TITLE
//           Row(
//             children: [
//               AvatarProfileImageZero(url: HomePageIcons.finoraIcon, width: 30, height: 40),
//               SizedBox(width: AppSizes.w10),
//               Text( HomepageStringsDart().finora,
//               style: FontManager().getTextStyle(context, color: AppColors.primaryColor, letterSpacing: 2.2, fontSize: 16, lWeight: FontWeight.w500),
//               )
             
//             ],
//           ),

//        const   SizedBox(height: AppSizes.h16),

          
//           SizedBox(
//             height: screenSize.height * 0.14,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               child: Row(
//                 children: [
//                   _buildCardWrapper(
//                     context,
//                     screenSize,
//                     TotalSpendingCard(),
//                   ),
//                   _buildCardWrapper(
//                     context,
//                     screenSize,
//                     OverspentCategoriesCard(),
//                   ),
//                   _buildCardWrapper(
//                     context,
//                     screenSize,
//                     FrequentTransactionCard(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//  Widget _buildCardWrapper(
//   BuildContext context,
//   Size screenSize,
//   Widget card,
// ) {
//   return Padding(
//     padding: const EdgeInsets.only(right:AppSizes.p12), 
//     child: Container(
//       width: screenSize.width * 0.8, // 👈 KEY CHANGE (peek effect)
//       height: screenSize.height * 0.14,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(screenSize.width * 0.03),
//         border: Border.all(
//           color: AppColors.border,
//           width: 1,
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(screenSize.width * 0.03),
//         child: card,
//       ),
//     ),
//   );
// }

// }

// class TotalSpendingCard extends StatelessWidget {
//   // FinoraController finoraController = ControllerManagement.finoraController;
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     // final padding = screenSize.width * 0.03;

//     return Obx(
//       () => Container(
//         height: MediaQuery.of(context).size.height / 4,
//         decoration: BoxDecoration(
//           color: AppColors.backgroundColor,
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p4),
//         child: Center(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Row(
//                 children: [
//                  Container(
//                    padding: EdgeInsets.all(AppSizes.p2),
//                     decoration: BoxDecoration(
                      
//                        color: const Color.fromRGBO(75, 77, 115, 0.04),
//     borderRadius: BorderRadius.circular(13),
//                     ),
//                   child: Icon(Icons.sunny, color: AppColors.primaryColor,size: 24,)),
//                  SizedBox(width: AppSizes.w8),
//                   Text(
//                     'Monthly Summary',
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 16,
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: AppSizes.h20,
//               ),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Total Spending',
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w400,
//                           fontSize: 14,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                       SizedBox(
//                         height: AppSizes.h8,
//                       ),
//                       Container(
//                         width: MediaQuery.sizeOf(context).width / 2.6,
//                         child: Text(
//                           '₹${formatMoneyIndian( totalDebitThisMonth.value.toStringAsFixed(0))}',
//                           style: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.w500,
//                             fontSize:20,
                               
//                             color: AppColors.primaryColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Average/Day',
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w400,
//                           fontSize: 14,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                       SizedBox(
//                         height: AppSizes.h8,
//                       ),
//                       Container(
//                         width: MediaQuery.sizeOf(context).width / 2.9,
//                         child: Text(
//                           '₹${formatMoneyIndian((( totalDebitThisMonth.value / (DateTime.now().day == 0 ? 1 : DateTime.now().day)).toStringAsFixed(0)))}',
//                           style: FontManager().getTextStyle(context,
//                               lWeight: FontWeight.w500,
//                               fontSize:20,
                                 
//                               color: AppColors.primaryColor,
//                               overflow: TextOverflow.ellipsis),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class OverspentCategoriesCard extends StatelessWidget {
//   // FinoraController finoraController = ControllerManagement.finoraController;
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final padding = screenSize.width * 0.03;

//     return Obx(
//       () => Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundColor,
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p4),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Overspent Categories',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.bold,
//                         fontSize: screenSize.width * 0.04,
//                         color: AppColors.primaryColor,
//                       ),
//                     ),
//                     SizedBox(height: AppSizes.h4),
//                     Text(
//                       '(${ selectedPeriod.value}ly)',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w500,
//                         fontSize: screenSize.width * 0.02,
//                         color: AppColors.bg3,
//                       ),
//                     ),
//                   ],
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                      selectedPeriod.value =
//                          selectedPeriod.value == 'Week' ? 'Month' : 'Week';
//                   },
//                   child: Icon(
//                     Icons.swap_horiz,
//                     color: AppColors.primaryColor,
//                     size: screenSize.width * 0.06,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: AppSizes.h5),
//             _buildCategoryList(screenSize, padding, context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryList(
//       Size screenSize, double padding, BuildContext context) {
//     // Check if lists are null or empty
//     final isMonthPeriod =  selectedPeriod.value == 'Month';
//     final categoryList =
//         isMonthPeriod ?  moreDrasticChange :  moreDrasticChangeWeek;

//     if (categoryList == null || categoryList.isEmpty) {
//       return Center(
//         child: Text(
//           'No Data',
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.w500,
//             fontSize: screenSize.width * 0.035,
//             color: AppColors.primaryColor.withOpacity(0.8),
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: categoryList.take(2).map((category) {
//         // Null checks for category map entries
//         final categoryName = category != null && category['category'] != null
//             ? category['category'].toString().capitalize ?? 'Unknown'
//             : 'Unknown';
//         final debitDiff = category != null && category['debit_diff'] != null
//             ? formatMoneyIndian(category['debit_diff'].toStringAsFixed(2))
//             : '0.00';

//         return Padding(
//           padding: EdgeInsets.only(bottom: padding * 0.4),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 categoryName,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.w600,
//                   fontSize: screenSize.width * 0.035,
//                   color: AppColors.accentColor,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               Text(
//                 '₹$debitDiff',
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.w500,
//                   fontSize: screenSize.width * 0.033,
//                   color: AppColors.accentColor,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// class FrequentTransactionCard extends StatelessWidget {
//   // FinoraController finoraController = ControllerManagement.finoraController;
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final padding = screenSize.width * 0.03;

//     return Obx(() {
//       return Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundColor,
//         ),
//         padding: EdgeInsets.all(padding),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                   Container(
//                     padding: EdgeInsets.all(AppSizes.p2),
//                     decoration: BoxDecoration(
                      
//                        color: const Color.fromRGBO(75, 77, 115, 0.04),
//     borderRadius: BorderRadius.circular(13),
//                     ),
//                     child: Icon(Icons.graphic_eq, color: AppColors.primaryColor,size: 24,)),
//                  SizedBox(width: AppSizes.w8),
//                   Text(
//                     'Most Frequent Payment',
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 16,
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
              
//               ],
//             ),
//             frequentPayments.isEmpty
//                 ? Text(
//                     'No Data',
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w600,
//                       fontSize: screenSize.width * 0.045,
//                       color: AppColors.accentColor,
//                     ),
//                   )
//                 :
//                  Text(
//                      frequentPayments[0]['name'].toString(),
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w600,
//                       fontSize: screenSize.width * 0.04,
//                       color: AppColors.accentColor,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//              frequentPayments.isEmpty
//                 ? SizedBox.shrink()
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '${ frequentPayments[0]['count']} Transactions',
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w400,
//                           fontSize: screenSize.width * 0.035,
//                           color: AppColors.bg3,
//                         ),
//                       ),
//                       Text(
//                         '₹${formatMoneyIndian( frequentPayments[0]['totalAmount'].toStringAsFixed(2))}',
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w500,
//                           fontSize: screenSize.width * 0.05,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//           ],
//         ),
//       );
//     });
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/finora_controller.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:get/get.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../components/shared_utils.dart';
import '../../controllers/controllerManagement.dart';
import '../../Constants/theme_helper.dart';

final RxString selectedPeriod = 'Month'.obs;
class FinoraInsightsSection extends StatelessWidget {

   FinoraInsightsSection({super.key});
   final controller = Get.find<FinoraController>();
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;

    return Container(
      decoration: BoxDecoration(
        // color: AppColors.redColor,
        borderRadius: BorderRadius.circular(padding),

      ),
      padding: EdgeInsets.symmetric(
        horizontal: padding / 2,
        vertical: padding * 0.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Row(
            children: [
              AvatarProfileImageZero(url: HomePageIcons.finoraIcon, width: 30, height: 40),
              SizedBox(width: AppSizes.w10),
              Text( HomepageStringsDart().finora,
              style: FontManager().getTextStyle(context, color: colors.primary, letterSpacing: 2.2, fontSize: 16, lWeight: FontWeight.w500),
              )

            ],
          ),

       const   SizedBox(height: AppSizes.h16),

          
          SizedBox(
            height: screenSize.height * 0.14,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCardWrapper(
                    context,
                    screenSize,
                    TotalSpendingCard(controller: controller,),
                  ),
                  _buildCardWrapper(
                    context,
                    screenSize,
                    OverspentCategoriesCard(controller: controller,),
                  ),
                  _buildCardWrapper(
                    context,
                    screenSize,
                    FrequentTransactionCard(controller: controller,),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildCardWrapper(
  BuildContext context,
  Size screenSize,
  Widget card,
) {
  final colors = context.appColors;
  return Padding(
    padding: const EdgeInsets.only(right:AppSizes.p12),
    child: Container(
      width: screenSize.width * 0.8, // 👈 KEY CHANGE (peek effect)
      height: screenSize.height * 0.14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
        child: card,
      ),
    ),
  );
}

}

class TotalSpendingCard extends StatelessWidget {
  // FinoraController finoraController = ControllerManagement.finoraController;
   final FinoraController controller;
   TotalSpendingCard({required this.controller});
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // final padding = screenSize.width * 0.03;

    return Obx(
      () {
        final colors = context.appColors;
        return Container(
        height: MediaQuery.of(context).size.height / 4,
        decoration: BoxDecoration(
          color: colors.background,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p4),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                 Container(
                   padding: EdgeInsets.all(AppSizes.p2),
                    decoration: BoxDecoration(
                       color: colors.primary.withOpacity(0.04),
                       borderRadius: BorderRadius.circular(13),
                    ),
                  child: Icon(Icons.sunny, color: colors.primary, size: 24,)),
                 SizedBox(width: AppSizes.w8),
                  Text(
                    'Monthly Summary',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 16,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: AppSizes.h20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Spending',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w400,
                          fontSize: 14,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(
                        height: AppSizes.h8,
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width / 2.6,
                        child: Text(
                          '₹${formatMoneyIndian( controller.totalDebitThisMonth.value.toStringAsFixed(0))}',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w500,
                            fontSize:20,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average/Day',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w400,
                          fontSize: 14,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(
                        height: AppSizes.h8,
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width / 2.9,
                        child: Text(
                          '₹${formatMoneyIndian((( controller.totalDebitThisMonth.value / (DateTime.now().day == 0 ? 1 : DateTime.now().day)).toStringAsFixed(0)))}',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w500,
                              fontSize:20,
                              color: colors.primary,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
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
}

class OverspentCategoriesCard extends StatelessWidget {
  // FinoraController finoraController = ControllerManagement.finoraController;
   final FinoraController controller;
   OverspentCategoriesCard({required this.controller});
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.03;

    return Obx(
      () {
        final colors = context.appColors;
        return Container(
        decoration: BoxDecoration(
          color: colors.background,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overspent Categories',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: screenSize.width * 0.04,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(height: AppSizes.h4),
                    Text(
                      '(${ selectedPeriod.value}ly)',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                        fontSize: screenSize.width * 0.02,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                     selectedPeriod.value =
                         selectedPeriod.value == 'Week' ? 'Month' : 'Week';
                  },
                  child: Icon(
                    Icons.swap_horiz,
                    color: colors.primary,
                    size: screenSize.width * 0.06,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.h5),
            _buildCategoryList(screenSize, padding, context),
          ],
        ),
      );
      },
    );
  }

  Widget _buildCategoryList(
      Size screenSize, double padding, BuildContext context) {
    // Check if lists are null or empty
    final isMonthPeriod =  selectedPeriod.value == 'Month';
    final categoryList =
        isMonthPeriod ?  controller.moreDrasticChange :  controller.moreDrasticChangeWeek;

    final colors = context.appColors;
    if (categoryList == null || categoryList.isEmpty) {
      return Center(
        child: Text(
          'No Data',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: screenSize.width * 0.035,
            color: colors.primary.withOpacity(0.8),
          ),
        ),
      );
    }

    return Column(
      children: categoryList.take(2).map((category) {
        // Null checks for category map entries
        final categoryName = category != null && category['category'] != null
            ? category['category'].toString().capitalize ?? 'Unknown'
            : 'Unknown';
        final debitDiff = category != null && category['debit_diff'] != null
            ? formatMoneyIndian(category['debit_diff'].toStringAsFixed(2))
            : '0.00';

        return Padding(
          padding: EdgeInsets.only(bottom: padding * 0.4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: screenSize.width * 0.035,
                  color: colors.onBackground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '₹$debitDiff',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: screenSize.width * 0.033,
                  color: colors.onBackground,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class FrequentTransactionCard extends StatelessWidget {
  // FinoraController finoraController = ControllerManagement.finoraController;
   final FinoraController controller;
   FrequentTransactionCard({required this.controller});
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.03;

    return Obx(() {
      final colors = context.appColors;
      return Container(
        decoration: BoxDecoration(
          color: colors.background,
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                  Container(
                    padding: EdgeInsets.all(AppSizes.p2),
                    decoration: BoxDecoration(
                       color: colors.primary.withOpacity(0.04),
                       borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(Icons.graphic_eq, color: colors.primary, size: 24,)),
                 SizedBox(width: AppSizes.w8),
                  Text(
                    'Most Frequent Payment',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 16,
                      color: colors.primary,
                    ),
                  ),
              
              ],
            ),
            controller.frequentPayments.isEmpty
                ? Text(
                    'No Data',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: screenSize.width * 0.045,
                      color: colors.onBackground,
                    ),
                  )
                :
                 Text(
                     controller.frequentPayments[0]['name'].toString(),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: screenSize.width * 0.04,
                      color: colors.onBackground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
             controller.frequentPayments.isEmpty
                ? SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${ controller.frequentPayments[0]['count']} Transactions',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w400,
                          fontSize: screenSize.width * 0.035,
                          color: colors.secondaryText,
                        ),
                      ),
                      Text(
                        '₹${formatMoneyIndian( controller.frequentPayments[0]['totalAmount'].toStringAsFixed(2))}',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: screenSize.width * 0.05,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      );
    });
  }
}

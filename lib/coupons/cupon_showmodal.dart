



// import 'package:flutter/material.dart';

// import '../Constants/app_styles.dart';
// import '../Constants/font_manager.dart';
// import '../Home_Screen/colors.dart';
// import '../backed_connections/apiAutomations/curd.dart';




// void showCouponPopup(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Container(
//             padding: EdgeInsets.all(24),
//             width: MediaQuery.of(context).size.width * 0.9,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: GestureDetector(
//                     onTap: () => Navigator.of(context).pop(),
//                     child: Container(
//                       padding: EdgeInsets.all(4),
//                       child: Icon(
//                         Icons.close,
//                         color: Colors.grey.shade600,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.shade100,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         '🎁',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     Text(
//                       'You Won a Coupon!',
//                       style: FontManager().getTextStyle(
//                         context,
//                         fontSize: 20,
//                         lWeight: FontWeight.w700,
//                         color: AppColors.bg1,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'You selected 2 transactions.\nAs a reward',
//                   textAlign: TextAlign.center,
//                   style: FontManager().getTextStyle(
//                     context,
//                     fontSize: 12,
//                     lWeight: FontWeight.w500,
//                     color: AppColors.now,
//                   ),
//                 ),
//                 SizedBox(height: 24),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Select the category',
//                     style: FontManager().getTextStyle(
//                       context,
//                       fontSize: 12,
//                       lWeight: FontWeight.w600,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Container(
//                   height: 100,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: categoriesOfReward.length,
//                     itemBuilder: (context, index) {
//                       final category = categoriesOfReward[index];
//                       return Container(
//                         margin: EdgeInsets.only(right: 12),
//                         child: buildCategoryCard(
//                           category['title'],
//                           category['emoji'],
//                           category['color'],
//                           context
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 16),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }


//   Widget buildCategoryCard(String title, String emoji, Color backgroundColor,BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // Navigator.of(context).pop();
//         _fetchCategoryCoupons(title);
//         _showCouponSelectionPopup(context, title);
//       },
//       child: Container(
//         width: 80,
//         height: 80,
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               emoji,
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(height: 4),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: FontManager().getTextStyle(
//                 context,
//                 fontSize: 12,
//                 lWeight: FontWeight.w600,
//                 color: AppColors.bg1,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }


// Future<void> _fetchCategoryCoupons(String category) async {
//     try {
//       isLoading.value = true;
      
//       // Trim spaces and replace with no spaces
//       final formattedCategory = category.replaceAll(' ', '');
//       final response = await getDataApiCall('$url/reward/search/$formattedCategory');

//       if (getFlagOfResponse(response)) {
//         final List<dynamic> data = jsonDecode(response.body)['data'];
//         categoryCoupons.assignAll(CouponModel.listFromJson(data));
//       }
//     } catch (e) {
//       // Handle error silently as per your code
//     } finally {
//       isLoading.value = false;
//     }
//   }


//    void _showCouponSelectionPopup(BuildContext context, String categoryTitle) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Container(
//             padding: EdgeInsets.all(24),
//             width: MediaQuery.of(context).size.width * 0.9,
//             height: MediaQuery.of(context).size.height * 0.7,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Column(
//               children: [
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: GestureDetector(
//                     onTap: () => Navigator.of(context).pop(),
//                     child: Container(
//                       padding: EdgeInsets.all(4),
//                       child: Icon(
//                         Icons.close,
//                         color: Colors.grey.shade600,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ),
                
//                 SizedBox(height: 24),
//                 Expanded(
//                   child: Obx(() => isLoading.value
//                       ? Center(child: Spinner())
//                       : categoryCoupons.isEmpty
//                           ? Center(child: Text('No coupons available'))
//                           : EnvelopeGrid(categoryCoupons: categoryCoupons)),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
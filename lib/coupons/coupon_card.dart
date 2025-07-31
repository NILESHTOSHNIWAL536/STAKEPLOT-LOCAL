// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:coupon_uikit/coupon_uikit.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/dotted_Border.dart';
// import 'package:flutter_application_code_stakeplot/Utils/rewardscreen.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/reward.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';

// class CouponCardWidget extends StatelessWidget {
//   final CouponModel coupon;
//   final VoidCallback onClaim;
//   BuildContext parentContext;

//    CouponCardWidget(
//       {Key? key, required this.coupon, required this.onClaim,required this.parentContext})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     bool isClaimed = onClaim.toString().contains('Closure: () => null');
//     double height = MediaQuery.of(context).size.height / 1.8;
//     final width = MediaQuery.of(context).size.width;
//     double curve=  height / 2.5;
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         CouponCard(
//           height: height,
//           width: width/1.15,
//           backgroundColor: Colors.white,
//           curveAxis: Axis.horizontal,
//           curvePosition: curve,
//           curveRadius: 30,
//           borderRadius: 16,
//           firstChild: Container(
//             height: curve,
//             width: double.infinity,
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [

//                     Row(
//                       children: [
//                           coupon.image.isNotEmpty
//                                         ? Image.network(
//                                             coupon.image,
//                                             width: fontSize * 2.5, // Adjust size as needed
//                                             height: fontSize * 2.5,
//                                             errorBuilder: (context, error, stackTrace) => Icon(
//                                               Icons.broken_image,
//                                               size: fontSize * 1.5,
//                                               color: Colors.grey,
//                                             ),
//                                           )
//                                         : Icon(
//                                             Icons.image,
//                                             size: fontSize * 1.5,
//                                             color: Colors.grey,
//                                           ),
//                         const SizedBox(width:4),
//                         InkWell(
//                           onTap: (){
//                              redirectToUrl(context, coupon.link);
//                           },
//                           child: textStyleImage(
//                               context: context,
//                               text: coupon.brand,
//                               fontWeight: FontWeight.bold,
//                               fontsize: 24,
//                               c: Colorcodes.red,
//                               iswrap: true
//                             ),
//                         ),

//                       ],
//                     ),
//                     InkWell(
//                       onTap: (){
//                          Navigator.pop(context);
//                       },
//                       child: Icon(Icons.close,size: 20,color: AppColors.greyCard,)),
//                   ],
//                 ),
//                 Text(
//                   coupon.title,
//                   style: FontManager().getTextStyle(
//                     context,
//                     fontSize: 16,
//                     lWeight: FontWeight.w700,
//                     color: AppColors.bg1,

//                   ),
//                   softWrap: false,
//                 ),
//                 Text(
//                   coupon.description,
//                   style: FontManager().getTextStyle(
//                     context,
//                     fontSize: 14,
//                     lWeight: FontWeight.w600,
//                     color: AppColors.bg1,
//                     lineHeight: 1.1
//                   ),
//                   softWrap: true,
//                 ),

//               ],
//             ),
//           ),
//           secondChild: Container(
//             height: height / 1.8,
//             width: double.infinity,
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     textStyle(
//                         context: context,
//                         text: 'Copy code',
//                         fontWeight: FontWeight.bold,
//                         fontsize: 18),
//                     SizedBox(height: 12),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               coupon.code,
//                               style: FontManager().getTextStyle(
//                                 context,
//                                 fontSize: 14,
//                                 lWeight: FontWeight.w500,
//                                 color: AppColors.primaryColor,
//                               ),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Clipboard.setData(ClipboardData(text: coupon.code));
//                               // Silently handle copy action as per your code
//                             },
//                             child: Icon(
//                               Icons.copy,
//                               color: Colors.grey.shade600,
//                               size: 20,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     InkWell(
//                       // coupon.link
//                       onTap: () async
//                       {
//                           redirectToUrl(context,RewardScreenStrings().productUrl.value);
//                       },
//                       child: Text(
//                         'In partnership with fishmydeal - exclusively on Stakeplot',
//                         style: FontManager().getTextStyle(
//                           context,
//                           fontSize: 10,
//                           lWeight: FontWeight.w700,
//                           color: AppColors.bg1,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width/1.1,
//                   child: ElevatedButton(
//                     onPressed: isClaimed ? null : () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF4C51BF),
//                       padding: EdgeInsets.symmetric(vertical: 9),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       isClaimed ? 'Claimed' : 'Save',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//            getBorderDotted(curve, context),
//       ],
//     );
//   }

//    Widget getBorderDotted(curve,context){
//     return Positioned(
//                                 top: curve+13, // Adjusts the SVG to appear above the card
//                                 left: 16,
//                                 child: Center(
//                                   child: Container(
//                                     width: MediaQuery.of(context).size.width/1.28,
//                                     child: DottedDivider(
//                                           height: 1,
//                                           dashWidth: 12,
//                                           dashSpacing: 3,
//                                           color: Colors.grey,
//                                         ),
//                                   ),
//                                 ),
//                               );
//   }

//   Widget _buildBulletPoint(String text) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           margin: EdgeInsets.only(top: 6, right: 8),
//           width: 4,
//           height: 4,
//           decoration: BoxDecoration(
//             color: Colors.black,
//             shape: BoxShape.circle,
//           ),
//         ),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.black87,
//               height: 1.4,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/dotted_Border.dart';
import 'package:flutter_application_code_stakeplot/Utils/rewardscreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/reward.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';

class CouponCardWidget extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback onClaim;
  final BuildContext parentContext;

  CouponCardWidget({
    Key? key,
    required this.coupon,
    required this.onClaim,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isClaimed = onClaim.toString().contains('Closure: () => null');
    // Responsive height based on screen size, capped for smaller devices
    double height =
        MediaQuery.of(context).size.height * 0.45; // 45% of screen height
    height = height.clamp(300, 450); // Min 300, max 450 for consistency
    final width =
        MediaQuery.of(context).size.width * 0.9; // 90% of screen width
    double curve = height * 0.55; // Adjusted curve for more space in firstChild

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CouponCard(
          height: height,
          width: width,
          backgroundColor: Colors.white,
          curveAxis: Axis.horizontal,
          curvePosition: curve,
          curveRadius: 20,
          borderRadius: 20,
          firstChild: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          coupon.image.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    coupon.image,
                                    width: fontSize * 3.2,
                                    height: fontSize * 2.2,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                      Icons.broken_image,
                                      size: fontSize * 1.5,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.image,
                                  size: fontSize * 1.5,
                                  color: Colors.grey.shade400,
                                ),
                          SizedBox(width: 8),
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                redirectToUrl(context, coupon.link);
                              },
                              child: textStyleImage(
                                context: context,
                                text: coupon.brand,
                                fontWeight: FontWeight.w800,
                                fontsize: 20,
                                c: Colorcodes.red,
                                iswrap: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: AppColors.greyCard.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  coupon.title,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 16,
                    lWeight: FontWeight.w600,
                    color: AppColors.bg1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Text(
                  coupon.description,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 12,
                    lWeight: FontWeight.w500,
                    color: AppColors.grey,
                    lineHeight: 1.2,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          secondChild: Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textStyle(
                      context: context,
                      text: 'Copy Code',
                      fontWeight: FontWeight.w700,
                      fontsize: 16,
                      c: AppColors.bg1,
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              coupon.code,
                              style: FontManager().getTextStyle(
                                context,
                                fontSize: 14,
                                lWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: coupon.code));
                              snackBarCalled(context, "code copied");
                            },
                            child: Icon(
                              Icons.copy,
                              color: AppColors.primaryColor.withOpacity(0.7),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        redirectToUrl(
                            context, RewardScreenStrings().productUrl.value);
                      },
                      child: Text(
                        'In partnership with fishmydeal - exclusively on Stakeplot',
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 11,
                          lWeight: FontWeight.w600,
                          color: AppColors.bg1.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: 70,
                    child: ElevatedButton(
                      onPressed: isClaimed
                          ? null
                          : () {
                              onClaim();
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isClaimed
                            ? Colors.grey.shade300
                            : AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: isClaimed ? 0 : 2,
                      ),
                      child: Text(
                        isClaimed ? 'Claimed' : 'Save',
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 14,
                          lWeight: FontWeight.w600,
                          color: AppColors.backgroundColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        getBorderDotted(curve, context),
      ],
    );
  }

  Widget getBorderDotted(double curve, BuildContext context) {
    return Positioned(
      top: curve - 0.5, // Centered on the curve
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: DottedDivider(
            height: 1,
            dashWidth: 10,
            dashSpacing: 4,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

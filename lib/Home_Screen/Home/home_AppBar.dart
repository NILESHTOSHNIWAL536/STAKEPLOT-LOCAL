import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/components/notification_icon.dart';
import 'package:lottie/lottie.dart';
import '../../Constants/app_styles.dart';
import '../../Constants/core/app_padding_sizes.dart';

// PreferredSizeWidget getAppBar(context) {
//   final userController = ControllerManagement.userController;

//   return PreferredSize(
//     preferredSize: const Size.fromHeight(60),
//     child: AppBar(
//       backgroundColor: AppColors.backgroundColor,
//       automaticallyImplyLeading: false,
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 10, top: 6, left: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             // crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//                GestureDetector(
//                     onTap: () {
                    
//                     },
//                     child: AvatarProfileImage(
//                       url: Strides.stride,
//                       width: 30,
//                       height: 30,
                     
//                     ),
//                   )
             
//             ],
//           ),
//         ),
//         Spacer(),
//         NotificationsBudget(
//           child: Text(""),
//         ),
//       ],
//     ),
//   );
// }

class TopRightIconsWidget extends StatelessWidget {
  const TopRightIconsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// PROFILE ICON
        GestureDetector(
          onTap: () {
            // TODO: Add your navigation or action here
           
          },
          child: Container(
            padding: const EdgeInsets.all(1),
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
             color: AppColors.border,
             borderRadius: BorderRadius.circular(12)
            ),
            child: AvatarProfileImageZero(
              url: Strides.stride,
              width: 30,
              height: 30,
            ),
          ),
        ),

         SizedBox(width: AppSizes.w16),

        /// NOTIFICATION BUTTON
        NotificationsBudget(
          child: const SizedBox(),
        ),
      ],
    );
  }
}


// PreferredSizeWidget historyAppBar(context, fromAutoPay) {
//   return AppBar(
//     backgroundColor: AppColors.newbg,
//     // Flat design for a modern look
//     title: Text(
//       !fromAutoPay?
//       HomepageStringsDart().historyTitle:"Select Transaction",
//       style: FontManager().getTextStyle(
//         context,
//         lWeight: FontWeight.w600,
//         fontSize: 18, // Slightly larger for better readability
//         color: AppColors.primaryColor,
//       ),
//     ),
//     // Center the title for symmetry
//     leading: IconButton(
//       icon: Icon(
//         Icons.arrow_back_ios, // More refined back icon
//         color: AppColors.accentColor,
//         size: 24, // Slightly smaller for balance
//       ),
//       onPressed: () {
//         clearTransactions(context: context);
//         Navigator.pop(context);
//       },
//       splashRadius: 20, // Smaller splash radius for a subtle effect
//     ),
//     actions:fromAutoPay?null: [
//       Padding(
//         padding: const EdgeInsets.only(right: 16.0), // Proper spacing
//         child: InkWell(
//           onTap: () {
//             int len = bankAccountLinkedList.length;
//             if (len == 0) {
//               snackBarCalled(context, SnackbarData().noBankForLinking);
//             }
            
//           //   else {
//           //     accountIdPdf.value = bankAccountLinkedList[0]['accountId'];
//           //     showModalForPdfDownloadBankUiCheckBox(context);
//           //   }
//           // },
//           else {
//   if (bankAccountLinkedList.isNotEmpty) {
//     accountIdPdf.value = bankAccountLinkedList[0].accountId;
//     showModalForPdfDownloadBankUiCheckBox(context);
//   }
// }},

//           splashColor:
//               AppColors.accentColor.withOpacity(0.2), // Subtle splash effect
//           borderRadius: BorderRadius.circular(12), // Rounded ripple effect
//           child: Icon(
//             Icons.download,
//             size: 24,
//             color: AppColors.primaryColor,
//           ),
//         ),
//       ),
//     ],
//   );
// }




class AutoHintIcon extends StatefulWidget {
  final String text;
  final String iconUrl;

  const AutoHintIcon({
    super.key,
    required this.text,
    required this.iconUrl,
  });

  @override
  State<AutoHintIcon> createState() => _AutoHintIconState();
}

class _AutoHintIconState extends State<AutoHintIcon> {
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _showOnce();
  }

   void _showOnce() async {
    // small delay so layout is ready
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    setState(() => _showText = true);

    // keep visible for some time
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    setState(() => _showText = false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _showText?SizedBox.shrink(): SizedBox(width: MediaQuery.of(context).size.width * 0.17),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          child: Container(
            padding:  EdgeInsets.symmetric(horizontal:_showText ? 8: 2, vertical: _showText?4:2),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: _showText?BorderRadius.circular(30):BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon (always visible)
                 
        
                // Space + text only when visible
                if (_showText) ...[
                 
                  Text(
                    widget.text,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 11,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
                AvatarProfileImage(
                  url: widget.iconUrl,
                  width: 36,
                  height: 36,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

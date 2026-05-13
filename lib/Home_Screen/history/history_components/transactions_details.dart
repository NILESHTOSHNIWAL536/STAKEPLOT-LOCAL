import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:get/get.dart';

import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/core/app_shadows.dart';
import '../../../Constants/theme_helper.dart';
import 'icon_split_hide.dart';

class TransactionDetails extends StatelessWidget {
  final TransactionModel transaction;
  final bool isExcluded;
  final bool isReview;
  final bool isManual;
  final bool isSplit;
  final String category;
  final String logo;
  final double amount;
  final String formatAmount;
  final String formatAmountBalance;
  final String nameOfUser;
  final String formattedDate;
  final String formattedDateManual;
  final int index;
  final FontSizeFactor fontSizes;
  final Color amtColor;
  final BuildContext context;
  final bool hide;

  const TransactionDetails({
    required this.hide,
    required this.transaction,
    required this.isExcluded,
    required this.isReview,
    required this.isManual,
    required this.isSplit,
    required this.category,
    required this.logo,
    required this.amount,
    required this.formatAmount,
    required this.formatAmountBalance,
    required this.nameOfUser,
    required this.formattedDate,
    required this.formattedDateManual,
    required this.index,
    required this.fontSizes,
    required this.amtColor,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Obx(() => Container(
          width: MediaQuery.of(context).size.width /
              (showCheckBox.value ? 1.2 : 1.1),
          padding: EdgeInsets.only(
              top: isExcluded ? 0 : fontSizes.padding / 6,
              bottom: isExcluded ? 0 : fontSizes.padding / 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: fontSizes.padding),
                child: Row(
                  children: [
                    isExcluded
                        ? getIconAvtarForTagShowModal(
                            30,
                            category,
                            fontSizes.scaleFactor / 2,
                            transaction,
                            index,
                            context)
                        : getIconAvtarForTagShowModal(
                            fontSizes.avatarSize,
                            category,
                            fontSizes.scaleFactor,
                            transaction,
                            index,
                            context),
                    SizedBox(width: fontSizes.padding),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width / 3.3,
                                child: textStyle(
                                  context: context,
                                  text: transaction.subcategory == ""
                                      ? nameOfUser
                                      : transaction.subcategory,
                                  c: colors.onSurface,
                                  fontsize: 13,
                                  fontWeight: FontWeight.w500,
                                  lineHeight: 1.5,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  textStyle(
                                    context: context,
                                    text: formatAmount,
                                    c: colors.primary,
                                    fontsize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          textStyle(
                            context: context,
                            text:
                                isManual ? formattedDateManual : formattedDate,
                            c: colors.secondaryText,
                            fontsize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              isExcluded
                  ? SizedBox(height: AppSizes.h10)
                  : const SizedBox.shrink(),
              isExcluded
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(left: AppSizes.p4),
                      child: IconsForHideUpdateSplit(
                        iconSize: fontSizes.iconSize,
                        padding: fontSizes.padding,
                        category: category,
                        amount: amount,
                        logo: logo,
                        context: context,
                        index: index,
                        subcategory: transaction.subcategory,
                        transaction: transaction,
                        isReview: isReview,
                        id: transaction.id,
                        isManual: isManual,
                        hide: hide,
                        isSplit: isSplit,
                        isExcluded: isExcluded,
                        formatAmountBalance: formatAmountBalance,
                      ),
                    ),
              (isManual || isReview)
                  ? const SizedBox(height: 0)
                  : isExcluded
                      ? const SizedBox.shrink()
                      : SizedBox(height: fontSizes.padding / 2),
            ],
          ),
        ));
  }
}

Widget getIconAvtarForTagShowModal(
    double avatarSize,
    String category,
    double scaleFactor,
    TransactionModel transaction,
    int index,
    BuildContext context) {
  String lowerCategory = category?.toLowerCase() ?? '';

  final matched = custom.firstWhere(
    (item) => item['name']?.toString().toLowerCase() == lowerCategory,
    orElse: () => {},
  );

  final url = matched.isNotEmpty && matched['imageUrl'] != null
      ? matched['imageUrl']
      : imageMapForHistory[lowerCategory] != null
          ? Categories.link + imageMapForHistory[lowerCategory].toString()
          : "assets/icons/Categories2/other.svg";

  return InkWell(
    onTap: () {
      tagName.value = category;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return TagShowmodal(
            data: transaction,
            index: index,
          );
        },
      );
    },
    child: Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colorcodes.greyLight,
          width: 0.3,
        ),
        boxShadow: [AppShadows.soft],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 1400), // 1-second animation
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.4, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut, // Smooth scaling effect
                ),
              ),
              child: child,
            );
          },
          child: AvatarProfileImage(
            key: ValueKey<String>(
                url), // Unique key to trigger animation on URL change
            url: url,
            height: avatarSize * 0.5,
            width: avatarSize * 0.5,
          ),
        ),
      ),
    ),
  );
}
// Widget getIconAvtarForTagShowModal(double avatarSize, String category, double scaleFactor, TransactionModel transaction, int index, BuildContext context) {
//   String lowerCategory = category?.toLowerCase() ?? '';

//   final matched = custom.firstWhere(
//     (item) => item['name']?.toString().toLowerCase() == lowerCategory,
//     orElse: () => {},
//   );

//   final url = matched.isNotEmpty && matched['imageUrl'] != null
//       ? matched['imageUrl']
//       : imageMapForHistory[lowerCategory] != null
//           ? Categories.link + imageMapForHistory[lowerCategory].toString()
//           : "assets/icons/Categories2/other.svg";

//   return InkWell(
//    onTap: () {
//               tagName.value = category;
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 builder: (context) {
//                   return TagShowmodal(
//                     data: transaction,
//                     index: index,
//                   );
//                 },
//               );
//             },
//     child: Container(
//       width: avatarSize,
//       height: avatarSize,
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: Colorcodes.greyLight,
//           width: 0.3,
//         ),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Center(
//         child: AvatarProfileImage(
//           url: url,
//           height: avatarSize * 0.5,
//           width: avatarSize * 0.5,
//         ),
//       ),
//     ),
//   );
// }

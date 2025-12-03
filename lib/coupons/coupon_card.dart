import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/dotted_Border.dart';
import 'package:flutter_application_code_stakeplot/Utils/rewardscreen.dart';
import 'package:flutter_application_code_stakeplot/repository/reward_repository.dart';
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
    double height = MediaQuery.of(context).size.height *
        0.45; // Reduced to 45% for better fit
    height =
        height.clamp(300, 500); // Adjusted max to 500 for better proportion
    final width =
        MediaQuery.of(context).size.width * 0.9; // 90% of screen width
    double curve = height * 0.6;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CouponCard(
          height: height,
          width: width,
          backgroundColor: AppColors.backgroundColor,
          curveAxis: Axis.horizontal,
          curvePosition: curve,
          curveRadius: 20,
          borderRadius: 20,
          firstChild: Container(
            height: height * 0.6,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.backgroundColor,
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
                          const SizedBox(width: 8),
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
                const SizedBox(height: 8),
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
                const SizedBox(height: 14),
                Text(
                  coupon.description,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 12,
                    lWeight: FontWeight.w500,
                    color: AppColors.grey,
                    lineHeight: 1.2,
                  ),
                  maxLines: 8,
                  // softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          secondChild: Container(
            height: height * 0.4,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tap the 'Redeem' button to automatically copy the coupon code and be redirected to the offer URL.",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 12,
                        lWeight: FontWeight.w700,
                        color: AppColors.bg1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        text: 'In partnership with ',
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 12,
                          lWeight: FontWeight.w600,
                          color: AppColors.bg1.withOpacity(0.6),
                        ),
                        children: [
                          TextSpan(
                            text: 'fishmydeal',
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 13,
                              lWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                redirectToUrl(context,
                                    RewardScreenStrings().productUrl.value);
                              },
                          ),
                          TextSpan(
                            text: ' - exclusively on ',
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 12,
                              lWeight: FontWeight.w600,
                              color: AppColors.bg1.withOpacity(0.6),
                            ),
                          ),
                          TextSpan(
                            text: ' Stakeplot',
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 13,
                              lWeight: FontWeight.w600,
                              color: AppColors.bg6,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width / 1.5,
                    height: MediaQuery.sizeOf(context).height / 20,
                    child: ElevatedButton(
                      onPressed: isClaimed
                          ? null
                          : () {
                              Clipboard.setData(
                                  ClipboardData(text: coupon.code));
                              snackBarCalled(context, "Code Copied ");
                              redirectToUrl(context, coupon.link);
                              onClaim();
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isClaimed
                            ? Colors.grey.shade300
                            : AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: isClaimed ? 0 : 2,
                      ),
                      child: Text(
                        isClaimed ? 'Claimed' : 'Redeem',
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
      top: curve + 10, // Centered on the curve
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.84,
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

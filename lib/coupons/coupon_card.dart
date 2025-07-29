import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/webView.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CouponCardWidget extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback onClaim;
  BuildContext parentContext;

   CouponCardWidget(
      {Key? key, required this.coupon, required this.onClaim,required this.parentContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isClaimed = onClaim.toString().contains('Closure: () => null');
    double height = MediaQuery.of(context).size.height / 1.7;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: CouponCard(
        height: height,
        backgroundColor: Colors.white,
        curveAxis: Axis.horizontal,
        curvePosition: height / 2.2,
        curveRadius: 20,
        borderRadius: 16,
        firstChild: Container(
          height: height / 2.2,
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textStyle(
                      context: context,
                      text: coupon.brand,
                      fontWeight: FontWeight.bold,
                      fontsize: 24,
                      c: Colorcodes.red),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      textStyle(
                          context: context,
                          text: coupon.title,
                          fontWeight: FontWeight.w500,
                          fontsize: 20),
                      textStyle(
                          context: context,
                          text: coupon.brand,
                          fontWeight: FontWeight.w500,
                          fontsize: 16),
                    ],
                  ),
                ],
              ),
              Text(
                coupon.description,
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  lWeight: FontWeight.w700,
                  color: AppColors.bg1,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint(
                      'Redeemable at all ${coupon.brand} restaurants in INDIA.'),
                  SizedBox(height: 6),
                  _buildBulletPoint(
                      'Not valid with any other discounts and promotions.'),
                  SizedBox(height: 6),
                  _buildBulletPoint('No cash value.'),
                ],
              ),
            ],
          ),
        ),
        secondChild: Container(
          height: height / 1.8,
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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
                      text: 'Copy code',
                      fontWeight: FontWeight.bold,
                      fontsize: 18),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            coupon.code,
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 14,
                              lWeight: FontWeight.w500,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: coupon.code));
                            // Silently handle copy action as per your code
                          },
                          child: Icon(
                            Icons.copy,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    // coupon.link
                    onTap: () async {
                      String urlString = coupon.link.trim();
                      WebViewController controller = WebViewController()
                                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                ..loadRequest(Uri.parse(
                                    urlString));
                      // Navigator.push(
                      //   parentContext,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         WebViewPage(controller: controller),
                      //   ),
                      // );
                              
                      if (urlString.isEmpty) {
                        snackBarCalledfail(context, "No link provided");
                        return;
                      }

                        try {
                          // Get.to(() => WebViewPage(controller: controller));
                          final uri = Uri.tryParse(urlString);

                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            print("Failed to launch URL: $urlString"); // Log to console
                            snackBarCalledfail(context, "Invalid or unsupported URL: $urlString");
                          }
                        } catch (e) {
                          print("Error launching URL: $e"); // Print actual error
                          snackBarCalledfail(context, "Error: ${e.toString()}"); // Show in snackbar
                        }

                    },
                    child: Text(
                      'In partnership with fishmydeal - exclusively on Stakeplot',
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 10,
                        lWeight: FontWeight.w700,
                        color: AppColors.bg1,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isClaimed ? null : () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4C51BF),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isClaimed ? 'Claimed' : 'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 6, right: 8),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

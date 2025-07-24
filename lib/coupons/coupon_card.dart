import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';

class CouponCardWidget extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback onClaim;

  const CouponCardWidget({Key? key, required this.coupon, required this.onClaim})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isClaimed = onClaim.toString().contains('Closure: () => null');
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: CouponCard(
        height: 600,
        backgroundColor: Colors.white,
        curveAxis: Axis.horizontal,
        curvePosition: 250,
        curveRadius: 20,
        borderRadius: 16,
        firstChild: Container(
          height: 250,
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
                  Text(
                    coupon.brand,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53E3E),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        coupon.title,
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 24,
                          lWeight: FontWeight.w500,
                          color: AppColors.bg1,
                        ),
                      ),
                      Text(
                        coupon.brand,
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 16,
                          lWeight: FontWeight.w500,
                          color: AppColors.bg1,
                        ),
                      ),
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
                  _buildBulletPoint('Redeemable at all ${coupon.brand} restaurants in INDIA.'),
                  SizedBox(height: 6),
                  _buildBulletPoint('Not valid with any other discounts and promotions.'),
                  SizedBox(height: 6),
                  _buildBulletPoint('No cash value.'),
                ],
              ),
            ],
          ),
        ),
        secondChild: Container(
          height: 250,
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
                  Text(
                    'Copy code',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 14,
                      lWeight: FontWeight.w500,
                      color: AppColors.bg1,
                    ),
                  ),
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
                  Text(
                    'In partnership with fishmydeal - exclusively on Stakeplot',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 10,
                      lWeight: FontWeight.w700,
                      color: AppColors.bg1,
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
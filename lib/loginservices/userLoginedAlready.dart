import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/loginservices/two_factor_email_verification.dart';
import 'package:get/get.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Constants/font_manager.dart';
import '../Constants/theme_helper.dart';
import '../repository/auth_service/otp_service.dart';

class UserLoginedAlready extends StatelessWidget {
  final dynamic data;
  final TextEditingController email;

  final RxBool isLoading = false.obs;

  UserLoginedAlready({
    Key? key,
    required this.data,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> body =
        (data != null && data['explanation'] != null)
            ? Map<String, dynamic>.from(data['explanation'])
            : {};

    final loggedDevice =
        body['loggedInDevice'] is Map ? body['loggedInDevice'] : {};

    final user = body['user'] is Map ? body['user'] : {};

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.p10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.4,
      decoration: BoxDecoration(
        color: context.appColors.dialogBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 5,
            height: MediaQuery.of(context).size.height / 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.appColors.iconBackground,
              // borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: context.appColors.border,
                width: 0,
              ),
            ),
            child: Icon(Icons.warning),
          ),
          _item(context, body['message'] ?? "Account already active", 15,
              context.appColors.onSurface, 28),
          _item(
              context,
              "Your email account is currently logged in on another device. For security reasons, you can only be logged in on one device at a time.",
              15,
              context.appColors.secondaryText,
              23),
          Container(
            padding: EdgeInsets.all(AppSizes.p12),
            width: MediaQuery.of(context).size.width / 1.2,
            height: MediaQuery.of(context).size.height / 12,
            decoration: BoxDecoration(
              color: context.appColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.appColors.border,
                width: 0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSizes.p12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appColors.iconBackground,
                    // borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: context.appColors.border,
                      width: 0,
                    ),
                  ),
                  child: Icon(Icons.phone_android_outlined,
                      color: context.appColors.onSurface),
                ),
                SizedBox(width: AppSizes.w12),
                Text(
                  loggedDevice['device'] ?? "Iphone",
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 15,
                      color: context.appColors.onSurface),
                ),
                Text(
                  loggedDevice['brand'] ?? "Iphone",
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 15,
                      color: context.appColors.onSurface),
                )
              ],
            ),
          ),
          SizedBox(height: AppSizes.h20),
          InkWell(
            onTap: () {
              isLoading.value = true;

              OtpService.getOTPForTwoFactorAuth(
                context,
                user['name'] ?? "",
                email.text,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TwoFactorEmailVerification(
                    data: {
                      'email': email.text,
                      'response': body,
                      'isForcedLogin': true,
                      'newUser': false,
                    },
                  ),
                ),
              );
            },
            child: Obx(() => isLoading.value
                ? getspinner(context, 30)
                : Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: AppSizes.p18),
                    decoration: BoxDecoration(
                        color: AppColors.redColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        "Logout Other device",
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    ),
                  )),
          ),
          SizedBox(height: AppSizes.h10),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Obx(() => isLoading.value
                ? getspinner(context, 30)
                : Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    padding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: AppSizes.p18),
                    decoration: BoxDecoration(
                        color: context.appColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w500,
                            fontSize: 15,
                            color: context.appColors.onSurface),
                      ),
                    ),
                  )),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String text, double size, Color color,
      double lineHeight) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p10),
      width: MediaQuery.of(context).size.width / 1.1,
      child: Center(
          child: Text(
        textAlign: TextAlign.center,
        text,
        style: FontManager().getTextStyle(
          context,
          fontSize: size,
          color: color,
          lineHeight: lineHeight / size,
        ),
      )),
    );
  }
}

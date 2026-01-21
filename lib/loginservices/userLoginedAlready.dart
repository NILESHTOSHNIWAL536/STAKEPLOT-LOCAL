import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/loginservices/two_factor_email_verification.dart';
import 'package:get/get.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Constants/font_manager.dart';
import '../repository/auth_service/otp_service.dart';

// class UserLoginedAlready extends StatelessWidget {
//   var data;
//   TextEditingController email;

//   var isLoading = false.obs;

//   UserLoginedAlready(
//       {Key? key,
//       required this.data,
//       required this.email,
//     })
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     var body = data['explanation'];
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 5, vertical: AppSizes.p10),
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height / 2,
//       decoration: BoxDecoration(
//           color: AppColors.backgroundColor,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           )),
//       child: Column(
//         children: [
//           Container(
//               width: MediaQuery.of(context).size.width / 2,
//               height: MediaQuery.of(context).size.height / 4.5,
//               child: AvatarProfileImage(
//                   url: "assets/icons/lock.svg", width: 10, height: 10)),
//           getContainer(context, body['message']),
//           getContainer(context, "Device Limit Exceeded"),
//           getContainer(
//               context,
//               body['loggedInDevice'] != ""
//                   ? body['loggedInDevice']['device'] ?? ""
//                   : ""),
//           getContainer(
//               context,
//               body['loggedInDevice'] != ""
//                   ? body['loggedInDevice']['brand'] ?? ""
//                   : ""),
//           InkWell(
//               onTap: () {
//                 isLoading.value = true;

//               OtpService.getOTPForTwoFactorAuth(context," body['user']['name']", email.text.toString());

//                 // Navigate to the OTP verification screen
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => TwoFactorEmailVerification(
//                       data: {
//                         'email': email.text.toString(),
//                         'response': body,
//                         'isForcedLogin': true,
//                         'newUser':false
//                       },
//                       // Pass the base URL
//                     ),
//                   ),
//                 );
//               },
//               child: Obx(() => isLoading.value
//                   ? getspinner(context, 30)
//                   : getButton(context, "Logout User")))
//         ],
//       ),
//     );
//   }

//   Widget getContainer(context, text) {
//     return Container(
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p10),
//         width: MediaQuery.of(context).size.width / 1.1,
//         child: textStyle(context: context, text: text, fontsize: 14));
//   }
// }
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.p10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.8,
      decoration:const  BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius:  BorderRadius.vertical(top: Radius.circular(20)),
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
               color: const Color(0xFFCACCEC),
  // borderRadius: BorderRadius.circular(9999),
  border: Border.all(
    color: const Color(0xFFE5E7EB),
    width: 0,
  ),
            ),
            // child: AvatarProfileImage(
            //   url: "assets/icons/lock.svg",
            //   width: 10,
            //   height: 10,
            // ),
            child: Icon(Icons.warning),
          ),

          _item(context, body['message'] ?? "Account already active", 18, AppColors.accentColor, 28),
          _item(context, "Your email account is currently logged in on another device. For security reasons, you can only be logged in on one device at a time.", 14, AppColors.grey, 23),
                    Container(
                      padding: EdgeInsets.all(AppSizes.p12),
            width: MediaQuery.of(context).size.width / 1.2,
            height: MediaQuery.of(context).size.height / 12,
            decoration: BoxDecoration(
             
             color: const Color(0xFFF9FAFB),
  borderRadius: BorderRadius.circular(8),
  border: Border.all(
    color: const Color(0xFFE5E7EB),
    width: 0,
  ),
            ),
            // child: AvatarProfileImage(
            //   url: "assets/icons/lock.svg",
            //   width: 10,
            //   height: 10,
            // ),
            child: Row(
              children: [
                 Container(
            padding: EdgeInsets.all(AppSizes.p12),
             decoration: BoxDecoration(
                          shape: BoxShape.circle,
                           color: const Color(0xFFCACCEC),
              // borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 0,
              ),
                        ),
                        child: Icon(Icons.phone_android_outlined),
                        ),
                        SizedBox(width: AppSizes.w12),
                 Text(
                     loggedDevice['device'] ??"Iphone",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w500, fontSize: 15, color:AppColors.accentColor ),
                  ),
                 Text(
                     loggedDevice['brand'] ??"Iphone",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w500, fontSize: 15, color:AppColors.accentColor ),
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
            child: Obx(
              () => isLoading.value
                  ? getspinner(context, 30):
                  Container(
    width: MediaQuery.of(context).size.width / 1.2,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p18),
    decoration: BoxDecoration(
        color: AppColors.redColor, borderRadius: BorderRadius.circular(8)),
    child: Center(
      child: Text(
         "Logout Other device",
        style: FontManager().getTextStyle(context,
            lWeight: FontWeight.w500, fontSize: 15, color:AppColors.backgroundColor ),
      ),
    ),
  )
            ),
          ),
        
         SizedBox(height: AppSizes.h10),
          InkWell(
            onTap: () {
            
               Navigator.pop(context);
            },
            child: Obx(
              () => isLoading.value
                  ? getspinner(context, 30):
                  Container(
    width: MediaQuery.of(context).size.width / 1.2,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p18),
    decoration: BoxDecoration(
        color: AppColors.border, borderRadius: BorderRadius.circular(8)),
    child: Center(
      child: Text(
         "Cancel",
        style: FontManager().getTextStyle(context,
            lWeight: FontWeight.w500, fontSize: 15, color:AppColors.accentColor ),
      ),
    ),
  )
            ),
          ),
        
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String text, double size, Color color, double lineHeight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p10),
      width: MediaQuery.of(context).size.width / 1.1,
      child: Center(

        child: Text(
          textAlign: TextAlign.center,
         text,
        style: FontManager().getTextStyle(context,
             fontSize: size, color:color ,
             lineHeight: lineHeight/size
             ,
            
             ),
      )
        
      ),
    );
  }
}

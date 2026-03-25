// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Utils/signUp.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
// import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/components/textfeild.dart';
// import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
// import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../Constants/app_styles.dart';
// import '../finance_screen/Budgets/Budget.dart';
// import '../image_service/avatarProfile.dart';
// import '../repository/auth_service/login_apis.dart';
// import '../services/secure_storage.dart';
// import '../backed_connections/googlesignin/credentials.dart';

// RxBool isValidUser=false.obs;
// class UserDetailsPage extends StatefulWidget {
//   final Map<String, dynamic> data;
//   const UserDetailsPage({Key? key, required this.data}) : super(key: key);

//   @override
//   _UserDetailsPageState createState() => _UserDetailsPageState();
// }

// class _UserDetailsPageState extends State<UserDetailsPage> {
//   RxBool flag = false.obs;
//   TextEditingController usernameController = TextEditingController();
//   TextEditingController dobController = TextEditingController();
//   RxString usernameError = ''.obs;
//   RxBool fg=false.obs;

//   @override
//   void initState() {
//     super.initState();
//     // Autofill fields with Google Sign-In data
//     isValidUser.value=false;
//     usernameController.text = widget.data['data']['name'].replaceAll(' ', '').toString().trim();
//     dobController.text = widget.data['data']['dob'] ?? '1970-01-01';
//     // Add listener for real-time username validation
//     usernameController.addListener(validateUsername);
//   }

//   @override
//   void dispose() {
//     usernameController.removeListener(validateUsername);
//     usernameController.dispose();
//     dobController.dispose();
//     super.dispose();
//   }

//   void validateUsername() {
//     String username = usernameController.text;
//     if (username.isEmpty) {
//       usernameError.value = 'Username cannot be empty';
//     } else if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
//       usernameError.value = 'Username must start with a letter';
//     } else if (username.length < 3) {
//       usernameError.value = 'Username must be at least 3 characters';
//     } else {
//       usernameError.value = '';
//     }
//   }

//   void submitDetails() async {
//     String username = usernameController.text;
//     if (!isValidUser.value) {
//       snackBarCalledfail(context, SignupData().emptyUsernameValid,  AppColors.redColor);
//       return;
//     }
//     if (username.isEmpty) {
//       snackBarCalledfail(context, SignupData().emptyUsername,  AppColors.redColor);
//       return;
//     }
//     if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
//       snackBarCalledfail(context, SignupData().invalidUsername,  AppColors.redColor);
//       return;
//     }
//     if (username.length < 3) {
//       snackBarCalledfail(context, SignupData().shortUsername,  AppColors.redColor);
//       return;
//     }
  

//     // Prepare updated data for storeData
//     final updatedData = {
//       'name': username,
//       'email': widget.data['data']['email'] ?? "heyooo@gmail.com",
//     };


//     flag.value = true;
//     fg.value=true;
//     await storeData2(context, updatedData, 'assets/avatar/FRAME-2.svg');
//     fg.value=false;
//     flag.value = false;
//   }

//   Future<void> storeData2(
//       context, Map<String, dynamic> data, String avatarUrl) async {
//     String name = data['name'];
//     String email = data['email'];
//       updateDeviceData(deviceData);
//     final response = await postDataApiCall(AuthApiRoutes.signUp,
//         {
//         'name': name,
//         'email': email,
//         'authorizationKey':Credentials.Sign_Up_Key,
//         'deviceInfo':deviceData
//       }
//     );

//     try {
//       var data2 = jsonDecode(response.body);
//       bool boolvar = data2['success'];

//       acceptReset.value = false;
//       if (!boolvar) {
//         snackBarCalledfail(
//             context, data2['error']['explanation'],  AppColors.redColor);
//         return;
//       }
//       final body = jsonDecode(response.body);

//       String accessToken = body['data'];
//      await SecureStorageService().setString("accessToken", "Bearer " + accessToken);
//       clearStack(context);
//       Navigator.pushReplacementNamed(context, '/ShareAccountLogin');
//     } catch (e) {
//       snackBarCalledfail(context, SignupData().errorInvalidOtp,  AppColors.redColor);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.newbg,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             padding: EdgeInsets.symmetric(horizontal: AppSizes.p20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                topHeaderToCreateProfile(),
//                 Padding(
//                   padding:
//                       EdgeInsets.symmetric(vertical: Colorcodes.paddingSize),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                     Obx(()=> isValidUser.value?getTextFeild():getTextFeild()),
//                       Obx(() => usernameError.value.isNotEmpty
//                           ? Padding(
//                               padding: EdgeInsets.only(left:AppSizes.p20, top: 5),
//                               child: Text(
//                                 usernameError.value,
//                                 style:
//                                     TextStyle(color:  AppColors.redColor, fontSize: 12),
//                               ),
//                             )
//                           : SizedBox.shrink()),
//                       // TextFeildCalender(
//                       //   textEditingController: dobController,
//                       //   heading: SignupData().dobLabel,
//                       //   keyBoard: TextInputType.datetime,
//                       //   lableText: SignupData().dobSubLabel,
//                       // ),
//                     ],
//                   ),
//                 ),
//              Obx(()=>   Center(
//                   child: Container(
//                     width: MediaQuery.of(context).size.width / 1.1,
//                     margin: const EdgeInsets.symmetric(
//                         vertical: AppSizes.p10, horizontal: 10),
//                     padding: EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 30),
//                     decoration: BoxDecoration(
//                       color: isValidUser.value? AppColors.primaryColor:AppColors.greyCard,
//                       borderRadius:
//                           BorderRadius.circular(12),
//                     ),
//                     child: InkWell(
//                       onTap: submitDetails,
//                       child: Obx(() => Center(
//                             child: !flag.value && fg.value
//                                 ? Spinner(
//                                     size: 20,
//                                     color: AppColors.backgroundColor,
//                                   )
//                                 : Text(
//                                     'Submit',
//                                     style: FontManager().getTextStyle(
//                                       context,
//                                       lWeight: FontWeight.bold,
//                                       fontSize: 20,
//                                       color: AppColors.backgroundColor,
//                                     ),
//                                   ),
//                           )),
//                     ),
//                   ),
//                 )),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }


// Widget topHeaderToCreateProfile() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AvatarProfileImageZero(url: Sign.appSignInimage, width: 14, height: 14),
//         const SizedBox(height: 8),
//         textStyle(
//             context: context,
//             text: 'What should we call you?',
//             fontWeight: FontWeight.w300,
//             fontsize: 18,
//             c: AppColors.accentColor
//             ),
//       ],
//     );
//   }
//   Widget getTextFeild(){
//     return TextFeildWidgetUnderline(
//                         textEditingController: usernameController,
//                         heading: SignupData().usernameLabel,
//                         keyBoard: TextInputType.name,
//                         lableText: SignupData().usernameSubLabel,
//                         icon: Icons.person_2_outlined,
//                       );
//   }
// }


// class UserDetailsPage2 extends StatefulWidget {
//   final Map<String, dynamic> data;
//   const UserDetailsPage2({Key? key, required this.data}) : super(key: key);

//   @override
//   _UserDetailsPage2State createState() => _UserDetailsPage2State();
// }

// class _UserDetailsPage2State extends State<UserDetailsPage2> {
//   RxBool flag = false.obs;
//   TextEditingController usernameController = TextEditingController();
//   TextEditingController dobController = TextEditingController();
//   RxString usernameError = ''.obs;

//   @override
//   void initState() {
//     super.initState();
//     // Autofill fields with Google Sign-In data
//     usernameController.text = (widget.data?['data']?['name']) ?? '';
//     dobController.text = widget.data['data']['dob'] ?? '1970-01-01';
//     // Add listener for real-time username validation
//     usernameController.addListener(validateUsername);
//   }

//   @override
//   void dispose() {
//     usernameController.removeListener(validateUsername);
//     usernameController.dispose();
//     dobController.dispose();
//     super.dispose();
//   }

//   void validateUsername() {
//     String username = usernameController.text;
//     if (username.isEmpty) {
//       usernameError.value = 'Username cannot be empty';
//     } else if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
//       usernameError.value = 'Username must start with a letter';
//     } else if (username.length < 3) {
//       usernameError.value = 'Username must be at least 3 characters';
//     } else {
//       usernameError.value = '';
//     }
//   }

//   void submitDetails() async {
//     String username = usernameController.text;

//     // Validate inputs
//     if (username.isEmpty) {
//       snackBarCalledfail(context, SignupData().emptyUsername,  AppColors.redColor);
//       return;
//     }
//     if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
//       snackBarCalledfail(context, SignupData().invalidUsername,  AppColors.redColor);
//       return;
//     }
//     if (username.length < 3) {
//       snackBarCalledfail(context, SignupData().shortUsername,  AppColors.redColor);
//       return;
//     }
    

//     // Prepare updated data for storeData
//     final updatedData = {
//       'name': username,
//       'email': widget.data['data']['email'],
//       'appleUserId': widget.data['data']['appleUserId'],
//     };


//     flag.value = true;
//     await storeData2(context, updatedData, 'assets/avatar/FRAME-2.svg');
//     flag.value = false;
//   }

//   Future<void> storeData2(
//       context, Map<String, dynamic> data, String avatarUrl) async {
//     String name = data['name'];
//     String email = data['email'];
//        updateDeviceData(deviceData);
//     final response = await postDataApiCall(AuthApiRoutes.signUp, {
//         'name': name,
//         'email': email,
//         'isAppleUser': true,
//         'appleUserId': data['appleUserId'],
//         'authorizationKey':Credentials.Sign_Up_Key,
//         'deviceInfo':deviceData
//       }
//     );

//     try {
//       var data2 = jsonDecode(response.body);
//       bool boolvar = data2['success'];

//       acceptReset.value = false;
//       if (!boolvar) {
//         snackBarCalledfail(context, data2['error']['explanation'],  AppColors.redColor);
//         return;
//       }
//       final body = jsonDecode(response.body);

//       String accessToken = body['data'];
//      await SecureStorageService().setString("accessToken", "Bearer " + accessToken);
//       clearStack(context);
//       Navigator.pushReplacementNamed(context, '/ShareAccountLogin');
//     } catch (e) {
//       snackBarCalledfail(context, SignupData().errorInvalidOtp,  AppColors.redColor);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             padding: EdgeInsets.symmetric(horizontal: AppSizes.p20),
//             child: Column(
//               children: [
               
//                 Padding(
//                   padding:
//                       EdgeInsets.symmetric(vertical: Colorcodes.paddingSize),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextFeildWidgetUnderline(
//                         textEditingController: usernameController,
//                         heading: SignupData().usernameLabel,
//                         keyBoard: TextInputType.name,
//                         lableText: SignupData().usernameSubLabel,
//                         icon: Icons.person_2_outlined,
//                       ),
//                       Obx(() => usernameError.value.isNotEmpty
//                           ? Padding(
//                               padding: EdgeInsets.only(left:AppSizes.p20, top: 5),
//                               child: Text(
//                                 usernameError.value,
//                                 style:
//                                     TextStyle(color:  AppColors.redColor, fontSize: 12),
//                               ),
//                             )
//                           : SizedBox.shrink()),
//                       // TextFeildCalender(
//                       //   textEditingController: dobController,
//                       //   heading: SignupData().dobLabel,
//                       //   keyBoard: TextInputType.datetime,
//                       //   lableText: SignupData().dobSubLabel,
//                       // ),
//                     ],
//                   ),
//                 ),
//                 Center(
//                   child: Container(
//                     width: MediaQuery.of(context).size.width / 1.3,
//                     margin: const EdgeInsets.symmetric(
//                         vertical: AppSizes.p10, horizontal: 10),
//                     padding: EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 30),
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryColor,
//                       borderRadius:
//                           BorderRadius.circular(Colorcodes.borderRadius30),
//                     ),
//                     child: InkWell(
//                       onTap: submitDetails,
//                       child: Obx(() => Center(
//                             child: flag.value
//                                 ? Spinner(
//                                     size: 20,
//                                     color: AppColors.backgroundColor,
//                                   )
//                                 : Text(
//                                     'Submit',
//                                     style: FontManager().getTextStyle(
//                                       context,
//                                       lWeight: FontWeight.bold,
//                                       fontSize: 20,
//                                       color: AppColors.backgroundColor,
//                                     ),
//                                   ),
//                           )),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../Constants/app_styles.dart';
import '../Constants/colorcodes.dart';
import '../Constants/colors.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Constants/font_manager.dart';
import '../Constants/loader.dart';
import '../Utils/signUp.dart';
import '../backed_connections/apiAutomations/curd.dart';
import '../backed_connections/apis_connect.dart';
import '../backed_connections/googlesignin/credentials.dart';
import '../components/textfeild.dart';
import '../finance_screen/Budgets/Budget.dart';
import '../image_service/avatarProfile.dart';
import '../repository/auth_service/login_apis.dart';
import '../repository/clearstack.dart';
import '../routes/route_user_login.dart';
import '../services/secure_storage.dart';
RxBool isValidUser=false.obs;
class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isAppleUser;

  const UserDetailsPage({
    Key? key,
    required this.data,
    this.isAppleUser = false,
  }) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  RxBool loading = false.obs;
  RxBool fg = false.obs;

  TextEditingController usernameController = TextEditingController();
  RxString usernameError = ''.obs;

  @override
  void initState() {
    super.initState();

    isValidUser.value = false;

    usernameController.text =
        (widget.data['data']?['name'] ?? '').replaceAll(' ', '').trim();

    usernameController.addListener(validateUsername);
  }

  @override
  void dispose() {
    usernameController.removeListener(validateUsername);
    usernameController.dispose();
    super.dispose();
  }

  void validateUsername() {
    final username = usernameController.text;

    if (username.isEmpty) {
      usernameError.value = 'Username cannot be empty';
      isValidUser.value = false;
    } else if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
      usernameError.value = 'Username must start with a letter';
      isValidUser.value = false;
    } else if (username.length < 3) {
      usernameError.value = 'Username must be at least 3 characters';
      isValidUser.value = false;
    } else {
      usernameError.value = '';
    }
  }

  Future<void> submitDetails() async {
    final username = usernameController.text;

    if (!isValidUser.value) {
      snackBarCalledfail(context, SignupData().emptyUsernameValid,  AppColors.redColor);
      return;
    }

    loading.value = true;
    fg.value = true;

    final payload = {
      'name': username,
      'email': widget.data['data']['email'] ?? '',
      'authorizationKey': Credentials.Sign_Up_Key,
      'deviceInfo': deviceData,
      if (widget.isAppleUser) ...{
        'isAppleUser': true,
        'appleUserId': widget.data['data']['appleUserId'],
      }
    };

    updateDeviceData(deviceData);

    final response =
        await postDataApiCall(AuthApiRoutes.signUp, payload);

    loading.value = false;
    fg.value = false;

    try {
      final body = jsonDecode(response.body);

      if (!body['success']) {
        snackBarCalledfail(
            context, body['error']['explanation'],  AppColors.redColor);
        return;
      }

      final accessToken = body['data'];
      await SecureStorageService()
          .setString("accessToken", "Bearer $accessToken");

      clearStack(context);
      // Navigator.pushReplacementNamed(context, '/ShareAccountLogin');
      Navigator.pushReplacementNamed(context, '/user_onboarding');
    } catch (e) {
      snackBarCalledfail(context, SignupData().errorInvalidOtp, );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  AvatarProfileImageZero(
                    url: Sign.appSignInimage,
                    width: 14,
                    height: 14,
                  ),
                   SizedBox(height: AppSizes.h24),
                  textStyle(
                    context: context,
                    text: 'What should we call you?',
                    fontsize: 18,
                    fontWeight: FontWeight.w300,
                    c: AppColors.accentColor,
                  ),

                   SizedBox(height: AppSizes.h100),
                    Center(
                      child: Lottie.asset(
                                "assets/splashScreen/username.json",
                                // fit: BoxFit.cover,
                                height: 230,
                               
                                
                              ),
                    ),
         SizedBox(height: AppSizes.h75),

                  /// USERNAME FIELD
                  TextFeildWidgetUnderline(
                    textEditingController: usernameController,
                    heading: SignupData().usernameLabel,
                    keyBoard: TextInputType.name,
                    lableText: SignupData().usernameSubLabel,
                    icon: Icons.person_2_outlined,
                  ),

                  Obx(() => usernameError.value.isNotEmpty
                      ? Padding(
                          padding:
                              const EdgeInsets.only(left:AppSizes.p10, top:AppSizes.p6),
                          child: Text(
                            usernameError.value,
                            style:  TextStyle(
                                color:  AppColors.redColor, fontSize: 12),
                          ),
                        )
                      : const SizedBox.shrink()),

                  SizedBox(height: AppSizes.h20),

                  /// SUBMIT BUTTON
                  Obx(() => Center(
                        child: Container(
                          width:
                              MediaQuery.of(context).size.width / 1.1,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.p12),
                          decoration: BoxDecoration(
                            color: isValidUser.value
                                ? AppColors.primaryColor
                                : AppColors.greyCard,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: isValidUser.value
                                ? submitDetails
                                : null,
                            child: Center(
                              child: loading.value || fg.value
                                  ? Spinner(
                                      size: 20,
                                      
                                    )
                                  : Text(
                                      'Continue',
                                      style: FontManager()
                                          .getTextStyle(
                                        context,
                                        fontSize: 20,
                                        lWeight: FontWeight.bold,
                                        color: AppColors.backgroundColor,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

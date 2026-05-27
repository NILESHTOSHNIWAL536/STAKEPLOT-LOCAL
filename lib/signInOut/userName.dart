import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../Constants/app_styles.dart';
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
import '../routes/route_user_login.dart';
import '../services/secure_storage.dart';

RxBool isValidUser = false.obs;

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
      snackBarCalledfail(
          context, SignupData().emptyUsernameValid, AppColors.redColor);
      return;
    }

    loading.value = true;
    fg.value = true;

    final payload = {
      'name': username,
      'email': widget.data['data']['email'] ?? '',
      'authorizationKey': Credentials.Sign_Up_Key,
      'deviceInfo': deviceData,
      'isGoogleUser': widget.data['data']['isGoogleUser'] ?? false,
      if (widget.isAppleUser) ...{
        'isAppleUser': true,
        'appleUserId': widget.data['data']['appleUserId'],
      }
    };

    updateDeviceData(deviceData);

    final response = await postDataApiCall(AuthApiRoutes.signUp, payload);
    loading.value = false;
    fg.value = false;

    try {
      final body = jsonDecode(response.body);

      if (!body['success']) {
        if (!mounted) return;
        snackBarCalledfail(
            context, body['error']['explanation'], AppColors.redColor);
        return;
      }

      final accessToken = body['data'];
      await SecureStorageService()
          .setString("accessToken", "Bearer $accessToken");

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/referral_code',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      // appLog('Error parsing response: $e');
      snackBarCalledfail(
        context,
        SignupData().errorInvalidOtp,
      );
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

                  TextFeildWidget(
                    textEditingController: usernameController,
                    heading: SignupData().usernameLabel,
                    keyBoard: TextInputType.name,
                    lableText: SignupData().usernameSubLabel,
                    icon: Icons.person_2_outlined,
                  ),

                  SizedBox(height: AppSizes.h20),

                  /// SUBMIT BUTTON
                  Obx(() => Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.1,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.p12),
                          decoration: BoxDecoration(
                            color: isValidUser.value
                                ? AppColors.primaryColor
                                : AppColors.greyCard,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: isValidUser.value ? submitDetails : null,
                            child: Center(
                              child: loading.value || fg.value
                                  ? Spinner(
                                      size: 20,
                                    )
                                  : Text(
                                      'Continue',
                                      style: FontManager().getTextStyle(
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

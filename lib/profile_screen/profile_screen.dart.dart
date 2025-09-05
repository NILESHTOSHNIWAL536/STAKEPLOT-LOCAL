import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/reward.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/edit_Details.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/hiddenTransaction.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/resetPin.dart';
import 'package:flutter_application_code_stakeplot/coupons/rewards_overview.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/webView.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../backed_connections/apiConnect/profileUser.dart';

class ProfileScreenDart extends StatefulWidget {
  const ProfileScreenDart({super.key});

  @override
  State<ProfileScreenDart> createState() => _ProfileScreenDartState();
}

class _ProfileScreenDartState extends State<ProfileScreenDart> {
  @override
  void initState() {
    super.initState();
    getHiddenTransactions(context);
    userController.fetchUserInfo();
  }

  void authenticateUser(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();
    bool isAuthenticated = false;
    try {
      // Check if the device supports biometrics or authentication
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (canCheckBiometrics || isDeviceSupported) {
        // Check if any biometrics are enrolled
        List<BiometricType> availableBiometrics =
            await auth.getAvailableBiometrics();
        if (availableBiometrics.contains(BiometricType.strong) ||
            availableBiometrics.contains(BiometricType.face)) {
          // Specific types of biometrics are available. Use checks like this with caution!
        }

        // Attempt authentication regardless of availableBiometrics to handle face lock
        isAuthenticated = await auth.authenticate(
          localizedReason: ProfileScreenStrings().historyArchivesSubLabel,
          options: const AuthenticationOptions(
            biometricOnly: false, // Allow PIN/password fallback
            stickyAuth: false,
            useErrorDialogs: true,
            sensitiveTransaction: true,
          ),
        );
      } else {
        // Device does not support biometrics or authentication, bypass authentication

        return;
      }
    } catch (e) {
      // Log the error for debugging and show error message
      snackBarCalledfail(
          context, "Authentication failed or canceled. Please try again.");
      return;
    }

    // Only proceed if authentication was successful or bypassed
    if (!isAuthenticated) {
      return; // Stop execution if not authenticated
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HiddenTransactionsScreen(),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    UserController userController = ControllerManagement.userController;
    return Scaffold(
      bottomNavigationBar: SafeArea(child: BottomNavigations(data: 3)),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 5, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarProfile(
                      name: userController.userName.value,
                      width: 8,
                      height: 10,
                      background: userController.avatarBackGround.value,
                      flag: false,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userController.userName.value,
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w600,
                                  color: AppColors.primaryColor)),
                          Obx(() => Container(
                                width: MediaQuery.of(context).size.width / 2.1,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "Score : " +
                                      userController.score.value.toString(),
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: AppColors.bg1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                          // userController.phone.value == "0"
                          //     ? SizedBox.shrink()
                          //     : Text(userController.phone.value,
                          //         style: FontManager().getTextStyle(context,
                          //             lWeight: FontWeight.w400,
                          //             fontSize: 10,
                          //             color: AppColors.bg1)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditDetails()),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                            0.2, // Adjust the multiplier as needed
                        decoration: BoxDecoration(
                            color: AppColors.mt,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: AppColors.primaryColor,
                                size: 24,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              // AvatarProfileImage(
                              //   url: ProfileIcons.edit,
                              //   height: 40,
                              //   width: 40,
                              // ),
                              Text(ProfileScreenStrings().editProfileLabel,
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w600,
                                      //fontSize: MediaQuery.of(context).size.width * 0.04,
                                      fontSize: 16,
                                      color: AppColors.accentColor))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Options list
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 16, right: 16),
                child: Column(children: [
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.mt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 8, 8, 4),
                      child: Column(
                        children: [
                          _buildOption(
                            ProfileImage(url: ProfileIcons.friends),
                            ProfileScreenStrings()
                                .friendsListLabel, // Direct access
                            ProfileScreenStrings()
                                .friendsListSubLabel, // Direct access
                            onTap: () {
                              Navigator.pushNamed(context, '/Friends');
                            },
                          ),
                          Divider(),
                          _buildOption(
                            ProfileImage(url: ProfileIcons.rewards),
                            ProfileScreenStrings().rewards, // Direct access
                            ProfileScreenStrings()
                                .friendsListSubLabel, // Direct access
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RewardsOverview(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.mt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              authenticateUser(context);
                            },
                            child: _buildOption(
                              ProfileImage(url: ProfileIcons.support),
                              ProfileScreenStrings()
                                  .historyArchivesLabel, // Direct access
                              ProfileScreenStrings()
                                  .historyArchivesSubLabel, // Direct access
                            ),
                          ),
                          Divider(),
                          InkWell(
                            onTap: () {
                              WebViewController controller = WebViewController()
                                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                ..loadRequest(Uri.parse(
                                    "https://stakeplot.com/Privacypolicy"));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      WebViewPage(controller: controller),
                                ),
                              );
                            },
                            child: _buildOption(
                              ProfileImage(url: ProfileIcons.terms),
                              ProfileScreenStrings()
                                  .termsConditionsLabel, // Direct access
                              ProfileScreenStrings()
                                  .termsConditionsSubLabel, // Direct access
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Third Container for Log ou
                  // t
                  const SizedBox(
                    height: 10,
                  ),
                  logoutWidget(),
                ]),
              ),
              // Spacer(),
              // logoutWidget(),
            ]),
          ),
        ),
      ),
    );
  }

  Widget logoutWidget() {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            await storeDeviceInfo(context);
            logoutUserFromDevice(context);
          },
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.mt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 14, 14, 14),
              child: _buildOption(
                ProfileImage(url: ProfileIcons.logout),
                ProfileScreenStrings().logoutLabel, // Direct access
                ProfileScreenStrings().logoutSubLabel, // Direct access
                isLogout: true,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            ProfileScreenStrings().appVersionLabel,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(Widget icon, String title, String subtitle,
      {Function()? onTap, bool isLogout = false}) {
    double h = MediaQuery.sizeOf(context).height;
    double w = MediaQuery.sizeOf(context).width;
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.button,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: SizedBox(
          height: 20,
          width: 20,
          child: icon,
        ),
      ),
      title: Text(title,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w500,
              fontSize: h / 52,
              color: AppColors.bg1)),
      subtitle: Text(subtitle,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w400,
              fontSize: h / 72,
              color: AppColors.bg1)),
      onTap: onTap,
    );
  }
}

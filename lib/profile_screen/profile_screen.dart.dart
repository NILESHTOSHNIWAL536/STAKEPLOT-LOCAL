import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/repository/reward_repository.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import 'package:flutter_application_code_stakeplot/image_service/profile.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/edit_user_profile.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/hiddenTransaction.dart';
import 'package:flutter_application_code_stakeplot/coupons/rewards_overview.dart';
import 'package:flutter_application_code_stakeplot/Constants/vibration.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../Constants/core/app_padding_sizes.dart';

class ProfileScreenDart extends StatefulWidget {
  const ProfileScreenDart({super.key});

  @override
  State<ProfileScreenDart> createState() => _ProfileScreenDartState();
}

class _ProfileScreenDartState extends State<ProfileScreenDart> {
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    getHiddenTransactions(context);
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
    final colors = context.appColors;
    return Scaffold(
      bottomNavigationBar: SafeArea(child: BottomNavigations(data: 3)),
      backgroundColor: colors.background,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 5, left: 5, right: AppSizes.p16),
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
                                  color: colors.primary)),
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
                                    color: colors.secondaryText,
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
                        width: MediaQuery.of(context).size.width * 0.2,
                        decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: colors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(ProfileScreenStrings().editProfileLabel,
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: colors.onBackground))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.h20),
              // Options list
              Padding(
                padding: const EdgeInsets.only(
                    top: 5, left: AppSizes.p16, right: AppSizes.p16),
                child: Column(children: [
                  Container(
                    decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border)),
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
                            ProfileScreenStrings()
                                .searchFriendLabel, // Direct access
                            ProfileScreenStrings()
                                .friendsListSubLabel, // Direct access
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TribeSearch(),
                                ),
                              );
                            },
                          ),
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
                  SizedBox(height: AppSizes.h10),
                  Container(
                    decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border)),
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
                              redirectToUrl(context,
                                  "https://stakeplot.com/Privacypolicy");
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
    final colors = context.appColors;
    return Column(
      children: [
        InkWell(
          onTap: () async {
            if (_isLoggingOut) return;

            setState(() {
              _isLoggingOut = true;
            });

            await logoutUserFromDevice(context);

            if (!mounted) return;
            setState(() {
              _isLoggingOut = false;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 14, 14, 14),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _isLoggingOut
                    ? _buildOption(
                        _logoutLoader(),
                        "Logging out...",
                        "Please wait while we secure your session",
                        isLogout: true,
                      )
                    : _buildOption(
                        ProfileImage(url: ProfileIcons.logout),
                        ProfileScreenStrings().logoutLabel, // Direct access
                        ProfileScreenStrings().logoutSubLabel, // Direct access
                        isLogout: true,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppSizes.h20),
        Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            ProfileScreenStrings().appVersionLabel,
            textAlign: TextAlign.center,
            style: FontManager()
                .getTextStyle(context, color: colors.hintText, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _logoutLoader() {
    final colors = context.appColors;

    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.3,
        valueColor: AlwaysStoppedAnimation<Color>(colors.onBackground),
      ),
    );
  }

  Widget _buildOption(Widget icon, String title, String subtitle,
      {Function()? onTap, bool isLogout = false}) {
    final colors = context.appColors;
    double h = MediaQuery.sizeOf(context).height;
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(AppSizes.p12),
        decoration: BoxDecoration(
            color: colors.iconBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border)),
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
              color: colors.onBackground)),
      subtitle: Text(subtitle,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w400,
              fontSize: h / 72,
              color: colors.secondaryText)),
      onTap: onTap,
    );
  }
}

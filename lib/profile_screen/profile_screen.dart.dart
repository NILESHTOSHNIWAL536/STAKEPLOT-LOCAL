import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/NavigatorScreens/userNavigator.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/onboarding_screens/onboarding_screen.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/communityProfileScreen.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/edit_Details.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/hiddenTransaction.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/webView.dart';
import 'package:http/http.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  }

  Future<bool> authenticateUser(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();
    bool isAuthenticated = false;

    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (canCheckBiometrics || isDeviceSupported) {
        isAuthenticated = await auth.authenticate(
          localizedReason: 'Authenticate to view hidden transactions',
          options: const AuthenticationOptions(
            biometricOnly: false, // Allow PIN fallback
            stickyAuth: true,
            useErrorDialogs: true,
            
          ),
        );
      } else {
        snackBarCalledfail(context,
            'Biometric authentication is not available on this device.');
        // Optionally show a message if biometrics are not available
        
      }
    } catch (e) {}

    return isAuthenticated;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      bottomNavigationBar: SafeArea(child: BottomNavigations(data: 3)),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Container(
          // padding: const EdgeInsets.only(top: 5, left: 16, right: 16),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
             
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 5, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarProfile(name: userName.value, width: 8, height: 10,background:userAvatarBackGround.value,flag: false,),
                    const SizedBox(width: 3,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName.value,
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w600,
                                  //fontSize: MediaQuery.of(context).size.width * 0.04,
                                  color: AppColors.primaryColor)),
                          Container(
                            width: MediaQuery.of(context).size.width/2.1,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(email.value,
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w400,
                                    //fontSize: MediaQuery.of(context).size.width * 0.04,
                                    fontSize: 10,
                                    color: AppColors.bg1),overflow: TextOverflow.ellipsis,),
                          ),
                          Text(number.value,
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w400,
                                  //fontSize: MediaQuery.of(context).size.width * 0.04,
                                  fontSize: 10,
                                  color: AppColors.bg1)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditDetails()),
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
                            //mainAxisSize: MainAxisSize.min,
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              AvatarProfileImage(
                                url: ProfileIcons.edit,
                                height: 40,
                                width: 40,
                              ),
                              Text('Edit',
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w600,
                                      //fontSize: MediaQuery.of(context).size.width * 0.04,
                                      fontSize: 12,
                                      color: AppColors.bg1))
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
                  // First Container for Community profile and Friends list
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
                              ProfileImage(
                                url: ProfileIcons.communityProf,
                              ),
                              'Community profile',
                              'Check your community profile', onTap: () {
                            navigatorToMyOwnPage(context);
                          }),
                          Divider(),
                          _buildOption(
                              ProfileImage(
                                url: ProfileIcons.friends,
                                // height: 20,
                                // width: 20,
                              ),
                              'Friends list',
                              'Check your friends list here', onTap: () {
                            Navigator.pushNamed(context, '/Friends');
                          }),
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(height: 10),
                  // Second Container for Support, Terms & conditions, and Privacy policy
            
                  SizedBox(height: 10),
                  // Second Container for Support, Terms & conditions, and Privacy policy
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
                            onTap: () async {
                              bool isAuthenticated =
                                  await authenticateUser(context);
                              if (isAuthenticated) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HiddenTransactionsScreen(),
                                  ),
                                );
                              } else {
                                snackBarCalledfail(context,
                                    'Authentication failed. Please try again.');
                              }
                            },
                            child: _buildOption(
                                ProfileImage(
                                  url: ProfileIcons.support,
                                  // height: 20,
                                  // width: 20,
                                ),
                                'History archives ',
                                'Find your hidden history here'),
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
                                ProfileImage(
                                  url: ProfileIcons.terms,
                                  // height: 20,
                                  // width: 20,
                                ),
                                'Terms & conditions',
                                'Please follow our terms and conditions'),
                          ),
            
                          // InkWell(
                          //   onTap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) =>
                          //             OnboardingScreen(),
                          //       ),
                          //     );
                          //   },
                          //   child: _buildOption(
                          //       ProfileImage(
                          //         url: ProfileIcons.support,
                          //         // height: 20,
                          //         // width: 20,
                          //       ),
                          //       'History archives ',
                          //       'Find your hidden history here'),
                          // ),
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
             await storeDeviceInfo();
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
                  ProfileImage(
                    url: ProfileIcons.logout,
                    // height: 22,
                    // width: 22,
                  ),
                  'Log out',
                  'You can login and log out from your account',
                  isLogout: true),
            ),
          ),
        ),
        SizedBox(height: 20),
        Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            'Stakeplot\nApp version 4.0.0',
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
          child: icon, // Use the passed widget directly
        ),
      ),
      title: Text(title,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w500,
              //fontSize: MediaQuery.of(context).size.width * 0.04,
              fontSize: h / 52,
              color: AppColors.bg1)),
      subtitle: Text(subtitle,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w400,
              //fontSize: MediaQuery.of(context).size.width * 0.04,
              fontSize: h / 72,
              color: AppColors.bg1)),
      //trailing: isLogout ? Icon(Icons.logout, color: Colors.red) : null,
      onTap: onTap,
    );
  }
}

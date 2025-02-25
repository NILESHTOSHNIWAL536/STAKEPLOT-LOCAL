import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/communityProfileScreen.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/edit_Details.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/hiddenTransaction.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/webView.dart';
import 'package:http/http.dart';
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
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      bottomNavigationBar: BottomNavigations(data: 4),
      backgroundColor: AppColors.backgroundColor,
    
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 5, left: 16, right: 16),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section
              Row(
                children: [
                  Container(
                    child: chatAvatartImage( url: avatar.value, width:15, height:17),
                    // backgroundImage: NetworkImage(post['profilePic']),
                    // radius: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName.value,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w600,
                                //fontSize: MediaQuery.of(context).size.width * 0.04,
                                color: AppColors.bg1)),
                        Text(email.value,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w400,
                                //fontSize: MediaQuery.of(context).size.width * 0.04,
                                fontSize: 12,
                                color: AppColors.bg1)),
                        Text(Phone.value,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w400,
                                //fontSize: MediaQuery.of(context).size.width * 0.04,
                                fontSize: 12,
                                color: AppColors.bg1)),
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
                      child: Row(
                        children: [
                          AvatarProfileImage(
                            url: ProfileIcons.edit,
                            height: 60,
                            width: 60,
                          ),
                          Text('Edit details',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w500,
                                  //fontSize: MediaQuery.of(context).size.width * 0.04,
                                  fontSize: 12,
                                  color: AppColors.bg1))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Options list
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: [
                    // First Container for Community profile and Friends list
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.mt,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                        child: Column(
                          children: [
                            _buildOption(
                                AvatarProfileImage(
                                  url: ProfileIcons.communityProf,
                                  height: 24,
                                  width: 24,
                                ),
                                'Community profile',
                                'Check your community profile', onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CommunityProfileScreen( id: currentId.value,)),
                              );
                            }),
                            Divider(),
                            _buildOption(
                                AvatarProfileImage(
                                  url: ProfileIcons.friends,
                                  height: 20,
                                  width: 20,
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
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HiddenTransactionsScreen(),
                                    ),
                                  );
                                },
                                child: _buildOption(
                                    AvatarProfileImage(
                                      url: ProfileIcons.support,
                                      height: 20,
                                      width: 20,
                                    ),
                                    'History archives ',
                                    'Find your hidden history here'),
                              ),
                              Divider(),
                              InkWell(
                                onTap: (){
                                  WebViewController controller  = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted) ..loadRequest(Uri.parse("https://finvu.in/terms"));
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebViewPage(controller: controller),
                                    ),
                                  );
                                },
                                child: _buildOption(
                                    AvatarProfileImage(
                                      url: ProfileIcons.terms,
                                      height: 20,
                                      width: 20,
                                    ),
                                    'Terms & conditions',
                                    'Please follow our terms and conditions'),
                              ),
                              // Divider(),
                              // _buildOption(
                              //     SizedBox(
                              //       height: 40,
                              //       width: 40,
                              //       child: AvatarProfileImage(
                              //         url: ProfileIcons.privacyPolicy,
                              //         height: 22,
                              //         width: 22,
                              //       ),
                              //     ),
                              //     'Privacy policy',
                              //     'We respect your privacy'),
                            ],
                          ),
                        ),
                      ),
                     
                      // Third Container for Log ou
                      // t
                      const SizedBox(height: 10,),
                      logoutWidget(),
                     
                    
                  ]
                ),
              ),
              // Spacer(),
              // logoutWidget(),
  
         ] ),
        ),
      ),
    );
  }


  Widget logoutWidget(){
     return Column(
        children: [
             InkWell(
                          onTap: () async {
                            final SharedPreferences _pref =
                                await SharedPreferences.getInstance();

                            // Remove tokens and other session data
                            await _pref.remove("accessToken");
                            await _pref.remove("token");
                            await _pref.remove("ConsentHandleId");
                            await _pref.remove("consentId");
                            await _pref.remove("from");
                            await _pref.remove("to");
                            await _pref.remove("sessionId");

                            // Navigate back to home screen
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/', (Route<dynamic> route) => false);
                            Navigator.pushReplacementNamed(context, '/');

                            clearGetX();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppColors.mt,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 14, 14, 14),
                              child: _buildOption(
                                  AvatarProfileImage(
                                    url: ProfileIcons.logout,
                                    height: 22,
                                    width: 22,
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
                            'Stakeplot\nApp version 1.0',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
        ],
     );
  }

  Widget _buildOption(Widget icon, String title, String subtitle,
      {Function()? onTap, bool isLogout = false}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.button,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: SizedBox(
          height: 33,
          width: 33,
          child: icon, // Use the passed widget directly
        ),
      ),
      title: Text(title,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w500,
              //fontSize: MediaQuery.of(context).size.width * 0.04,
              fontSize: 15,
              color: AppColors.bg1)),
      subtitle: Text(subtitle,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w400,
              //fontSize: MediaQuery.of(context).size.width * 0.04,
              fontSize: 13,
              color: AppColors.bg1)),
      //trailing: isLogout ? Icon(Icons.logout, color: Colors.red) : null,
      onTap: onTap,
    );
  }
}

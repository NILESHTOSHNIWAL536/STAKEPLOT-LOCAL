import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/communityProfileScreen.dart';

class ProfileScreenDart extends StatefulWidget {
  const ProfileScreenDart({super.key});

  @override
  State<ProfileScreenDart> createState() => _ProfileScreenDartState();
}

class _ProfileScreenDartState extends State<ProfileScreenDart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigations(data: 4),
      backgroundColor: AppColors.backgroundColor,
      // appBar: AppBar(
      //   title: const Text('Profile'),
      //   actions: [
      //     TextButton(
      //       onPressed: () {
      //         // Edit details action
      //       },
      //       child: Text('Edit details',
      //           style: FontManager().getTextStyle(context,
      //               lWeight: FontWeight.w500,
      //               //fontSize: MediaQuery.of(context).size.width * 0.04,
      //               color: AppColors.bg1)),
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://example.com/profile.jpg'), // Replace with actual image URL
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
                  TextButton.icon(
                    icon: AvatarProfileImage(
                      url: ProfileIcons.edit,
                      height: 22,
                      width: 22,
                    ),
                    onPressed: () {},
                    label: Text('Edit details',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w500,
                            //fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontSize: 12,
                            color: AppColors.bg1)),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // Options list
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Expanded(
                  child: Column(
                    children: [
                      // First Container for Community profile and Friends list
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.mt,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 16, 20, 16),
                          child: Column(
                            children: [
                              _buildOption(
                                  AvatarProfileImage(
                                    url: ProfileIcons.communityProf,
                                    height: 22,
                                    width: 22,
                                  ),
                                  'Community profile',
                                  'Check your community profile', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CommunityProfileScreen()),
                                );
                              }),
                              Divider(),
                              _buildOption(
                                  AvatarProfileImage(
                                    url: ProfileIcons.friends,
                                    height: 22,
                                    width: 22,
                                  ),
                                  'Friends list',
                                  'Check your friends list here', onTap: () {
                                Navigator.pushNamed(context, '/Friends');
                              }),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Second Container for Support, Terms & conditions, and Privacy policy
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.mt,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 16, 20, 16),
                          child: Column(
                            children: [
                              _buildOption(
                                  AvatarProfileImage(
                                    url: ProfileIcons.support,
                                    height: 22,
                                    width: 22,
                                  ),
                                  'Support',
                                  'We are available 24x7 on your service'),
                              Divider(),
                              _buildOption(
                                  AvatarProfileImage(
                                    url: ProfileIcons.terms,
                                    height: 22,
                                    width: 22,
                                  ),
                                  'Terms & conditions',
                                  'Please follow our terms and conditions'),
                              Divider(),
                              _buildOption(
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: AvatarProfileImage(
                                      url: ProfileIcons.privacyPolicy,
                                      height: 22,
                                      width: 22,
                                    ),
                                  ),
                                  'Privacy policy',
                                  'We respect your privacy'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Third Container for Log out
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.mt,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 16, 20, 16),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(Widget icon, String title, String subtitle,
      {Function()? onTap, bool isLogout = false}) {
    print('--- _buildOption Debug Info ---');
    print('Icon: $icon');
    print('Title: $title');
    print('Subtitle: ${subtitle ?? "No subtitle"}');
    print('isLogout: $isLogout');
    print(
        'onTap: ${onTap != null ? "Function Provided" : "No Function Provided"}');
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.button,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: SizedBox(
          height: 30,
          width: 30,
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

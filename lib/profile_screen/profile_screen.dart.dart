import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
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
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 10),
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
                  icon: Icon(Icons.edit, color: Colors.blue),
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
            Expanded(
              child: Column(
                children: [
                  // First Container for Community profile and Friends list
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.mt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border)),
                    child: Column(
                      children: [
                        _buildOption(Icons.person, 'Community profile',
                            'Check your community profile', onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CommunityProfileScreen()),
                          );
                        }),
                        Divider(),
                        _buildOption(Icons.group, 'Friends list',
                            'Check your friends list here', onTap: () {
                          Navigator.pushNamed(context, '/Friends');
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Second Container for Support, Terms & conditions, and Privacy policy
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.mt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border)),
                    child: Column(
                      children: [
                        _buildOption(Icons.support, 'Support',
                            'We are available 24x7 on your service'),
                        Divider(),
                        _buildOption(Icons.article, 'Terms & conditions',
                            'Please follow our terms and conditions'),
                        Divider(),
                        _buildOption(Icons.privacy_tip, 'Privacy policy',
                            'We respect your privacy'),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Third Container for Log out
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.mt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border)),
                    child: _buildOption(Icons.logout, 'Log out',
                        'You can login and log out from your account',
                        isLogout: true),
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
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, String subtitle,
      {Function()? onTap, bool isLogout = false}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.mt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w500,
              //fontSize: MediaQuery.of(context).size.width * 0.04,
              fontSize: 16,
              color: AppColors.bg1)),
      subtitle: Text(subtitle,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w400,
              //fontSize: MediaQuery.of(context).size.width * 0.04,
              fontSize: 14,
              color: AppColors.bg1)),
      //trailing: isLogout ? Icon(Icons.logout, color: Colors.red) : null,
      onTap: onTap,
    );
  }
}

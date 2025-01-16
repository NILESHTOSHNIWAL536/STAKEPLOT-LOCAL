import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () {
              // Edit details action
            },
            child: const Text('Edit details',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      'https://example.com/profile.jpg'), // Replace with actual image URL
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      Text(userName.value,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(email.value,
                          style: TextStyle(fontSize: 14)),
                      Text(Phone.value, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                TextButton.icon(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {},
                  label: Text('Edit details',
                      style: TextStyle(color: Colors.blue)),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
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
                            'Check your friends list here',onTap: () {
                              Navigator.pushNamed(context, '/Friends'); 
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Second Container for Support, Terms & conditions, and Privacy policy
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
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
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: isLogout ? Icon(Icons.logout, color: Colors.red) : null,
      onTap: onTap,
    );
  }

}

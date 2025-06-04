import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/communityProfileScreen.dart';

class CommunityUserProfileScreen extends StatefulWidget {
  const CommunityUserProfileScreen({Key? key}) : super(key: key);

  @override
  State<CommunityUserProfileScreen> createState() => _CommunityUserProfileScreenState();
}

class _CommunityUserProfileScreenState extends State<CommunityUserProfileScreen> {
  bool _messageRepliesEnabled = true;
  int _selectedNavIndex = 3; // Profile tab selected

  @override
  void initState() {
    super.initState();
    // Set status bar styl
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(child: BottomNavigations(data: 2)),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none, 
          children: [
            Column(
              children: [
                _buildHeader(),
                
                   Container(
                    height: MediaQuery.sizeOf(context).height/1.24,
                    color: const Color(0xFFC2C3D5),
                    child: Column(
                      children: [
                        const SizedBox(height: 50), // Space for half of the avatar
                        _buildMenuItems(),
                      ],
                    ),
                  
                ),
              ],
            ),
            // Position the AvatarProfile to straddle the boundary
            Positioned(
              top: 16, // Adjust this value based on your header height
              left: 0,
              right: 0,
              child: Center(
                child: AvatarProfile(
                  name: userName.value,
                  width: 4.4,
                  height: 10,
                  background: userAvatarBackGround.value ?? defaultBackGround.value,
                  flag: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildMenuItems() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: (){
                  Navigator.push(
         context,
         MaterialPageRoute(
             builder: (context) =>CommunityProfileScreen( id: currentId.value,)),
       );

              },
              child: _buildMenuItem('View Profile', hasArrow: true)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: (){
      //             Navigator.push(
      //    context,
      //    MaterialPageRoute(
      //        builder: (context) =>CommunityProfileScreen( id: currentId.value,)),
      //  );

              },
              child: _buildMenuItem('Saved', hasArrow: true)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: (){
      //             Navigator.push(
      //    context,
      //    MaterialPageRoute(
      //        builder: (context) =>CommunityProfileScreen( id: currentId.value,)),
      //  );

              },
              child: _buildMenuItem('Update Interest', hasArrow: true)),
            const SizedBox(height: 12),
            _buildMenuItem('Message And Replies', hasToggle: true),
            const SizedBox(height: 12),
            _buildMenuItem('Hide Chat', hasToggle: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, {bool hasArrow = false, bool hasToggle = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
          style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.accentColor)),
          if (hasArrow)
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            )
          else if (hasToggle)
            Switch(
              value: _messageRepliesEnabled,
              onChanged: (value) {
                setState(() {
                  _messageRepliesEnabled = value;
                });
              },
              activeColor: const Color(0xFF4A4A68),
              
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
            ),
        ],
      ),
    );
  }



}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Profile/Saved.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';

import 'package:flutter_application_code_stakeplot/finSpace/updateInterestScreen.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/communityProfileScreen.dart';
import 'package:get/get.dart';

import '../routers_api.dart';

class CommunityUserProfileScreen extends StatefulWidget {
  const CommunityUserProfileScreen({Key? key}) : super(key: key);

  @override
  State<CommunityUserProfileScreen> createState() => _CommunityUserProfileScreenState();
}

class _CommunityUserProfileScreenState extends State<CommunityUserProfileScreen> {

  
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
                    height: MediaQuery.sizeOf(context).height/1.22,
                    color: const Color(0xFFC2C3D5),
                    child: Column(
                      children: [
                         SizedBox(height: MediaQuery.sizeOf(context).height/15), // Space for half of the avatar
                        _buildMenuItems(),
                      ],
                    ),
                  
                ),
              ],
            ),
            // Position the AvatarProfile to straddle the boundary
            Positioned(
              top: MediaQuery.sizeOf(context).height/42, // Adjust this value based on your header height
              left: 0,
              right: 0,
              child: Center(
                child: AvatarProfile2(
                  url: ControllerManagement.userController.avatar.value,
                  width: 7,
                  height: 8,
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
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Container(
         height: MediaQuery.sizeOf(context).height/18,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child:  Icon(
                    Icons.arrow_back,
                    color: AppColors.grey,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  

  Widget _buildMenuItems() {
    return Container(
    
      height: MediaQuery.sizeOf(context).height/2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: (){
                  Navigator.push(
         context,
         MaterialPageRoute(
             builder: (context) =>CommunityProfileScreen( id: userController.userId.value,)),
       );

              },
              child: _buildMenuItem('View Profile', hasArrow: true)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: (){
                  Navigator.push(
         context,
         MaterialPageRoute(
             builder: (context) =>Saved()),
       );

              },
              child: _buildMenuItem('Saved', hasArrow: true)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: (){
                  Navigator.push(
         context,
         MaterialPageRoute(
             builder: (context) =>UpdateInterestScreen()),
       );

              },
              child: _buildMenuItem('Update Interest', hasArrow: true)),
            const SizedBox(height: 12),
            _buildMenuItem('Message And Replies', hasToggle: true),
           
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
              Icons.arrow_forward,
              size: 18,
              color: Colors.grey,
            )
          else if (hasToggle)
            Container(
              height: 20,
              width: 30,
              child:Obx(()=> Transform.scale(
                scale: 0.7,
                child:Switch(
                value: canMessageUser.value,
                onChanged: (value)async {
                   canMessageUser.value=value;

               try{
                  var body = {
                        "canMaskMessage": canMessageUser.value,
                  };
                   await updateDataApiCall2(UserRoutes.update, body);
                }catch(e){
                  
                }

                },
                // padding: EdgeInsets.zero,
                activeColor: const Color(0xFF4A4A68),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              )),),
            )
        ],
      ),
    );
  }



}

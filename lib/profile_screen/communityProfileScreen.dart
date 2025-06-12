import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Profile/friends.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';

import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

import 'package:flutter_application_code_stakeplot/profile_screen/tabBarUser.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CommunityProfileScreen extends StatefulWidget {
  String id;
  CommunityProfileScreen({super.key, required this.id});

  @override
  State<CommunityProfileScreen> createState() => _CommunityProfileScreenState();
}

class _CommunityProfileScreenState extends State<CommunityProfileScreen> {
  File? _profileImage;
  File? _coverImage;

  
  String _networkImageUrl =
      "https://static.vecteezy.com/system/resources/thumbnails/045/713/367/small_2x/aesthetic-leaves-on-a-dark-background-free-photo.jpg"; // This can be dynamically set

  Future<void> _pickImage(ImageSource source, String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (type == "profile") {
          _profileImage = File(pickedFile.path);
        } else {
          _coverImage = File(pickedFile.path);
        }
      });
    }
  }

  @override
  void initState()
   {
    getuserPost(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              topUserProfile(),

    
              Column(
                children: [
                 const SizedBox(height: 10),
                      TabBarUser(userPostList: myPostList)
                ],
              ),
             
            ],
          ),
        ),
      ),
    );
  }

 
 Widget topUserProfile() {
    return 
         Container(
            height: MediaQuery.of(context).size.height / 5.4,
            // height: 200,
           child: Column(
            children: [
               AvatarProfile(name: userName.value, width: 4.4, height: 10,background:userAvatarBackGround.value ?? defaultBackGround.value,flag: true,),
           Text(userName.value.toString(),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w600, color: AppColors.bg1)),
                          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                networkFriends(
                     ProfileScreenStrings().postsLabel, myPostList.length.toString(), Icons.post_add),
                     InkWell(
                      onTap: (){
                           Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>Friends(isMasked: true,),
                                  ),
                           );
                      },
                       child: networkFriends( ProfileScreenStrings().networkLabel, MaskedFriendsList.length.toString(),
                                           Icons.person_2_outlined),
                     ),
              ],
            ),
          ),
        
            ],
           ),
          );
       
    
  }

  Widget networkFriends(String network, String count, IconData icon) {
    return Container(
      width: MediaQuery.sizeOf(context).width/2.4,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryColor, width: .5),
          
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           
            textStyle(
                context: context,
                text: count.toString(),
                fontWeight: FontWeight.w500,
                c: AppColors.finSpaceColor,
                fontsize: 16),
                 const SizedBox(
      width: 5,
    ),
                 textStyle(
        context: context,
        text: network.toString(),
        fontWeight: FontWeight.w400,
        c: AppColors.finSpaceColor,
        fontsize: 16),
          ],
        ));
  }
}

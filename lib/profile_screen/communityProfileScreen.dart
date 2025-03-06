import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/tabBarUser.dart';
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

  final dummyData = {
    "name": "Rohit Sharma",
    "username": "@rohit45_",
    "posts": "Posts Content",
    "polls": "Polls Content",
    "exploria": "Exploria Content"
  };
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
          
            topUserProfile(),
    
            const SizedBox(height: 60),
    
            Column(
              children: [
                Text(userName.value.toString(),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w600, color: AppColors.bg1)),
               
                        const SizedBox(height: 10),
                   TabBarUser(userPostList: myPostList)
              ],
            ),
           
          ],
        ),
      ),
    );
  }

 
  Widget topUserProfile() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Positioned button to edit cover image
        Positioned(
          top: 20,
          right: 16,
          child: TextButton.icon(
            onPressed: () {
              // _pickImage(ImageSource.gallery, "cover");
            },
            label: const Text(
              'Edit cover',
              style: TextStyle(color: AppColors.bg1),
            ),
            icon: const Icon(Icons.edit),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Add the action to be triggered on tap, like picking an image
          },
          child: Container(
            height: MediaQuery.of(context).size.height / 6,
            // height: 200,
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              image: _coverImage != null
                  ? DecorationImage(
                      image: FileImage(_coverImage!),
                      fit: BoxFit.cover,
                    )
                  : _networkImageUrl != null && _networkImageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(_networkImageUrl),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage(
                              'assets/cover_placeholder.jpg'), // Default placeholder asset
                          fit: BoxFit.cover,
                        ),
            ),
          ),
        ),

        Positioned(
          top: 140,
          left: MediaQuery.of(context).size.width / 6.7,
          child: networkFriends("Network", friendsList.length.toString(),
              Icons.person_2_outlined),
        ),

        Positioned(
          top: 140,
          left: MediaQuery.of(context).size.width / 1.45,
          child: networkFriends(
              "Posts", myPostList.length.toString(), Icons.post_add),
        ),

        Positioned(
          top: 80,
          left: MediaQuery.of(context).size.width / 2 - 50,
          child: GestureDetector(
            // onTap: () => _pickImage(ImageSource.gallery, "profile"),
            child: CircleAvatar(
              radius: 50,
              child: ProfileImage(url: avatar.value),
            ),
          ),
        ),
      ],
    );
  }

  Widget networkFriends(String network, String count, IconData icon) {
    return Column(
      children: [
        Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryColor, width: .5),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                ),
                textStyle(
                    context: context,
                    text: count.toString(),
                    fontWeight: FontWeight.bold,
                    fontsize: 12),
              ],
            )),
        const SizedBox(
          height: 5,
        ),
        textStyle(
            context: context,
            text: network.toString(),
            fontWeight: FontWeight.w400,
            fontsize: 12),
      ],
    );
  }
}

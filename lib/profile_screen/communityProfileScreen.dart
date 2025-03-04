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
  void initState() {
    getuserPost(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg5,
      // bottomNavigationBar: BottomNavigations(data: 4),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            // Top Cover and Profile Picture
            topUserProfile(),

            const SizedBox(height: 60),

            Column(
              children: [
                Text(userName.value.toString(),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w600, color: AppColors.bg1)),
                Text(email.value.toString(),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w400,
                        //fontSize: MediaQuery.of(context).size.width * 0.04,
                        //fontSize: 12,
                        color: AppColors.userName)),
                        const SizedBox(height: 10),
                DefaultTabController(
                  length: 2, // Number of tabs
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TabBar(
                          indicatorPadding:
                              EdgeInsets.zero, // Ensures no extra spacing
                          labelPadding:
                              EdgeInsets.zero, // Controls padding inside tabs
                          indicator: BoxDecoration(
                            color: AppColors.tab, // Background for selected tab
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: AppColors
                              .primaryColor, // Text color for selected tab
                          unselectedLabelColor:
                              AppColors.bg1, // Text color for unselected tabs
                          indicatorSize: TabBarIndicatorSize
                              .tab, // Indicator fills the tab
                          tabs: [
                            Tab(
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4), // Adjusted for smaller size
                                decoration: BoxDecoration(
                                  color: Colors
                                      .transparent, // No background when unselected
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Posts',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                            Tab(
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4), // Smaller padding
                                decoration: BoxDecoration(
                                  color: Colors
                                      .transparent, // No background when unselected
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Polls',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 1.67,
                        // Adjust as needed for TabBarView
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 12.0),
                          child: TabBarView(
                            children: [
                              Center(child: feedWidgets("post")),
                              Center(child: pollWidgets("poll")),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget feedWidgets(String type) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: Column(
              children: myPostList
                  .map((item) => (item['isPoll'] ?? false)
                      ? const SizedBox.shrink()
                      : PostCard(data: item))
                  .toList(),
            ),
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget pollWidgets(String type) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
              child: Wrap(
                  children: myPostList
                      .map((item) => (item['isPoll'] ?? false)
                          ? PostCard(data: item)
                          : SizedBox.shrink())
                      .toList())),
          SizedBox(
            height: 100,
          ),
        ],
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

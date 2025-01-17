import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CommunityProfileScreen extends StatefulWidget {
  const CommunityProfileScreen({super.key});

  @override
  State<CommunityProfileScreen> createState() => _CommunityProfileScreenState();
}

class _CommunityProfileScreenState extends State<CommunityProfileScreen> {
  File? _profileImage;
  File? _coverImage;

  final dummyData = {
    "name": "Rohit Sharma",
    "username": "@rohit45_",
    "followers": 400,
    "following": 1100,
    "posts": "Posts Content",
    "polls": "Polls Content",
    "exploria": "Exploria Content"
  };

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg5,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top Cover and Profile Picture
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Positioned button to edit cover image
                    Positioned(
                      top: 20,
                      right: 16,
                      child: TextButton.icon(
                        onPressed: () {
                          _pickImage(ImageSource.gallery, "cover");
                        },
                        label: const Text(
                          'Edit cover',
                          style: TextStyle(color: AppColors.bg1),
                        ),
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          image: _coverImage != null
                              ? DecorationImage(
                                  image: FileImage(_coverImage!),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: AssetImage(
                                      'assets/cover_placeholder.jpg'), // Optional placeholder
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 140,
                      left: MediaQuery.of(context).size.width / 2 - 50,
                      child: GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery, "profile"),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : const AssetImage(
                                      'assets/profile_placeholder.jpg')
                                  as ImageProvider,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                // User Details
                Column(
                  children: [
                    Text(dummyData['name'].toString(),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w600,
                            //fontSize: MediaQuery.of(context).size.width * 0.04,
                            //fontSize: 12,
                            color: AppColors.bg1)),
                    Text(dummyData['username'].toString(),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w400,
                            //fontSize: MediaQuery.of(context).size.width * 0.04,
                            //fontSize: 12,
                            color: AppColors.userName)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                dummyData['followers'].toString(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'Followers',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(width: 40),
                          Column(
                            children: [
                              Text(
                                dummyData['following'].toString(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'Following',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Tabs Section with TabController
                    DefaultTabController(
                      length: 3, // Number of tabs
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(

                                  //color: Colors.green,
                                  border: Border.all(color: AppColors.border),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16))),
                              child: TabBar(
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      16), // Rounded corners
                                  color: AppColors.tab,
                                ),
                                // Padding for labels
                                labelColor: AppColors
                                    .primaryColor, // Text color for selected tab
                                unselectedLabelColor: AppColors
                                    .bg1, // Text color for unselected tabs

                                tabs: [
                                  Tab(child: Text('Posts')),
                                  Tab(text: 'Polls'),
                                  Tab(text: 'Exploria'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 300, // Adjust as needed for TabBarView
                            child: TabBarView(
                              children: [
                                Center(child: feedWidgets("post")),
                                Center(child: pollWidgets("poll")),
                                Center(
                                    child:
                                        Text(dummyData['exploria'].toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // DefaultTabController(
                    //   length: 3,
                    //   child: Column(
                    //     children: [
                    //       Container(
                    //         color: Colors
                    //             .grey[200], // Background color for the TabBar
                    //         child: TabBar(
                    //           indicator: BoxDecoration(
                    //             borderRadius: BorderRadius.circular(
                    //                 30), // Rounded corners
                    //             color: Colors
                    //                 .blue, // Selected tab background color
                    //           ),
                    //           labelColor:
                    //               Colors.white, // Text color for selected tab
                    //           unselectedLabelColor: Colors
                    //               .black, // Text color for unselected tabs
                    //           labelStyle: TextStyle(
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 16,
                    //           ),
                    //           unselectedLabelStyle: TextStyle(
                    //             fontWeight: FontWeight.normal,
                    //             fontSize: 14,
                    //           ),
                    //           tabs: const [
                    //             Tab(text: 'Posts'),
                    //             Tab(text: 'Polls'),
                    //             Tab(text: 'Exploria'),
                    //           ],
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: TabBarView(
                    //           children: [
                    //             Center(child: feedWidgets("post")),
                    //             Center(child: pollWidgets("poll")),
                    //             Center(
                    //                 child:
                    //                     Text(dummyData['exploria'].toString())),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // )
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget feedWidgets(String type) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Wrap(
                children: myPostList
                    .map((item) => (item['isPoll'] ?? false)
                        ? SizedBox.shrink()
                        : PostCard(data: item))
                    .toList(),
              ),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget pollWidgets(String type) {
    return Expanded(
      child: SingleChildScrollView(
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
      ),
    );
  }
}

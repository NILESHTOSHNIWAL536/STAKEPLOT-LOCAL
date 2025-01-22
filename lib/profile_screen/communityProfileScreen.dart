// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';

// class CommunityProfileScreen extends StatefulWidget {
//   const CommunityProfileScreen({super.key});

//   @override
//   State<CommunityProfileScreen> createState() => _CommunityProfileScreenState();
// }

// class _CommunityProfileScreenState extends State<CommunityProfileScreen> {
//   File? _profileImage;
//   File? _coverImage;

//   final dummyData = {
//     "name": "Rohit Sharma",
//     "username": "@rohit45_",
//     "posts": "Posts Content",
//     "polls": "Polls Content",
//     "exploria": "Exploria Content"
//   };
//   String _networkImageUrl =
//       "https://static.vecteezy.com/system/resources/thumbnails/045/713/367/small_2x/aesthetic-leaves-on-a-dark-background-free-photo.jpg"; // This can be dynamically set

//   Future<void> _pickImage(ImageSource source, String type) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         if (type == "profile") {
//           _profileImage = File(pickedFile.path);
//         } else {
//           _coverImage = File(pickedFile.path);
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bg5,
//       bottomNavigationBar: BottomNavigations(data: 4),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // Top Cover and Profile Picture
//               Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   // Positioned button to edit cover image
//                   Positioned(
//                     top: 20,
//                     right: 16,
//                     child: TextButton.icon(
//                       onPressed: () {
//                         _pickImage(ImageSource.gallery, "cover");
//                       },
//                       label: const Text(
//                         'Edit cover',
//                         style: TextStyle(color: AppColors.bg1),
//                       ),
//                       icon: const Icon(Icons.edit),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       // Add the action to be triggered on tap, like picking an image
//                     },
//                     child: Container(
//                       height: 200,
//                       decoration: BoxDecoration(
//                         color: Colors.lightBlueAccent,
//                         image: _coverImage != null
//                             ? DecorationImage(
//                                 image: FileImage(_coverImage!),
//                                 fit: BoxFit.cover,
//                               )
//                             : _networkImageUrl != null &&
//                                     _networkImageUrl.isNotEmpty
//                                 ? DecorationImage(
//                                     image: NetworkImage(_networkImageUrl),
//                                     fit: BoxFit.cover,
//                                   )
//                                 : const DecorationImage(
//                                     image: AssetImage(
//                                         'assets/cover_placeholder.jpg'), // Default placeholder asset
//                                     fit: BoxFit.cover,
//                                   ),
//                       ),
//                     ),
//                   ),

//                   Positioned(
//                     top: 140,
//                     left: MediaQuery.of(context).size.width / 2 - 50,
//                     child: GestureDetector(
//                       onTap: () => _pickImage(ImageSource.gallery, "profile"),
//                       child: CircleAvatar(
//                         radius: 50,
//                         backgroundImage: _profileImage != null
//                             ? FileImage(_profileImage!)
//                             : const AssetImage('assets/profile_placeholder.jpg')
//                                 as ImageProvider,
//                         child: _profileImage == null
//                             ? const Icon(
//                                 Icons.camera_alt,
//                                 size: 30,
//                                 color: Colors.white,
//                               )
//                             : null,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 60),
//               // User Details
//               Column(
//                 children: [
//                   Text(dummyData['name'].toString(),
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.w600,
//                           //fontSize: MediaQuery.of(context).size.width * 0.04,
//                           //fontSize: 12,
//                           color: AppColors.bg1)),
//                   Text(dummyData['username'].toString(),
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.w400,
//                           //fontSize: MediaQuery.of(context).size.width * 0.04,
//                           //fontSize: 12,
//                           color: AppColors.userName)),
//                   // Padding(
//                   //   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                   //   child: Row(
//                   //     mainAxisAlignment: MainAxisAlignment.center,
//                   //     children: [
//                   //       // Column(
//                   //       //   children: [
//                   //       //     Text(
//                   //       //       dummyData['followers'].toString(),
//                   //       //       style: const TextStyle(
//                   //       //           fontSize: 18, fontWeight: FontWeight.bold),
//                   //       //     ),
//                   //       //     const Text(
//                   //       //       'Followers',
//                   //       //       style: TextStyle(color: Colors.grey),
//                   //       //     ),
//                   //       //   ],
//                   //       // ),
//                   //       const SizedBox(width: 40),
//                   //       // Column(
//                   //       //   children: [
//                   //       //     Text(
//                   //       //       dummyData['following'].toString(),
//                   //       //       style: const TextStyle(
//                   //       //           fontSize: 18, fontWeight: FontWeight.bold),
//                   //       //     ),
//                   //       //     const Text(
//                   //       //       'Following',
//                   //       //       style: TextStyle(color: Colors.grey),
//                   //       //     ),
//                   //       //   ],
//                   //       // ),
//                   //     ],
//                   //   ),
//                   // ),
//                   // Tabs Section with TabController
//                   DefaultTabController(
//                     length: 3, // Number of tabs
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
//                           child: DecoratedBox(
//                             decoration:const  BoxDecoration(

//                                 ),
//                             child: TabBar(
//                               indicator: BoxDecoration(
//                                  // Rounded corners

//                                 color: AppColors.tab,

//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               // Padding for labels
//                               labelColor: AppColors
//                                   .primaryColor, // Text color for selected tab
//                               unselectedLabelColor: AppColors
//                                   .bg1, // Text color for unselected tabs

//                               tabs: const[
//                                 Tab(child: Text('Posts')),
//                                 Tab(text: 'Polls'),
//                                 Tab(text: 'Exploria'),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 800, // Adjust as needed for TabBarView
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: TabBarView(
//                               children: [
//                                 Center(child: feedWidgets("post")),
//                                 Center(child: pollWidgets("poll")),
//                                 Center(
//                                     child:
//                                         Text(dummyData['exploria'].toString())),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // DefaultTabController(
//                   //   length: 3,
//                   //   child: Column(
//                   //     children: [
//                   //       Container(
//                   //         color: Colors
//                   //             .grey[200], // Background color for the TabBar
//                   //         child: TabBar(
//                   //           indicator: BoxDecoration(
//                   //             borderRadius: BorderRadius.circular(
//                   //                 30), // Rounded corners
//                   //             color: Colors
//                   //                 .blue, // Selected tab background color
//                   //           ),
//                   //           labelColor:
//                   //               Colors.white, // Text color for selected tab
//                   //           unselectedLabelColor: Colors
//                   //               .black, // Text color for unselected tabs
//                   //           labelStyle: TextStyle(
//                   //             fontWeight: FontWeight.bold,
//                   //             fontSize: 16,
//                   //           ),
//                   //           unselectedLabelStyle: TextStyle(
//                   //             fontWeight: FontWeight.normal,
//                   //             fontSize: 14,
//                   //           ),
//                   //           tabs: const [
//                   //             Tab(text: 'Posts'),
//                   //             Tab(text: 'Polls'),
//                   //             Tab(text: 'Exploria'),
//                   //           ],
//                   //         ),
//                   //       ),
//                   //       Expanded(
//                   //         child: TabBarView(
//                   //           children: [
//                   //             Center(child: feedWidgets("post")),
//                   //             Center(child: pollWidgets("poll")),
//                   //             Center(
//                   //                 child:
//                   //                     Text(dummyData['exploria'].toString())),
//                   //           ],
//                   //         ),
//                   //       ),
//                   //     ],
//                   //   ),
//                   // )
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget feedWidgets(String type) {
//     return Expanded(
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               child: Wrap(
//                 children: myPostList
//                     .map((item) => (item['isPoll'] ?? false)
//                         ? const SizedBox.shrink()
//                         : PostCard(data: item))
//                     .toList(),
//               ),
//             ),
//             SizedBox(
//               height: 100,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget pollWidgets(String type) {
//     return Expanded(
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//                 child: Wrap(
//                     children: myPostList
//                         .map((item) => (item['isPoll'] ?? false)
//                             ? PostCard(data: item)
//                             : SizedBox.shrink())
//                         .toList())),
//             SizedBox(
//               height: 100,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
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

  final String _networkImageUrl =
      "https://static.vecteezy.com/system/resources/thumbnails/045/713/367/small_2x/aesthetic-leaves-on-a-dark-background-free-photo.jpg"; // Sample URL for cover image

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
      bottomNavigationBar: BottomNavigations(data: 4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 60),
            _buildUserDetails(),
            const SizedBox(height: 20),
            _buildTabs(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover image container
        _buildCoverImage(),
        // Profile image
        _buildProfileImage(),
        // Edit cover button
        Positioned(
          top: 20,
          right: 16,
          child: TextButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery, "cover"),
            label: const Text('Edit cover',
                style: TextStyle(color: AppColors.bg1)),
            icon: const Icon(Icons.edit),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImage() {
    return GestureDetector(
      onTap: () {
        // Add the action to be triggered on tap, like picking an image
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          image: _coverImage != null
              ? DecorationImage(
                  image: FileImage(_coverImage!), fit: BoxFit.cover)
              : DecorationImage(
                  image: NetworkImage(_networkImageUrl),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Positioned(
      top: 140,
      left: MediaQuery.of(context).size.width / 2 - 50,
      child: GestureDetector(
        onTap: () => _pickImage(ImageSource.gallery, "profile"),
        child: CircleAvatar(
          radius: 50,
          backgroundImage: _profileImage != null
              ? FileImage(_profileImage!)
              : const AssetImage('assets/profile_placeholder.jpg')
                  as ImageProvider,
          child: _profileImage == null
              ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  Widget _buildUserDetails() {
    return Column(
      children: [
        Text(
          "Rohit Sharma", // Placeholder for name
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w600, color: AppColors.bg1),
        ),
        Text(
          "@rohit45_", // Placeholder for username
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w400, color: AppColors.userName),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildTabBar(),
          _buildTabBarView(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: TabBar(
        indicator: BoxDecoration(
          color: AppColors.tab,
          borderRadius: BorderRadius.circular(16),
        ),
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.bg1,
        tabs: const [
          Tab(child: Text('Posts')),
          Tab(text: 'Polls'),
          Tab(text: 'Exploria'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: 800, // Adjust as needed for TabBarView
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TabBarView(
          children: [
            Center(child: feedWidgets("post")),
            Center(child: pollWidgets("poll")),
            Center(
                child: Text(
                    "Exploria Content")), // Placeholder for exploria content
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
            child: Wrap(
              children: myPostList
                  .map((item) => (item['isPoll'] ?? false)
                      ? SizedBox.shrink()
                      : PostCard(data: item))
                  .toList(),
            ),
          ),
          const SizedBox(height: 100),
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
                  .toList(),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

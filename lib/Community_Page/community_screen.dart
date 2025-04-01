import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'package:flutter_application_code_stakeplot/Community_Page/community_showmodal_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/explore_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postLoad.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/text_screen.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Ensure image_picker is added in pubspec.yaml
import 'dart:io';
import 'package:flutter_application_code_stakeplot/Community_Page/poll_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/image_screen.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class Community extends StatefulWidget {
  const Community({Key? key}) : super(key: key);

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final List<Map<String, dynamic>> posts = [];

  String? selectedImage;
  String CurrentUser = 'user1';

  final ImagePicker _picker = ImagePicker(); // Initialize the ImagePicker
  final TextEditingController _searchController = TextEditingController();
  int likeCount = 0; // Counter for likes
  bool isLiked = false;
 

  @override
  void initState() {
        getPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: BottomNavigations(data: 2),
      body: SafeArea(
        child: Container(
          
          height: MediaQuery.of(context).size.height/1.1,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            controller: scrollControllerPost,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _buildWelcomeRow(),
                ),
                  
                Obx(
                  () => getTrendingData.length == 0 && findTranding
                      ? Loader()
                      : !findTranding && getTrendingData.length == 0
                          ? noFriend(context, "Make friends to see their posts")
                          : Obx(() => getPosted.value
                              ? LazyLoadingList()
                              : LazyLoadingList()),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget getPostListview() {
     double width = MediaQuery.of(context).size.width;
    //  double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      // height:  height,
      child: ListView.builder(
        padding: EdgeInsets.zero, 
        itemCount: getTrendingData.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final dataObj = getTrendingData[index];
          return PostCard(data: dataObj);
        },
      ));

}

  Widget _buildWelcomeRow() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome back to',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.normal,
                      fontSize: h / 46,
                      color: Colors.black),
                ),
                Text(
                  'Financial Community',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: h / 40,
                      color: Colors.black),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  Container(
                      width: MediaQuery.sizeOf(context).width / 7,
                      height: MediaQuery.sizeOf(context).width / 7,
                      decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(18)),
                      child: GestureDetector(
                        onTap: () async {
                          await showModal({});
                        },
                        child: AvatarProfileImage(
                          url: LikeComment.plus,
                          height: 22,
                          width: 22,
                        ),
                      )),
                  
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: w / 0.8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Hero(
                tag: "TribeSearch",
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/TribeSearch');
                  },
                  child: Container(
                    width: MediaQuery.sizeOf(context).width / 1.45,
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        filled: true,
                        enabled: false,
                        hintText: 'Search...',
                        fillColor: AppColors.button,
                        hintStyle: FontManager().getTextStyle(context,
                            lWeight: FontWeight.normal,
                            fontSize: 14,
                            color: Colors.black),
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/TribeChats');
                },
                child: AvatarProfileImage(
                  url: LikeComment.message,
                  height: 22,
                  width: 22,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Featured Posts',
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
      ],
    );
  }

  // This is the modal function where we allow the user to pick an image
  Future<void> showModal(Map<String, dynamic> post) async {
    TextEditingController textController = TextEditingController();
    TextEditingController textController2 = TextEditingController();
    File? pickedImage;
    int k = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // Calculate responsive padding based on screen width
        final double horizontalPadding =
            MediaQuery.of(context).size.width * 0.04;
        final double verticalPadding =
            MediaQuery.of(context).size.height * 0.02;

        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  0.9, // Limit height to 90% of screen
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: horizontalPadding / 2),
                    child: Text(
                      'Create Post',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width *
                            0.05, // Responsive font size
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
                  SizedBox(height: verticalPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOptionButton(
                        context: context,
                        icon: Icons.text_fields,
                        label: 'Text',
                        onTap: () {
                          posting.value = false;
                          Navigator.of(context).pop();
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return TextScreen(
                                userInfo: post,
                                onPostCreated: (newPost) {
                                  setState(() {
                                    posts.add(newPost);
                                    k = 1;
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                      _buildOptionButton(
                        context: context,
                        icon: Icons.image_rounded,
                        label: 'Image',
                        onTap: () {
                          posting.value = false;
                          Navigator.of(context).pop();
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return ImageScreen(
                                userInfo: post,
                                onPostCreated: (newPost) {
                                  setState(() {
                                    posts.add(newPost);
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                      _buildOptionButton(
                        context: context,
                        icon: Icons.poll_outlined,
                        label: 'Poll',
                        onTap: () {
                          posting.value = false;
                          Navigator.of(context).pop();
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return Container(
                                padding: const EdgeInsets.all(16.0),
                                width: MediaQuery.sizeOf(context).width,
                                child: PollScreen(
                                  userInfo: post,
                                  onPollPosted: (pollData) {
                                    setState(() {
                                      posts.add(pollData);
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: verticalPadding),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return Container(
                            child: ExploreModal(
                              onPostCreated: (newPost) {
                                setState(() {
                                  posts.add(newPost);
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                          horizontal: horizontalPadding / 2),
                      padding: EdgeInsets.symmetric(
                        vertical: verticalPadding,
                        horizontal: horizontalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.explore,
                            color: AppColors.primaryColor,
                            size: MediaQuery.of(context).size.width *
                                0.06, // Responsive icon size
                          ),
                          SizedBox(width: horizontalPadding / 2),
                          Flexible(
                            child: Text(
                              'Exploria',
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: MediaQuery.of(context).size.width *
                                    0.045, // Responsive font size
                                color: AppColors.accentColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: verticalPadding),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Helper method to build option buttons
  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final double iconSize =
        MediaQuery.of(context).size.width * 0.07; // Responsive icon size
    final double fontSize =
        MediaQuery.of(context).size.width * 0.04; // Responsive font size

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                EdgeInsets.all(iconSize * 0.3), // Padding scales with icon size
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.25),
            child: Text(
              label,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: fontSize,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    if (post['postType'] == 'polled') {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          // Adjust the value for desired radius
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/50'),
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 8),
                  Text(post['name'],
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black)),
                ],
              ),
              const SizedBox(height: 8),

              // Poll question
              Text(post['question'],
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black)),
              const SizedBox(height: 16),

              // Poll widget using flutter_polls
              FlutterPolls(
                pollId: post['pollId'], // Unique poll ID
                // pollTitle: Text(
                //   post['question'],
                //   style: const TextStyle(
                //     fontSize: 16.0,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),

                pollTitle: Align(
                  alignment: Alignment.topLeft,
                  //Text('dgfhj'),
                ),

                pollOptions: (post['options'] as List<String>).map((option) {
                  final totalVotes = (post['votes'].values as Iterable<int>)
                      .fold<int>(0, (int a, int b) => a + b);
                  final optionVotes = post['votes'][option] as int;

                  return PollOption(
                    title: Text(option,
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.normal,
                            fontSize: 16,
                            color: Colors.black)),
                    votes: optionVotes,
                  );
                }).toList(),
                hasVoted: false, // Update this logic to track user votes
                onVoted: (PollOption option, int optionIndex) async {
                  // Update votes dynamically
                  final selectedOption = post['options'][optionIndex];
                  post['votes'][selectedOption] =
                      (post['votes'][selectedOption] ?? 0) + 1;

                  // Trigger a UI rebuild
                  (context as Element).markNeedsBuild();

                  return true; // Return true to indicate vote was successful
                },
                // Handle logic for user-selected option
                heightBetweenTitleAndOptions: 20,
                // Optional customization
              ),

              const SizedBox(height: 16),
              _buildPostActions(post),
            ],
          ),
        ),
      );
    }

    if (post['contentType'] == 'Exploria') {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          // Adjust the value for desired radius
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10, // Size of the profile picture
                        backgroundImage: NetworkImage(
                            'https://via.placeholder.com/50'), // Profile picture URL
                        backgroundColor: Colors
                            .grey[300], // Fallback color if image fails to load
                      ),
                      Text(post['name'],
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black)),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              if (selectedImage != null) Image.network(selectedImage!),
              if (selectedImage == null)
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text('Place:',
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black)),
                        Text('${post['locationName']}',
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text('Location:',
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black)),
                        Text('${post['locationAddress']}',
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    'Budget',
                    style: FontManager().getTextStyle(
            
                    context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '(Per Day)',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0), // Space below the title
              Wrap(
                spacing: 8.0, // Space between items horizontally
                runSpacing: 8.0, // Space between rows of items
                children: List.generate(post['budgetItems'].length, (index) {
                  final budgetItem = post['budgetItems'][index];
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ), // Optional padding
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Background color
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                    child: Text(
                      '${budgetItem['description']} ${budgetItem['amount']}',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  );
                }),
              ),

              //Text('${post['amount']}'),
              // Text('${post['description']} ${post['amount']}'),

              SizedBox(
                height: 10,
              ),
              Text('Trip Highlights',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black)),
              SizedBox(
                height: 10,
              ),

              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 4.0), // Optional padding
                decoration: BoxDecoration(
                  color: Colors.grey, // Background color
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),

                child: Text('${post['title']}',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black)),
              ),
              //Text('${post['title']}'),
              SizedBox(
                height: 10,
              ),
              Text('Description',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black)),
              Text('${post['content']}',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.normal,
                    fontSize: 16,
                  )),

              SizedBox(
                height: 10,
              ),
              _buildPostActions(post)
            ],
          ),
        ),
      );
    }

    return Card(
      //margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        // Adjust the value for desired radius
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            _buildPostHeader(post),

            const SizedBox(height: 16),

            // Post Content
            _buildPostContent(post),

            const SizedBox(height: 16),

            // Post Actions (Like, Comment, Share)
            _buildPostActions(post),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(Map<String, dynamic> post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(post['profilePic']),
              radius: 24,
            ),
            const SizedBox(width: 8),
            Text(post['name'],
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Colors.black)),
           
          ],
        ),
        IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
      ],
    );
  }

  Widget _buildPostContent(Map<String, dynamic> post) {
    switch (post['contentType']) {
      case 'text':
        return Column(children: [
          Text(
            post['title'],
            style: const TextStyle(
              fontSize: 18, // Change font size
              fontWeight: FontWeight.bold, // Change font weight
              color: Colors.black, // Change text color
               ),
        ),
          Text(
            post['content'],
            style: const TextStyle(fontSize: 14),
          ),
        ]);
      case 'image':
        return Image.network(
          post['content'],
          fit: BoxFit.contain,
        );
      case 'textImage':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post['title'],
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black)),
            Text(
              post['content'],
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            if (post['imageContent'] != null &&
                post['imageContent'].isNotEmpty) ...[
              Image.file(
                File(post['imageContent']),
                fit: BoxFit.cover,
              ),
            ] else ...[
              Text(" "),
            ],
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPostActions(post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Like Button
        IconButton(
          onPressed: () {
            setState(() {
              if (post["isLiked"]) {
                post["likeCount"]--;
                post["isLiked"] = false;
              } else {
                post["likeCount"]++;
                post["isLiked"] = true;
              }
            });
          },
          icon: Icon(
            post["isLiked"] ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: post["isLiked"] ? Colors.red : Colors.blue,
          ),
        ),
        Text(post["likeCount"].toString()),

        // Comment Button
        IconButton(
          onPressed: () {
            // Add Comment button logic here
          },
          icon: const Icon(
            Icons.comment,
            color: Colors.blue,
            size: 24.0,
          ),
        ),

        // Share Button
        IconButton(
          onPressed: () {
            // Add Share button logic here
          },
          icon: const Icon(
            Icons.share,
            color: Colors.blue,
            size: 24.0,
          ),
        ),
      ],
    );
  }
}

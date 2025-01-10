import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_application_code_stakeplot/Community_Page/community_showmodal_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/explore_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/text_screen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:image_picker/image_picker.dart'; // Ensure image_picker is added in pubspec.yaml
import 'dart:io';
import 'package:flutter_application_code_stakeplot/Community_Page/poll_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/image_screen.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class Community extends StatefulWidget {
  const Community({Key? key}) : super(key: key);

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final List<Map<String, dynamic>> posts = [
    {
      'profilePic': 'https://via.placeholder.com/50',
      'name': 'John Doe',
      'contentType': 'text',
      'content': 'This is a text-only post. Welcome to our community!',
      'title': 'title here',
      "likeCount": 0,
      "isLiked": false
    },
    {
      'profilePic': 'https://via.placeholder.com/50',
      'name': 'Jane Smith',
      'contentType': 'image',
      'content': 'https://via.placeholder.com/300',
      "likeCount": 0,
      "isLiked": false
    },
  ];

  String? selectedImage;
  String CurrentUser = 'user1';

  final ImagePicker _picker = ImagePicker(); // Initialize the ImagePicker
  final TextEditingController _searchController = TextEditingController();
  int likeCount = 0; // Counter for likes
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: BottomNavigations(data: 2),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeRow(),

              const SizedBox(height: 16),

              // Posts List
              ListView.builder(
                shrinkWrap:
                    true, // Ensures the list only takes up necessary space
                physics:
                    NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPostCard(post);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back to',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.normal,
                      fontSize: 18,
                      color: Colors.black),
                ),
                Text(
                  'Financial Community',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  DecoratedContainer(
                      width: 55,
                      height: 55,
                      borderRadius: 18,
                      child: IconButton(
                        onPressed: () async {
                          await showModal({});
                          //await CommunityShowModalScreen();
                        },
                        icon: const Icon(Icons.add),
                      )),
                  TextButton(
                      onPressed: () async {
                        //await showModal(); // Await the result here
                      },
                      child: Text(
                        'Create post',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.normal,
                            fontSize: 12,
                            color: Colors.black),
                      )),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 300,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: FontManager().getTextStyle(context,
                      lWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Colors.black),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                ),
              ),
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.chat_sharp)),
          ],
        ),
        SizedBox(
          height: 20,
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
    //int k = 0;
    File? pickedImage;
    int k = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context)
              .viewInsets, // Adjust for keyboard if needed
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            //width: MediaQuery.sizeOf(context).width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 16,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      'Create Post',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Text button
                    Expanded(
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DecoratedContainer(
                            width: 90.0,
                            height: 60.0,
                            child: IconButton(
                              icon: const Icon(Icons.text_fields),
                              onPressed: () {
                                // Replace the current modal content instead of showing a new one
                                Navigator.of(context)
                                    .pop(); // Close the current modal
                                showModalBottomSheet(
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
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Text',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.normal,
                                  fontSize: 18,
                                  color: Colors.black)),
                        ],
                      ),
                    ),
                    // For Image button
                    Expanded(
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DecoratedContainer(
                            width: 90.0,
                            height: 60.0,
                            child: IconButton(
                              icon: const Icon(Icons.image_rounded),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Close the current modal
                                showModalBottomSheet(
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
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Image',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.normal,
                                  fontSize: 18,
                                  color: Colors.black)),
                        ],
                      ),
                    ),

                    // For Poll button
                    Expanded(
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DecoratedContainer(
                            width: 90.0,
                            height: 60.0,
                            child: IconButton(
                              icon: const Icon(Icons.poll_outlined),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Close the current modal
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                  builder: (BuildContext context) {
                                    return Container(
                                      padding: const EdgeInsets.all(16.0),
                                      height:
                                          MediaQuery.sizeOf(context).height / 2,
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
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Poll',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.normal,
                                  fontSize: 18,
                                  color: Colors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                // ... existing code ...
                Align(
                  alignment: Alignment.center,
                  child: DecoratedContainer(
                    width:
                        MediaQuery.of(context).size.width - 50, // Match padding

                    height: 60.0,
                    borderRadius: 24,
                    child: TextButton.icon(
                      icon: Icon(Icons.explore),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the current modal
                        showModalBottomSheet(
                          context: context,
                          //isScrollControlled: true,
                          builder: (context) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.7,
                              // 80% of screen height
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
                      label: Text('Exploria',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal,
                              fontSize: 18,
                              color: Colors.black)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            TextButton(
              onPressed: () {
                // Follow Button Logic
              },
              child: Text('+Follow'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 12,
                    color: Colors.black),
              ),
            ),
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
          fit: BoxFit.cover,
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
//-----------------------------------------

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// //import 'package:flutter_application_code_stakeplot/Community_Page/community_showmodal_screen.dart';
// import 'package:flutter_application_code_stakeplot/Community_Page/explore_screen.dart';
// import 'package:flutter_application_code_stakeplot/Community_Page/text_screen.dart';
// import 'package:image_picker/image_picker.dart'; // Ensure image_picker is added in pubspec.yaml
// import 'dart:io';
// import 'package:flutter_application_code_stakeplot/Community_Page/poll_screen.dart';
// import 'package:flutter_application_code_stakeplot/Community_Page/image_screen.dart';

// class Community extends StatefulWidget {
//   const Community({Key? key}) : super(key: key);

//   @override
//   State<Community> createState() => _CommunityState();
// }

// class _CommunityState extends State<Community> {
//   final List<Map<String, dynamic>> posts = [
//     {
//       'profilePic': 'https://via.placeholder.com/50',
//       'name': 'John Doe',
//       'contentType': 'text',
//       'content': 'This is a text-only post. Welcome to our community!',
//       'title': 'title here',
//       "likeCount": 0,
//       "isLiked": false
//     },
//     {
//       'profilePic': 'https://via.placeholder.com/50',
//       'name': 'Jane Smith',
//       'contentType': 'image',
//       'content': 'https://via.placeholder.com/300',
//       "likeCount": 0,
//       "isLiked": false
//     },
//   ];

//   String? selectedImage;

//   final ImagePicker _picker = ImagePicker(); // Initialize the ImagePicker
//   final TextEditingController _searchController = TextEditingController();
//   int likeCount = 0; // Counter for likes
//   bool isLiked = false;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Welcome Section
//             _buildWelcomeRow(),

//             const SizedBox(height: 16),

//             // Posts List
//             ListView.builder(
//               shrinkWrap:
//                   true, // Ensures the list only takes up necessary space
//               physics:
//                   NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
//               itemCount: posts.length,
//               itemBuilder: (context, index) {
//                 final post = posts[index];
//                 return _buildPostCard(post);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWelcomeRow() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text(
//                   'Welcome back to',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
//                 ),
//                 Text(
//                   'Financial Community',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             Column(
//               children: [
//                 IconButton(
//                   onPressed: () async {
//                     await showModal({});
//                     //await CommunityShowModalScreen();
//                   },
//                   icon: const Icon(Icons.add),
//                 ),
//                 TextButton(
//                     onPressed: () async {
//                       //await showModal(); // Await the result here
//                     },
//                     child: Text('Create post')),
//               ],
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Container(
//               width: 300,
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search...',
//                   prefixIcon: Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: const BorderRadius.all(Radius.circular(24.0)),
//                   ),
//                 ),
//               ),
//             ),
//             IconButton(onPressed: () {}, icon: Icon(Icons.chat_sharp)),
//           ],
//         ),
//         SizedBox(
//           height: 20,
//         ),
//         Text(
//           'Featured Posts',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }

//   // This is the modal function where we allow the user to pick an image
//   Future<void> showModal(Map<String, dynamic> post) async {
//     int k = 0; // Keep track of the modal state

//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             if (k == 1) {
//               return TextScreen(
//                 userInfo: post,
//                 onPostCreated: (newPost) {
//                   setState(() {
//                     posts.add(newPost);
//                     // Ensure the UI rebuilds after adding a new post
//                   });
//                 },
//               );
//             } else if (k == 2) {
//               return ImageScreen(
//                 userInfo: post,
//                 onPostCreated: (newPost) {
//                   setState(() {
//                     posts.add(newPost);
//                     // Ensure the UI rebuilds after adding a new post
//                   });
//                   Navigator.pop(context);
//                 },
//               );
//             } else if (k == 3) {
//               return Container(
//                 padding: const EdgeInsets.all(16.0),
//                 height: MediaQuery.sizeOf(context).height / 2,
//                 width: MediaQuery.sizeOf(context).width,
//                 child: PollScreen(
//                   onPollPosted: (pollData) {
//                     setState(() {
//                       posts.add(pollData);
//                     });
//                     Navigator.pop(context);
//                   },
//                 ),
//               );
//             } else if (k == 4) {
//               return Container(
//                 height: MediaQuery.of(context).size.height *
//                     0.7, // 80% of screen height
//                 child: ExploreModal(
//                   onPostCreated: (newPost) {
//                     setState(() {
//                       posts.add(newPost);
//                     });
//                     Navigator.pop(context);
//                   },
//                 ),
//               );
//             } else {
//               return Container(
//                 padding: const EdgeInsets.all(16.0),
//                 height: MediaQuery.sizeOf(context).height,
//                 width: MediaQuery.sizeOf(context).width,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Create Post',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         // Text button
//                         Column(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.text_fields),
//                               onPressed: () {
//                                 // Update the modal content
//                                 setState(() {
//                                   k = 1; // Set k to true
//                                 });
//                               },
//                             ),
//                             const Text('Text'),
//                           ],
//                         ),
//                         // For Image button
//                         Column(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.image_rounded),
//                               onPressed: () {
//                                 setState(() {
//                                   k = 2; // Set k to true
//                                 });
//                               },
//                             ),
//                             const Text('Image'),
//                           ],
//                         ),
//                         // For Poll button
//                         Column(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.poll_outlined),
//                               onPressed: () {
//                                 setState(() {
//                                   k = 3; // Set k to true
//                                 });
//                               },
//                             ),
//                             const Text('Poll'),
//                           ],
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 24),
//                     // ... existing code ...
//                     TextButton(
//                       onPressed: () {
//                         setState(() {
//                           k = 4; // Set k to true
//                         });
//                       },
//                       child: const Text('Exploria'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//           },
//         );
//       },
//     );
//   }

//   Widget _buildPostCard(Map<String, dynamic> post) {
//     if (post['contentType'] == 'poll') {
//       return Card(
//         margin: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 20, // Size of the profile picture
//                         backgroundImage: NetworkImage(
//                             'https://via.placeholder.com/50'), // Profile picture URL
//                         backgroundColor: Colors
//                             .grey[300], // Fallback color if image fails to load
//                       ),
//                       Text(
//                         post['name'],
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               // Post author name

//               const SizedBox(height: 8),

//               // Poll question
//               Text(
//                 post['question'],
//                 style: const TextStyle(
//                   fontSize: 14.0,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Poll options with percentage bars
//               ...(post['options'] as List<String>).map<Widget>((option) {
//                 // Calculate percentage of votes for the option
//                 final totalVotes = (post['votes'].values as Iterable<int>)
//                     .fold<int>(0, (int a, int b) => a + b);
//                 final optionVotes = post['votes'][option] as int;
//                 final percentage =
//                     totalVotes > 0 ? (optionVotes / totalVotes) * 100 : 0;

//                 return GestureDetector(
//                   onTap: () {
//                     // Update votes dynamically
//                     post['votes'][option] = optionVotes + 1;

//                     // Trigger a UI rebuild (ensure the widget uses setState or similar)
//                     (context as Element).markNeedsBuild();
//                   },
//                   child: Column(
//                     children: [
//                       ListTile(
//                         title: Text(option),
//                         trailing: Text(
//                           '${percentage.toStringAsFixed(1)}%',
//                           style: const TextStyle(
//                             color: Colors.grey,
//                             fontSize: 14.0,
//                           ),
//                         ),
//                       ),
//                       LinearProgressIndicator(
//                         value: totalVotes > 0 ? percentage / 100 : 0,
//                         minHeight: 5,
//                         backgroundColor: Colors.grey[300],
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           Colors.blue,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               _buildPostActions(post),
//             ],
//           ),
//         ),
//       );
//     }
//     if (post['contentType'] == 'Exploria') {
//       return Card(
//         margin: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 10, // Size of the profile picture
//                         backgroundImage: NetworkImage(
//                             'https://via.placeholder.com/50'), // Profile picture URL
//                         backgroundColor: Colors
//                             .grey[300], // Fallback color if image fails to load
//                       ),
//                       Text(
//                         post['name'],
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               if (selectedImage != null) Image.network(selectedImage!),
//               if (selectedImage == null)
//                 Container(
//                   height: 200,
//                   color: Colors.grey[300],
//                   child: Center(
//                     child: Icon(Icons.image, size: 50, color: Colors.grey),
//                   ),
//                 ),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Text(
//                           'Place:',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16.0,
//                           ),
//                         ),
//                         Text('${post['locationName']}'),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Text(
//                           'Location:',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16.0,
//                           ),
//                         ),
//                         Text('${post['locationAddress']}'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 'Budget(Per Day)',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16.0,
//                 ),
//               ),
//               ...List.generate(post['budgetItems'].length, (index) {
//                 final budgetItem = post['budgetItems'][index];
//                 return Chip(
//                   elevation: 20,
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   backgroundColor: Colors.grey,
//                   shadowColor: Colors.black,
//                   label: Text(
//                     '${budgetItem['description']} ${budgetItem['amount']}',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 );
//               }),
//               //Text('${post['amount']}'),
//               // Text('${post['description']} ${post['amount']}'),

//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 'Trip Highlights',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16.0,
//                 ),
//               ),
//               Column(
//                 children: [
//                   Text('${post['title']}'),
//                   Text(
//                     'Description',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16.0,
//                     ),
//                   ),
//                   Text('${post['content']}'),
//                 ],
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               _buildPostActions(post)
//             ],
//           ),
//         ),
//       );
//     }

//     return Card(
//       //margin: const EdgeInsets.only(bottom: 16.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Post Header
//             _buildPostHeader(post),

//             const SizedBox(height: 16),

//             // Post Content
//             _buildPostContent(post),

//             const SizedBox(height: 16),

//             // Post Actions (Like, Comment, Share)
//             _buildPostActions(post),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPostHeader(Map<String, dynamic> post) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: NetworkImage(post['profilePic']),
//               radius: 24,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               post['name'],
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Follow Button Logic
//               },
//               child: Text('+Follow'),
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 textStyle: const TextStyle(fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//         IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
//       ],
//     );
//   }

//   Widget _buildPostContent(Map<String, dynamic> post) {
//     switch (post['contentType']) {
//       case 'text':
//         return Column(children: [
//           Text(
//             post['title'],
//             style: const TextStyle(fontSize: 14),
//           ),
//           Text(
//             post['content'],
//             style: const TextStyle(fontSize: 14),
//           ),
//         ]);
//       case 'image':
//         return Image.network(
//           post['content'],
//           fit: BoxFit.cover,
//         );
//       case 'textImage':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               post['title'],
//               style: const TextStyle(fontSize: 14),
//             ),
//             Text(
//               post['content'],
//               style: const TextStyle(fontSize: 14),
//             ),
//             const SizedBox(height: 8),
//             if (post['imageContent'] != null &&
//                 post['imageContent'].isNotEmpty) ...[
//               Image.file(
//                 File(post['imageContent']),
//                 fit: BoxFit.cover,
//               ),
//             ] else ...[
//               Text(" "),
//             ],
//           ],
//         );
//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   Widget _buildPostActions(post) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         // Like Button
//         IconButton(
//           onPressed: () {
//             setState(() {
//               if (post["isLiked"]) {
//                 post["likeCount"]--;
//                 post["isLiked"] = false;
//               } else {
//                 post["likeCount"]++;
//                 post["isLiked"] = true;
//               }
//             });
//           },
//           icon: Icon(
//             post["isLiked"] ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
//             color: post["isLiked"] ? Colors.red : Colors.blue,
//           ),
//         ),
//         Text(post["likeCount"].toString()),

//         // Comment Button
//         IconButton(
//           onPressed: () {
//             // Add Comment button logic here
//           },
//           icon: const Icon(
//             Icons.comment,
//             color: Colors.blue,
//             size: 24.0,
//           ),
//         ),

//         // Share Button
//         IconButton(
//           onPressed: () {
//             // Add Share button logic here
//           },
//           icon: const Icon(
//             Icons.share,
//             color: Colors.blue,
//             size: 24.0,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/explore_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postLoad.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postloadTranding.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/text_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/widgets/buildbutton.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/NavigatorScreens/userNavigator.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application_code_stakeplot/Community_Page/poll_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/image_screen.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:page_transition/page_transition.dart';

RxBool isPostloading = false.obs;
RxBool hasMorePostTranding = false.obs;
RxBool hasMorePostFeed = false.obs;

class Community extends StatefulWidget {
  const Community({Key? key}) : super(key: key);

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final List<Map<String, dynamic>> posts = [];

  String? selectedImage;
  String CurrentUser = 'user1';

  int likeCount = 0; // Counter for likes
  bool isLiked = false;
  final CommunityScreenStrings strings = CommunityScreenStrings();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    currentPageTranding.value = 1;
    currentPageFeed.value = 1;
    isPostloading.value = false;
    getTrendingData.clear();
    getAllPostData.clear();
    hasMorePostTranding.value = true;
    hasMorePostFeed.value = true;
    getPost();
    getTranding();
    setUpSocketListenerMainPage(context);
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 50 &&
          !isPostloading.value) {
        isPostloading.value = true;
        if (isTrending.value) {
          if (hasMorePostTranding.value) getTranding();
        } else {
          if (hasMorePostFeed.value) getPost();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          Obx(() => isTrending.value ? SizedBox.shrink() : PostImage()),
      bottomNavigationBar: SafeArea(child: BottomNavigations(data: 2)),
      body: SafeArea(
        child: Container(
         height : MediaQuery.of(context).size.height / 1.1,
          padding:
              const EdgeInsets.only(left: 0.0, right: 0.0, bottom: 0, top: 8.0),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildWelcomeRow(context),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12.0, right: 12.0, top: 4),
                  child: Obx(() =>
                      isTrending.value ? getTabs(context) : getTabs(context)),
                ),
                Obx(() => isTrending.value ? getTrandingWidget() : getFeed())
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getFeed() {
    return getTrendingData.isEmpty && !isPost.value
        ? const Loader()
        : isPost.value && getTrendingData.isEmpty
            ? noFriend(
                context, "Make friends to see their posts or upload post")
            : Obx(
                () => getPosted.value ? LazyLoadingList() : LazyLoadingList());
  }

  Widget getTrandingWidget() {
    return getAllPostData.isEmpty && !isPostTranding.value
        ? const Loader()
        : isPostTranding.value && getAllPostData.isEmpty
            ? noFriend(
                context, "Make friends to see their posts or upload post")
            : Obx(() => getPostedTranding.value
                ? LazyLoadingTranding()
                : LazyLoadingTranding());
  }

  Widget PostImage() {
    return Container(
      width: MediaQuery.of(context).size.width /
          8, // Slightly larger for better visibility
      height:
          MediaQuery.of(context).size.width / 8, // Maintain square aspect ratio
      decoration: BoxDecoration(
        color: AppColors
            .finSpaceColor, // Ensure this color contrasts well with the background
        borderRadius:
            BorderRadius.circular(30), // Reduced radius for a modern look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Subtle shadow for depth
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            maskedName.value.trim().isEmpty
                ? MaskedNameDialogBox.showMaskedNameDialog(context)
                : await showModal({});
          },
          splashColor: Colors.white.withOpacity(0.3), // Visual feedback on tap
          child: const Center(
            child: Icon(
              Icons.add, // Generic icon for adding content
              size: 26, // Slightly larger for visibility
              color: Colors.white, // High contrast with primaryColor
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
            return PostCard(
              data: dataObj,
              index: index,
            );
          },
        ));
  }

  Widget getTabs(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
              onTap: () {
                isTrending.value = false;
              },
              child: textStyleImage(
                  context: context,
                  text: strings.feed,
                  fontsize: !isTrending.value ? 18 : 14,
                  fontWeight:
                      !isTrending.value ? FontWeight.w700 : FontWeight.w400,
                  c: AppColors.accentColor)),
        ),
        GestureDetector(
            onTap: () {
              isTrending.value = true;
            },
            child: textStyleImage(
                context: context,
                text: strings.trending,
                fontsize: isTrending.value ? 18 : 14,
                fontWeight:
                    isTrending.value ? FontWeight.w700 : FontWeight.w400,
                c: AppColors.accentColor)),
      ]),
    );
  }

  // This is the modal function where we allow the user to pick an image
  Future<void> showModal(Map<String, dynamic> post) async {
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

        return SafeArea(
          child: Padding(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.accentColor,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: horizontalPadding / 2),
                          child: Text(
                            strings.createPost,
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                              color: AppColors.accentColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 40), // To balance the back button
                      ],
                    ),
                    SizedBox(height: verticalPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildOptionButton(
                          context: context,
                          icon: Icons.text_fields,
                          label: strings.textOption,
                          onTap: () {
                            posting.value = false;
                            Navigator.of(context).pop();
                              Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextScreen(
                                    userInfo: post,
                                    onPostCreated: (newPost) {
                                      setState(() {
                                        posts.add(newPost);
                                        k = 1;
                                      });
                                    },
                                  ),
        ),
      );
                            // showModalBottomSheet(
                            //   isScrollControlled: true,
                            //   backgroundColor: AppColors.backgroundColor,
                            //   context: context,
                            //   builder: (context) {
                            //     return Container(
                            //       decoration: const BoxDecoration(
                            //           color: Colors.white,
                            //           borderRadius: BorderRadius.only(
                            //               topLeft: Radius.circular(16),
                            //               topRight: Radius.circular(16))),
                            //       child: TextScreen(
                            //         userInfo: post,
                            //         onPostCreated: (newPost) {
                            //           setState(() {
                            //             posts.add(newPost);
                            //             k = 1;
                            //           });
                            //         },
                            //       ),
                            //     );
                            //   },
                            // );
                          
                          },
                        ),
                        buildOptionButton(
                          context: context,
                          icon: Icons.image_rounded,
                          label: strings.imageOption,
                          onTap: () {
                            posting.value = false;
                            Navigator.of(context).pop();
                             Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageScreen(
                                    userInfo: post,
                                    onPostCreated: (newPost) {
                                      setState(() {
                                        posts.add(newPost);
                                      });
                                    },
                                  ),
        ),
      );
                            // showModalBottomSheet(
                            //   isScrollControlled: true,
                            //   backgroundColor: AppColors.backgroundColor,
                            //   context: context,
                            //   builder: (context) {
                            //     return Container(
                            //       decoration: BoxDecoration(
                            //           color: Colors.white,
                            //           borderRadius: BorderRadius.only(
                            //               topLeft: Radius.circular(16),
                            //               topRight: Radius.circular(16))),
                            //       child: ImageScreen(
                            //         userInfo: post,
                            //         onPostCreated: (newPost) {
                            //           setState(() {
                            //             posts.add(newPost);
                            //           });
                            //         },
                            //       ),
                            //     );
                            //   },
                            // );
                          
                          },
                        ),
                        buildOptionButton(
                          context: context,
                          icon: Icons.poll_outlined,
                          label: strings.pollOption,
                          onTap: () {
                            posting.value = false;
                            Navigator.of(context).pop();
                            Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>  PollScreen(
                                    userInfo: post,
                                    onPollPosted: (pollData) {
                                      setState(() {
                                        posts.add(pollData);
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
        ),
      );
                            // showModalBottomSheet(
                            //   isScrollControlled: true,
                            //   backgroundColor: AppColors.backgroundColor,
                            //   context: context,
                            //   builder: (context) {
                            //     return Container(
                            //       padding: const EdgeInsets.all(16.0),
                            //       width: MediaQuery.sizeOf(context).width,
                            //       decoration: BoxDecoration(
                            //           color: Colors.white,
                            //           borderRadius: BorderRadius.only(
                            //               topLeft: Radius.circular(16),
                            //               topRight: Radius.circular(16))),
                            //       child: PollScreen(
                            //         userInfo: post,
                            //         onPollPosted: (pollData) {
                            //           setState(() {
                            //             posts.add(pollData);
                            //           });
                            //           Navigator.pop(context);
                            //         },
                            //       ),
                            //     );
                            //   },
                            // );
                          
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
                          backgroundColor: AppColors.backgroundColor,
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
                                strings.exploria,
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
          ),
        );
      },
    );
  }
}

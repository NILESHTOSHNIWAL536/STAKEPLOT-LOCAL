import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/explore_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postLoadFeed.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postloadTranding.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/text_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/widgets/buildbutton.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/repository/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/poll_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/image_screen.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../Constants/core/app_padding_sizes.dart';

class Community extends StatefulWidget {
  const Community({Key? key}) : super(key: key);

  @override
  State<Community> createState() => CommunityState();
}

class CommunityState extends State<Community> {
  final List<Map<String, dynamic>> posts = [];

  String? selectedImage;
  String CurrentUser = 'user1';

  int likeCount = 0; // Counter for likes
  bool isLiked = false;
  final CommunityScreenStrings strings = CommunityScreenStrings();
  final ScrollController scrollController = ScrollController();
  final ScrollController scrollControllerPost = ScrollController();
  final RxBool showScrollToTop = false.obs;

  ScrollController get controller => scrollController;

  Future<void> wait() async {
    await Future.delayed(Duration(seconds: 1, milliseconds: 500));
  }

  @override
  // void initState() {
  //   super.initState();
  //   initGetControllersIfisRegistered();
  //   postController.currentPageTranding.value = 1;
  //   postController.currentPageFeed.value = 1;
  //   postController.isPostloading.value = false;
  //   postController.hasMorePostTranding.value = true;
  //   postController.hasMorePostFeed.value = true;
  //   callApisPost();
    
  // }
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    initGetControllersIfisRegistered();

    postController.currentPageTranding.value = 1;
    postController.currentPageFeed.value = 1;
    postController.isPostloading.value = false;
    postController.hasMorePostTranding.value = true;
    postController.hasMorePostFeed.value = true;

    callApisPost(); // ✅ SAFE NOW
  });
}

  void callApisPost() async {
    // await wait();
    postController.isPost.value = false;
    postController.isPostTranding.value = false;
    getPost(context);
    getTranding(context);
    setUpSocketListenerMainPage(context);
    scrollControllerPost.addListener(() {
      showScrollToTop.value = scrollControllerPost.offset > 50;
      if (scrollControllerPost.position.pixels >=
              scrollControllerPost.position.maxScrollExtent - 50 &&
          !postController.isPostloading.value) {
        postController.isPostloading.value = true;
        if (postController.isTrending.value) {
          if (postController.hasMorePostTranding.value) getTranding(context);
        } else {
          if (postController.hasMorePostFeed.value) getPost(context);
        }
      }
    });
  }

  void _scrollToTop() {
    scrollControllerPost.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
@override
void dispose() {
  scrollController.dispose();
  scrollControllerPost.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // floatingActionButton: Obx(() =>
      //     postController.isTrending.value ? SizedBox.shrink() : PostImage()),
      bottomNavigationBar: BottomNavigations(
        data: 2,
        onCommunityDoubleTap: _scrollToTop, // Pass callback
      ),
//       body:
//        SingleChildScrollView(
//         controller: scrollControllerPost,
//         // controller: scrollController, uncomment this if anythimg goes wrong with pagination
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // buildWelcomeRow(context),
//             ArenaHeader(
//             initialTab: 1, // Polls
//             onTabChanged: (index) {
            
//             },
//           ),
//             // Padding(
//             //   padding:
//             //       const EdgeInsets.only(left:AppSizes.p12, right:AppSizes.p12, top: 4),
//             //   child: Obx(() => postController.isTrending.value
//             //       ? getTabs(context)
//             //       : getTabs(context)),
//             // ),
//            Obx(() {

//   final isTrending = postController.isTrending.value;

//   return isTrending
//       ? getTrandingWidget()
//       : getFeed();

// })

//           ],
//         ),
//       ),

    body:
     CustomScrollView(
  controller: scrollControllerPost,
  slivers: [

    /// HEADER
    SliverToBoxAdapter(
      child: ArenaHeader(
        initialTab: 1,
        onTabChanged: (index) {},
      ),
    ),

    /// FEED
    Obx(() {

      final posts = postController.isTrending.value
          ? postController.trandingPostList
          : postController.feedPostList;

      final isLoading = postController.isPostloading.value;
      final hasMore = postController.isTrending.value
          ? postController.hasMorePostTranding.value
          : postController.hasMorePostFeed.value;

      return SliverPadding(
  padding: EdgeInsets.only(
    bottom: kBottomNavigationBarHeight + 20,), // ⭐ MAGIC LINE
  
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
        
              /// Loader at bottom
              if (index >= posts.length) {
        
                if (!isLoading) return const SizedBox();
        
                return Skeletonizer(
                  enabled: true,
                  child: PostCard(
                    data: posts.last,
                    index: posts.length - 1,
                  ),
                );
              }
        
              return PostCard(
                key: ValueKey(posts[index].id),
                data: posts[index],
                index: index,
              );
            },
        
            childCount: posts.length + (hasMore ? 1 : 0),
          ),
        ),
      
      );
    }),
  ],
),

    );
  }

  Widget getFeed() {
    return postController.feedPostList.isEmpty && !postController.isPost.value
        ? const Center(
            child: Loader(),
          )
        : (postController.isPost.value && postController.feedPostList.isEmpty)
            ? Padding(
                padding: const EdgeInsets.only(top: 40),
                child: SizedBox(
                  
                  height: MediaQuery.sizeOf(context).height / 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AvatarProfileImage(
                        url: FinSpaceIcons.empty,
                        height: 5,
                        width: 5,
                      ),
                      Text('Nothing to show based on your interests.',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.accentColor)),
                    ],
                  ),
                ),
              )
            : Obx(() => postController.getPosted.value
                ? LazyLoadingList()
                : LazyLoadingList());
  }

  Widget getTrandingWidget() {
    return postController.trandingPostList.isEmpty &&
            !postController.isPostTranding.value
        ? Center(child: const Loader())
        : (postController.isPostTranding.value &&
                postController.trandingPostList.isEmpty)
            ? Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Container(
                  height: MediaQuery.sizeOf(context).height / 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AvatarProfileImage(
                        url: FinSpaceIcons.empty,
                        height: 5,
                        width: 5,
                      ),
                      Text('Nothing to show .',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.accentColor)),
                    ],
                  ),
                ),
              )
            : Obx(() => postController.getPostedTranding.value
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
            color: AppColors.accentColor
                .withOpacity(0.2), // Subtle shadow for depth
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparentColor,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            String maskedName =
                ControllerManagement.userController.maskedName.value;
            maskedName.isEmpty || maskedName == "" || maskedName == Null
                ? MaskedNameDialogBox.showMaskedNameDialog(context)
                : await showModal({});
          },
          splashColor: AppColors.backgroundColor
              .withOpacity(0.3), // Visual feedback on tap
          child: const Center(
            child: Icon(
              Icons.add, // Generic icon for adding content
              size: 26, // Slightly larger for visibility
              color:
                  AppColors.backgroundColor, // High contrast with primaryColor
            ),
          ),
        ),
      ),
    );
  }

  

  Widget _buildDottedDivider() {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final boxWidth = constraints.constrainWidth();
          final dashWidth = 5.0;
          final dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor.withOpacity(0.4),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget getTabs(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right:AppSizes.p10),
              child: GestureDetector(
                  onTap: () {
                    postController.isTrending.value = false;
                    postController.isPostloading.value = false;
                  },
                  child: textStyleImage(
                      context: context,
                      text: strings.feed,
                      fontsize: !postController.isTrending.value ? 20 : 14,
                      fontWeight: !postController.isTrending.value
                          ? FontWeight.w700
                          : FontWeight.w400,
                      c: postController.isTrending.value
                          ? AppColors.now
                          : AppColors.finSpaceColor)),
            ),
            GestureDetector(
                onTap: () {
                  postController.isTrending.value = true;
                  postController.isPostloading.value = false;
                },
                child: textStyleImage(
                    context: context,
                    text: strings.trending,
                    fontsize: postController.isTrending.value ? 20 : 14,
                    fontWeight: postController.isTrending.value
                        ? FontWeight.w700
                        : FontWeight.w400,
                    c: !postController.isTrending.value
                        ? AppColors.now
                        : AppColors.finSpaceColor)),
          ]),
    );
  }

  // This is the modal function where we allow the user to pick an image
  Future<void> showModal(Map<String, dynamic> post) async {
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
              width: MediaQuery.sizeOf(context).width,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: AppColors.finSpaceColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    0.9, // Limit height to 90% of screen
              ),
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            postController.posting.value = false;
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TextScreen(
                                  userInfo: post,
                                  onPostCreated: (newPost) {
                                    setState(() {
                                      posts.add(newPost);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: AppSizes.p20),
                              child: Text(
                                strings.textOption,
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildDottedDivider(),
                        GestureDetector(
                          onTap: () {
                            postController.posting.value = false;
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
                                ));
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: AppSizes.p20),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              child: Text(
                                "Post Card",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildDottedDivider(),
                        GestureDetector(
                          onTap: () {
                            postController.posting.value = false;
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PollScreen(
                                  // userInfo: post,
                                  // onPollPosted: (pollData) {
                                  //   setState(() {
                                  //     posts.add(pollData);
                                  //   });
                                  //   Navigator.pop(context);
                                  // },
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: AppSizes.p20),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              child: Text(
                                strings.pollOption,
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildDottedDivider(),
                        GestureDetector(
                          onTap: () {
                            postController.posting.value = false;
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExploreModal(
                                  onPostCreated: (newPost) {
                                    setState(() {
                                      posts.add(newPost);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: AppSizes.p20),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              child: Text(
                                strings.exploria,
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

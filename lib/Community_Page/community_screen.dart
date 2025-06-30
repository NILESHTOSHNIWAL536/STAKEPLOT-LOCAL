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
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/poll_screen.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/image_screen.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';


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

  @override
  void initState() {
    super.initState();
    postController.currentPageTranding.value = 1;
    postController.currentPageFeed.value = 1;
    postController.isPostloading.value = false;
    postController.trandingPostList.clear();
    postController.feedPostList.clear();
    postController.hasMorePostTranding.value = true;
    postController.hasMorePostFeed.value = true;
    postController.isPost.value = false;
    postController.isPostTranding.value = false;
    getPost();
    getTranding();
    setUpSocketListenerMainPage(context);
    //     scrollController.addListener(_onScroll); //uncomment this if anything goes wrong 
    scrollControllerPost.addListener(() {
      // Scroll-to-top visibility
      
      showScrollToTop.value = scrollControllerPost.offset > 50;

      // Pagination logic
      if (scrollControllerPost.position.pixels >=
              scrollControllerPost.position.maxScrollExtent - 50 &&
          !postController.isPostloading.value) {
        print('DEBUG: Triggering pagination');
        postController.isPostloading.value = true;
        if (postController.isTrending.value) {
          if (postController.hasMorePostTranding.value) getTranding();
        } else {
          if (postController.hasMorePostFeed.value) getPost();
        }
      }
    });
  
  }
//   void _onScroll() // uncomment
//   {
//     scrollController.addListener(() async {
//       if (scrollController.position.pixels >=
//               scrollController.position.maxScrollExtent - 50 &&
//           ! postController.isPostloading.value) {
//          postController.isPostloading.value = true;
//         if ( postController.isTrending.value) {
//           if ( postController.hasMorePostTranding.value) getTranding();
//         } else {
//           if ( postController.hasMorePostFeed.value) getPost();
//         }
//       }
//     });
//   }
   // Scroll-to-top callback for BottomNavigations
  void _scrollToTop() {
    print('DEBUG: Double-tap on Community tab, scrolling to top');
    scrollControllerPost.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
// 



  @override
  Widget build(BuildContext context) {
    print('DEBUG: Building Community widget');
    return Scaffold(
      
      floatingActionButton: Obx(() =>
          postController.isTrending.value ? SizedBox.shrink() : PostImage()),
      // bottomNavigationBar: SafeArea(child: BottomNavigations(data: 2)),
      bottomNavigationBar: SafeArea(
        child: BottomNavigations(
          data: 2,
          onCommunityDoubleTap: _scrollToTop, // Pass callback
        ),
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height / 1.1,
          padding:
              const EdgeInsets.only(left: 0.0, right: 0.0, bottom: 0, top: 8.0),
          child: SingleChildScrollView(
            controller: scrollControllerPost,
            // controller: scrollController, uncomment this if anythimg goes wrong with pagination
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildWelcomeRow(context),
                Padding(
                  padding:const EdgeInsets.only(left: 12.0, right: 12.0, top: 4),
                  child: Obx(() => postController.isTrending.value ? getTabs(context): getTabs(context)),
                ),
                Obx(() => postController.isTrending.value
                    ? getTrandingWidget()
                    : getFeed()),
                    
              ],
            ),
            
          ),
        ),
      ),
    
    );
    
  }

  Widget getFeed() {
    return postController.feedPostList.isEmpty && !postController.isPost.value
        ? const Loader()
        : (postController.isPost.value && postController.feedPostList.isEmpty)
            ? Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Container(
                //  color: Colors.amber,
                height: MediaQuery.sizeOf(context).height/3,
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
        ? const Loader()
        : (postController.isPostTranding.value &&
                postController.trandingPostList.isEmpty)
            ?  Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Container(
                //  color: Colors.amber,
                height: MediaQuery.sizeOf(context).height/3,
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
            String maskedName =
                ControllerManagement.userController.maskedName.value;
            maskedName.isEmpty || maskedName == "" || maskedName == Null
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
          itemCount: postController.feedPostList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final dataObj = postController.feedPostList[index];
            return PostCard(
              data: dataObj,
              index: index,
            );
          },
        ));
  }

  Widget _buildDottedDivider() {
    return Container(
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
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
                                      k = 1;
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
                                  horizontal: 8, vertical: 20),
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
                                horizontal: 8, vertical: 20),
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
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 20),
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
                                horizontal: 8, vertical: 20),
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

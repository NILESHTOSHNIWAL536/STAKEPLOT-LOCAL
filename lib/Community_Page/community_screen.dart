import 'package:flutter/material.dart';
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
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
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
  int selectedArenaTab = 1;

  static const List<Map<String, String>> dummyComics = [
    {
      "title": "Crypto crash",
      "subtitle": "Learn why Bitcoin dropped 20% this week",
      "tag": "Digital Assets",
      "meta": "Trending",
      "image":
          "https://images.unsplash.com/photo-1621761191319-c6fb62004040?auto=format&fit=crop&w=900&q=80"
    },
    {
      "title": "NFT Revolution",
      "subtitle": "The new rules of digital ownership",
      "tag": "Digital Assets",
      "meta": "2 day ago",
      "image":
          "https://images.unsplash.com/photo-1642104704074-907c0698cbd9?auto=format&fit=crop&w=900&q=80"
    },
    {
      "title": "DeFi Explained",
      "subtitle": "Yield, swaps, and risk without the noise",
      "tag": "DeFi",
      "meta": "Popular",
      "image":
          "https://images.unsplash.com/photo-1639322537228-f710d846310a?auto=format&fit=crop&w=900&q=80"
    },
  ];

  static const List<Map<String, String>> dummyPersonalized = [
    {
      "title": "Tax Tactics 101",
      "subtitle": "Based on your reading history",
      "image":
          "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=700&q=80"
    },
    {
      "title": "Budget Like a Boss",
      "subtitle": "Popular with similar readers",
      "image":
          "https://images.unsplash.com/photo-1554224154-22dec7ec8818?auto=format&fit=crop&w=700&q=80"
    },
    {
      "title": "Salary Reset",
      "subtitle": "Smarter monthly planning in six panels",
      "image":
          "https://images.unsplash.com/photo-1554224154-26032ffc0d07?auto=format&fit=crop&w=700&q=80"
    },
  ];

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
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
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

      body: CustomScrollView(
        controller: scrollControllerPost,
        slivers: [
          /// HEADER
          SliverToBoxAdapter(
            child: ArenaHeader(
              initialTab: 1,
              onTabChanged: (index) {
                setState(() {
                  selectedArenaTab = index;
                });
              },
              onCreatePressed: () async {
                String maskedName =
                    ControllerManagement.userController.maskedName.value;
                maskedName.trim().isEmpty
                    ? MaskedNameDialogBox.showMaskedNameDialog(context)
                    : await showModal({});
              },
            ),
          ),

          /// FEED
          Obx(() {
            if (selectedArenaTab == 0) {
              return SliverToBoxAdapter(child: _comicContent());
            }

            final posts = postController.isTrending.value
                ? postController.trandingPostList
                : postController.feedPostList;

            final isLoading = postController.isPostloading.value;
            final hasMore = postController.isTrending.value
                ? postController.hasMorePostTranding.value
                : postController.hasMorePostFeed.value;

            return SliverPadding(
              padding: EdgeInsets.only(
                bottom: kBottomNavigationBarHeight + 20,
              ), // ⭐ MAGIC LINE

              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    /// Loader at bottom
                    if (index >= posts.length) {
                      if (!isLoading || posts.isEmpty) return const SizedBox();

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

  Widget _comicContent() {
    return Padding(
      padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
            child: _featuredComicCard(dummyComics.first),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 28, 26, 14),
            child: _sectionTitle("Trending Now", Icons.trending_up_rounded),
          ),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 26),
              itemBuilder: (context, index) => _trendingComicCard(
                  dummyComics[(index + 1) % dummyComics.length]),
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.w16),
              itemCount: 4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 14),
            child: _sectionTitle("Personalized for You", Icons.auto_awesome),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: dummyPersonalized
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.p16),
                        child: _personalizedComicCard(item),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    final colors = context.appColors;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w800,
              fontSize: 24,
              color: colors.onBackground,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.w8),
        Icon(icon, color: colors.primary, size: 24),
      ],
    );
  }

  Widget _featuredComicCard(Map<String, String> item) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: NetworkImage(item["image"]!),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(75, 77, 115, 0.24),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x33000000), Color(0xCC000000)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item["title"]!,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w800,
                fontSize: 25,
                color: AppColors.backgroundColor,
              ),
            ),
            const SizedBox(height: AppSizes.h8),
            Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: AppColors.backgroundColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  item["meta"]!,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.backgroundColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              item["subtitle"]!,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.backgroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trendingComicCard(Map<String, String> item) {
    final colors = context.appColors;

    return Container(
      width: 255,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        // boxShadow: context.isDarkMode
        //     ? []
        //     : const [
        //         BoxShadow(
        //           color: Color.fromRGBO(0, 0, 0, 0.12),
        //           blurRadius: 12,
        //           offset: Offset(0, 6),
        //         )
        //       ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.network(
              item["image"]!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item["tag"]!,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w700,
                      fontSize: 11,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.h10),
                Text(
                  item["title"]!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w800,
                    fontSize: 17,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalizedComicCard(Map<String, String> item) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        // boxShadow: context.isDarkMode
        //     ? []
        //     : const [
        //         BoxShadow(
        //           color: Color.fromRGBO(0, 0, 0, 0.13),
        //           blurRadius: 18,
        //           offset: Offset(0, 8),
        //         )
        //       ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item["image"]!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSizes.w16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"]!,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w800,
                    fontSize: 20,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSizes.h10),
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: colors.primary, size: 16),
                    const SizedBox(width: AppSizes.w6),
                    Expanded(
                      child: Text(
                        item["subtitle"]!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: 14,
                          color: colors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: colors.secondaryText, size: 30),
        ],
      ),
    );
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
            maskedName.trim().isEmpty
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

  Widget getTabs(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.p10),
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
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final colors = context.appColors;
        return SafeArea(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: colors.dialogBackground,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.h20),
                    Text(
                      "Create in Arena",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w800,
                        fontSize: 22,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSizes.h6),
                    Text(
                      "Pick the format that fits your idea.",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w400,
                        fontSize: 14,
                        color: colors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSizes.h18),
                    _createOptionTile(
                      context: context,
                      icon: Icons.short_text_rounded,
                      title: strings.textOption,
                      subtitle: "Share a thought, question, or quick insight.",
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
                    ),
                    _createOptionTile(
                      context: context,
                      icon: Icons.image_outlined,
                      title: "Post Card",
                      subtitle: "Add an image-led post with a caption.",
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
                          ),
                        );
                      },
                    ),
                    _createOptionTile(
                      context: context,
                      icon: Icons.poll_outlined,
                      title: strings.pollOption,
                      subtitle: "Ask the community and collect votes.",
                      onTap: () {
                        postController.posting.value = false;
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PollScreen(),
                          ),
                        );
                      },
                    ),
                    _createOptionTile(
                      context: context,
                      icon: Icons.explore_outlined,
                      title: strings.exploria,
                      subtitle: "Create a richer story-style post.",
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
                    ),
                    const SizedBox(height: AppSizes.h8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _createOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p12),
      child: Material(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.p14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colors.primary, size: 24),
                ),
                const SizedBox(width: AppSizes.w12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w400,
                          fontSize: 12,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

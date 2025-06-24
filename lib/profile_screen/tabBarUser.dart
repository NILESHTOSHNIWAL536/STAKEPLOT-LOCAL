
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';

class TabBarUser extends StatefulWidget {
  final List<PostModel> userPostList;
   TabBarUser({Key? key, required this.userPostList}) : super(key: key);

  @override
  State<TabBarUser> createState() => _TabBarUserState();
}

class _TabBarUserState extends State<TabBarUser> {
    RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    // Show spinner for 2 seconds
    Future.delayed(const Duration(seconds: 1), () {
        isLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey, width: 0.1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              labelColor: AppColors.finSpaceColor,
              unselectedLabelColor: AppColors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: AppColors.finSpaceColor,
              tabs: [
                Tab(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Aa',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_outlined, size: 20),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.49,
            child: TabBarView(
              children: [
                Obx(()=>isLoading.value?Spinner(size: 40,): Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child:      pollWidgets(),
                )),
                 Obx(()=>isLoading.value?Spinner(size: 50,): feedWidgets()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget feedWidgets() {
    // Filter posts with postType other than "write" or "poll" (media posts)
    final validPosts = widget.userPostList
        .where((item) => item.postType.name != 'write' && item.postType.name != 'poll')
        .toList();
    final hasPosts = validPosts.isNotEmpty;

   

    if (!hasPosts) {
      return buildEmptyState('No Media Found');
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: 1,
      ),
      itemCount: validPosts.length,
      itemBuilder: (context, index) {
        var item = validPosts[index];
        // Check if image exists; otherwise, use placeholder
        String? imageUrl;
        if (item.images.isNotEmpty) {
          // Select the first valid URL from the images list
          imageUrl = item.images.first;
        }

       
        // Fallback to image field if images list is invalid or empty
        imageUrl ??=  item.image != 'none' ? item.image: null;


        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => TribeUnique(
                  id: item.id,
                  dataObj: item,
                  popBox: false.obs,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.zero,
            child: GFImageOverlay(
              width: double.infinity,
              height: double.infinity,
              boxFit: BoxFit.cover,
              image: imageUrl != null
                  ? NetworkImage(imageUrl)
                  : const AssetImage('assets/icons/maskAvatars/profileIcon11.png'), // Ensure this asset exists
              colorFilter: null,
              color: Colors.transparent,
              border: Border.all(color: AppColors.grey.withOpacity(0.1)),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
            ),
          ),
        );
      },
    );
  }

  Widget pollWidgets() {
    // Filter posts with postType "write" or "poll"
    final validPosts = widget.userPostList
        .where((PostModel item) => item.postType.name == 'write' || item.postType.name == 'poll')
        .toList();
    final hasPosts = validPosts.isNotEmpty;

  

    if (!hasPosts) {
      return buildEmptyState('No Posts Found',);
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: validPosts.length,
      itemBuilder: (context, index) {
        var item = validPosts[index];
        return PostCard(data: item, index: index);
      },
    );
  }

  Widget buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 60,
            color: AppColors.bg1.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.bg1,
            ),
          ),
          const SizedBox(height: 8),
         
        ],
      ),
    );
  }
}
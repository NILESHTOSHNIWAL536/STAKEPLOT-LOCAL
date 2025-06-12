import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';

class TabBarUser extends StatelessWidget {
  List userPostList;
  TabBarUser({Key? key, required this.userPostList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Column(
        children: [
          Container(
            // color: Colors.amber,
                      decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey, width: 0.1), // Added border
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              indicatorPadding: EdgeInsets.zero, // Ensures no extra spacing
              labelPadding: EdgeInsets.zero, // Controls padding inside tabs
              // indicator: BoxDecoration(
              //   color: AppColors.tab, // Background for selected tab
              //   borderRadius: BorderRadius.circular(12),
              // ),
              labelColor: AppColors.finSpaceColor, // Text color for selected tab
              unselectedLabelColor:
                  AppColors.grey, // Text color for unselected tabs
               indicatorSize: TabBarIndicatorSize.tab,
               indicatorColor: AppColors.finSpaceColor, // Indicator fills the tab
              tabs: [
                Tab(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4), // Adjusted for smaller size
                    decoration: BoxDecoration(
                      color:
                          Colors.transparent, // No background when unselected
                      borderRadius: BorderRadius.circular(12),
                    ),
                   child: Text('Aa',
                         style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w500,
                           
                          )),
                  ),
                ),
                
                Tab(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4), // Smaller padding
                    decoration: BoxDecoration(
                      color:
                          Colors.transparent, // No background when unselected
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.image_outlined, size: 20),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.46,
            child: TabBarView(
              children: [
                 Padding(
                 padding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
                  child: pollWidgets("poll"),
                ),
                feedWidgets("post"),
               
              ],
            ),
          ),
        ],
      ),
    );
  }
Widget feedWidgets(String type, {bool showOnlyImages = false}) {
  final validPosts = userPostList.where((item) =>(item['image']!=null || item['image']!= ""  || item['image'] != 'none')).toList();
  final hasPosts = validPosts.isNotEmpty;

  if (!hasPosts) {
    return buildEmptyState(
        'No Posts Found', 'This user hasn\'t shared any posts yet.');
  }

  if (!showOnlyImages) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        
        childAspectRatio: 1, // Square images
      ),
      itemCount: validPosts.length,
      itemBuilder: (context, index) {
        var item = validPosts[index];
        return GestureDetector(
          onTap: () {
            // Optionally, navigate to post details
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    TribeUnique(
                  id: item["_id"],
                  dataObj: item,
                  popBox:  false.obs,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
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
              // borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
              image: NetworkImage(item['image']),
              colorFilter: null,
              color: Colors.transparent,
              border: Border.all(color: AppColors.grey.withOpacity(0.1)),
              margin: EdgeInsets.zero, // Ensure GFImageOverlay has no margin
              padding: EdgeInsets.zero,
            ),
          ),
        );
      },
    );
  }

  return SingleChildScrollView(
    child: Column(
      children: [
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: validPosts.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return (item['image'] == 'none')
                  ? const SizedBox.shrink()
                  : PostCard(data: item, index: index);
            }).toList(),
          ),
        ),
        SizedBox(
          height: 100,
        ),
      ],
    ),
  );
}
  // Widget feedWidgets(String type) {
  //   // final hasPosts = userPostList.any((item) => !(item['isPoll'] ?? false));
  //    final validPosts = userPostList.where((item) => item['image'] != 'none').toList();
  //   print('Valid posts with images: ${validPosts.map((item) => item['image']).toList()}'); // Log valid images
  //   final hasPosts = validPosts.isNotEmpty; // Check if there are valid posts
  //   print('Checking for posts with images: hasPosts = $hasPosts'); // Print statement to check if there are posts with images// Print statement to check if there are posts with images
  //   if (!hasPosts) {
  //     return buildEmptyState(
  //         'No Posts Found', 'This user hasn\'t shared any posts yet.');
  //   }
  //   return SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         Container(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: validPosts.asMap().entries.map((entry) {
  //               int index = entry.key;
  //               var item = entry.value;
  //               // return (item['isPoll'] ?? false)
  //               return (item['image'] == 'none')
  //                   ? const SizedBox.shrink()
  //                   : PostCard(data: item, index: index);
  //             }).toList(),
  //           ),
  //         ),
  //         SizedBox(
  //           height: 100,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget pollWidgets(String type) {
    // final hasPolls = userPostList.any((item) => item['isPoll'] ?? false);
    final hasPolls = userPostList.any((item) => item['image'] == 'none');
    // Log whether there are polls
    if (!hasPolls) {
      return buildEmptyState(
          'No Polls Found', 'This user hasn\'t created any polls yet.');
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: Column(
              children: userPostList.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                // Log each item being processed
                // return (item['isPoll'] ?? false)
                return (item['image'] == 'none' ?? false)
                    ? PostCard(
                        data: item,
                        index:
                            index) //change here if incase anything goes wrong
                    : const SizedBox.shrink();
              }).toList(),
            ),
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon for visual appeal
          Icon(
            Icons.info_outline,
            size: 60,
            color: AppColors.bg1.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          // Title
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

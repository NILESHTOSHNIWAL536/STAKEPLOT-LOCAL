import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

class TabBarUser extends StatelessWidget {
 List userPostList;
 TabBarUser({ Key? key,required this.userPostList }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  DefaultTabController(
                    length: 2, // Number of tabs
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: TabBar(
                            indicatorPadding:
                                EdgeInsets.zero, // Ensures no extra spacing
                            labelPadding:
                                EdgeInsets.zero, // Controls padding inside tabs
                            indicator: BoxDecoration(
                              color: AppColors.tab, // Background for selected tab
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelColor: AppColors
                                .primaryColor, // Text color for selected tab
                            unselectedLabelColor:
                                AppColors.bg1, // Text color for unselected tabs
                            indicatorSize: TabBarIndicatorSize
                                .tab, // Indicator fills the tab
                            tabs: [
                              Tab(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4), // Adjusted for smaller size
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .transparent, // No background when unselected
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('Posts',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                              Tab(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4), // Smaller padding
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .transparent, // No background when unselected
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('Polls',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 1.68,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12.0),
                            child: TabBarView(
                              children: [
                                Center(child: feedWidgets("post")),
                                Center(child: pollWidgets("poll")),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
  }


   Widget feedWidgets(String type) {
  final hasPosts = userPostList.any((item) => !(item['isPoll'] ?? false));
    if (!hasPosts) {
      return buildEmptyState( 'No Posts Found', 'This user hasn\'t shared any posts yet.');
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
          child: Column(
            children: userPostList.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return (item['isPoll'] ?? false)
                  ? const SizedBox.shrink()
                  : PostCard(data: item, index: index);
            }).toList(),
          ),
        ),
          // Container(
          //   child: Column(
          //     children: userPostList
          //         .map((item) => (item['isPoll'] ?? false )
          //             ? const SizedBox.shrink()
          //             : PostCard(data: item,index: ,))
          //         .toList(),
          //   ),
          // ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget pollWidgets(String type) {
     final hasPolls = userPostList.any((item) => item['isPoll'] ?? false);
    if (!hasPolls) {
      return buildEmptyState( 'No Polls Found', 'This user hasn\'t created any polls yet.');
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: Column(
              children: userPostList.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                return (item['isPoll'] ?? false)
                    ? const SizedBox.shrink()
                    : PostCard(data: item, index: index);
              }).toList(),
            ),
          ),
          // Container(
          //     child: Wrap(
          //         children: userPostList
          //             .map((item) => (item['isPoll'] ?? false)
          //                 ? PostCard(data: item,index: ,)
          //                 : SizedBox.shrink())
          //             .toList())),
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
          // Subtitle
         
          // Optional: Subtle decorative container
          
        ],
      ),
    );
  }

}



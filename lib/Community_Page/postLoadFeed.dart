// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:get/get.dart';
// import 'package:skeletonizer/skeletonizer.dart';

// import '../Constants/colors.dart';

// class LazyLoadingList extends StatefulWidget {
//   @override
//   _LazyLoadingListState createState() => _LazyLoadingListState();
// }

// class _LazyLoadingListState extends State<LazyLoadingList> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Container(
//       color: AppColors.border,
//           width: MediaQuery.of(context).size.width,
//           child:ListView.builder(
            
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount:  postController.feedPostList.length+1,
//             itemBuilder: (context, index) {
//                if (index == postController.feedPostList.length) {
//                if (postController.hasMorePostFeed.value) {
//                     return  Obx(()=> !postController.isPostloading.value?SizedBox.shrink():  Skeletonizer(
//                         enableSwitchAnimation: true,
//                         enabled: postController.isPostloading.value,
//                         child:  PostCard(
//                           data: postController.feedPostList[index-1],
//                           index: index-1,
//                         )
//                     ));
//                   } else {
//                     return const SizedBox.shrink();
//                   }
//                 }
          
//               return Obx(() => (postController.postData[postController.feedPostList[index].id] ?? false)
//                   ? PostCard(
//                       data:  postController.feedPostList[index],
//                       index: index,
//                     )
//                   : PostCard(
//                       data:  postController.feedPostList[index],
//                       index: index,
                      
//                     ));
//             },
//           ),
//         ));
//   }


// }

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../Constants/colors.dart';

class LazyLoadingList extends StatelessWidget {
  const LazyLoadingList({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      color: AppColors.border,
      width: MediaQuery.of(context).size.width,

      /// ✅ ONLY ONE Obx
      child: Obx(() {

        final posts = postController.feedPostList;
        final isLoading = postController.isPostloading.value;
        final hasMore = postController.hasMorePostFeed.value;

        /// ⭐ Safety check (prevents index crash)
        if (posts.isEmpty) {
          return const SizedBox();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          /// +1 for loader
          itemCount: posts.length + (hasMore ? 1 : 0),

          itemBuilder: (_, index) {

            /// ✅ Loader at bottom
            if (index >= posts.length) {

              if (!isLoading) {
                return const SizedBox();
              }

              return Skeletonizer(
                enabled: true,
                enableSwitchAnimation: true,

                /// Use LAST item safely
                child: PostCard(
                  data: posts.last,
                  index: posts.length - 1,
                ),
              );
            }

            /// ✅ NORMAL POST
            final post = posts[index];

            return Text('Post ${post.id}'); // Placeholder for PostCard

            // return PostCard(
            //   key: ValueKey(post.id), // ⭐ prevents wrong rebuilds
            //   data: post,
            //   index: index,
            // );
          },
        );
      }),
    );
  }
}

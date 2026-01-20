import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../Constants/colors.dart';

class LazyLoadingList extends StatefulWidget {
  @override
  _LazyLoadingListState createState() => _LazyLoadingListState();
}

class _LazyLoadingListState extends State<LazyLoadingList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      color: AppColors.border,
          width: MediaQuery.of(context).size.width,
          child:ListView.builder(
            
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:  postController.feedPostList.length+1,
            itemBuilder: (context, index) {
               if (index == postController.feedPostList.length) {
               if (postController.hasMorePostFeed.value) {
                    return  Obx(()=> !postController.isPostloading.value?SizedBox.shrink():  Skeletonizer(
                        enableSwitchAnimation: true,
                        enabled: postController.isPostloading.value,
                        child:  PostCard(
                          data: postController.feedPostList[index-1],
                          index: index-1,
                        )
                    ));
                  } else {
                    return const SizedBox.shrink();
                  }
                }
          
              return Obx(() => (postController.postData[postController.feedPostList[index].id] ?? false)
                  ? PostCard(
                      data:  postController.feedPostList[index],
                      index: index,
                    )
                  : PostCard(
                      data:  postController.feedPostList[index],
                      index: index,
                      
                    ));
            },
          ),
        ));
  }
}


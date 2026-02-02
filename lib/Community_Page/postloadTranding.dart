import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LazyLoadingTranding extends StatefulWidget 
{
  @override
  _LazyLoadingListState createState() => _LazyLoadingListState();
}

class _LazyLoadingListState extends State<LazyLoadingTranding> {
 

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:  postController.trandingPostList.length+1,
              itemBuilder: (context, index) {
            if (index == postController.trandingPostList.length)
            {
               if (postController.hasMorePostTranding.value) {
                    return  Obx(()=> !postController.hasMorePostTranding.value?SizedBox.shrink():  Skeletonizer(
                        enableSwitchAnimation: true,
                        enabled: postController.hasMorePostTranding.value,
                        child:  PostCard(
                          data: postController.trandingPostList[index-1],
                          index: index-1,
                        )
                    ));
                  } else {
                    return const SizedBox.shrink();
                  }
                }
          
          
                return Obx(()=>(postController.postData[ postController.trandingPostList[index].id] ??false) ?   PostCard(data: postController.trandingPostList[index],index: index,) :PostCard(data:  postController.trandingPostList[index],index: index,));
              },
            ),
    ));
  }
}

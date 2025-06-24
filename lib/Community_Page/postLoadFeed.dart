import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';


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
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:  postController.feedPostList.length,
            itemBuilder: (context, index) {
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


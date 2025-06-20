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
            itemCount: getTrendingData.length,
            itemBuilder: (context, index) {
              return Obx(() => (postData[getTrendingData[index]['_id']] ?? false)
                  ? PostCard(
                      data: getTrendingData[index],
                      index: index,
                    )
                  : PostCard(
                      data: getTrendingData[index],
                      index: index,
                      
                    ));
            },
          ),
        ));
  }
}


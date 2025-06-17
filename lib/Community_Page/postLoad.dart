import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

final ScrollController scrollControllerPost = ScrollController();
final RxList displayedData = [].obs;
final int itemsPerLoad = 10;

class LazyLoadingList extends StatefulWidget {
  @override
  _LazyLoadingListState createState() => _LazyLoadingListState();
}

class _LazyLoadingListState extends State<LazyLoadingList> {
  @override
  void initState() {
    super.initState();
    // displayedData.clear();
    // loadInitialData();
    // scrollControllerPost.addListener(_onScroll);
  }

  // void _onScroll() {
  //   if (scrollControllerPost.position.pixels >=
  //       scrollControllerPost.position.maxScrollExtent * 0.9) {
  //     _loadMoreData();
  //   }
  // }

  // void _loadMoreData() {
  //   // if (displayedData.length < getTrendingData.length) {
  //   //   int nextItems = (displayedData.length + itemsPerLoad).clamp(0, getTrendingData.length);
  //   //   displayedData.addAll(getTrendingData.sublist(displayedData.length, nextItems));
  //   // }
  //   if(getTrendingData.length>5){
  //          displayedData.addAll(getTrendingData);
  //   }

  // }

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

void loadInitialData() 
{
  // displayedData.addAll(getTrendingData.take(itemsPerLoad).toList()); // Load first batch
}

void resetAndLoadData() {
  // displayedData.clear();
  // loadInitialData();
  
}

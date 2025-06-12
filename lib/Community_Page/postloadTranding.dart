import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postLoad.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

// final ScrollController scrollControllerPost2 = ScrollController();
final RxList displayedData = [].obs;
final int itemsPerLoad = 10;

class LazyLoadingTranding extends StatefulWidget 
{
  @override
  _LazyLoadingListState createState() => _LazyLoadingListState();
}

class _LazyLoadingListState extends State<LazyLoadingTranding> {
 

  @override
  void initState() {
    super.initState();
    // displayedData.clear();
    // loadInitialData();
    // scrollControllerPost.addListener(_onScroll);
  }

 

  // void _onScroll() {
  //   if (scrollControllerPost.position.pixels >= scrollControllerPost.position.maxScrollExtent * 0.9) {
  //     _loadMoreData();
  //   }
  // }

  // void _loadMoreData() {
  //   // if (displayedData.length < getAllPostData.length) {
  //   //   int nextItems = (displayedData.length + itemsPerLoad).clamp(0, getAllPostData.length);
  //   //   displayedData.addAll(getAllPostData.sublist(displayedData.length, nextItems));
  //   // }
  //    if(getAllPostData.length>5)
  //    {
  //          displayedData.addAll(getAllPostData);
  //    }
  // }


  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: getAllPostData.length,
              itemBuilder: (context, index) {
                return   Obx(()=> ( postData[getAllPostData[index]['_id']] ??false) ?   PostCard(data: getAllPostData[index],index: index,) :PostCard(data: getAllPostData[index],index: index,));
              },
            ),
    ));
  }
}

 void loadInitialData()
 {
    displayedData.addAll(getAllPostData.take(itemsPerLoad).toList()); // Load first batch
 }


void resetAndLoadData() {
  displayedData.clear();  
  loadInitialData(); 
}
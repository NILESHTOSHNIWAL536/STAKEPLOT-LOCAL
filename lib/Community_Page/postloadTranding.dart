import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

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

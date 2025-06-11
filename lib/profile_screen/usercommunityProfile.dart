import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/tabBarUser.dart';
import 'package:get/get.dart';
import 'dart:io';

class CommunityUserProfile extends StatefulWidget {
  final data;
  final List ids;
  bool flag = false;
  CommunityUserProfile(
      {Key? key, required this.data, required this.ids, this.flag = false})
      : super(key: key);

  @override
  State<CommunityUserProfile> createState() => _CommunityProfileScreenState();
}

class _CommunityProfileScreenState extends State<CommunityUserProfile> {
  TextEditingController about = TextEditingController();
  String dataReport = "";
  List getTrendingData = [];
  RxList getuerPost = [].obs;
  List frds = [];
  bool findData = true;
  RxBool finduserPost = true.obs;
  bool already = false;
  RxInt count = 0.obs;
  RxInt score = 0.obs;
  RxBool fl = false.obs;
  RxBool reload = false.obs;
  RxString buttonValue = "Add".obs;
  RxString frdRequest = "Friend Request not sent before".obs;
  RxString frdRequestCheck = "Friend Request not sent before".obs;
 
  @override
  void initState() {
    getDis();
    getStatus();
    getConnections();
  }

  void getDis() async {
    var response = await getDataApiCall(
        '${url}/post/userDiscussions/${widget.data['_id']}');

    if (getFlagOfResponse(response)) {
      var his = jsonDecode(response.body);
      var obj = his['data'];
     
      setState(() {
        getTrendingData = obj;
        findData = false;
      });
      getuerPost.clear();
      getuerPost.addAll(obj);
      getTrendingData.forEach((element) {
        postCount[element["_id"]] =
            element['upvotes'] < 0 ? 0 : element['upvotes'];
      });
    } else {}
  }

  void getConnections() async {
    var response = await getDataApiCall('${url}/user/connections/${widget.data['_id']}');

    if (getFlagOfResponse(response)) 
    {
      var his = jsonDecode(response.body);
      count.value = his['data']['connections'];
      score.value = his['data']['score'];
    } else {}
  }

  void getStatus() async {
    var response = await postDataApiCallwithOutSharedPref(
        "${url}/user/friend/acceptRequestStatus", {
      'userName': widget.data['name'],
      'friendUserId': widget.data['_id'],
    });

    if (getFlagOfResponse(response)) {
      var his = jsonDecode(response.body);
      frdRequestCheck.value = his['data'];
      if (frdRequestCheck.value == "Friend Request already sent") {
        buttonValue.value = "Requested";
      } else if (frdRequestCheck.value == "Friend Request not sent before") {
        buttonValue.value = "Add";
      } else if (frdRequestCheck.value == "User is already your friend") {
        buttonValue.value = "Remove";
      } else {
        buttonValue.value = "Accept";
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg5,
      // appBar: AppBar(),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              // Top Cover and Profile Picture
              topUserProfile(widget.data),

              // Text(widget.data['name'].toString(),
              //     style: FontManager().getTextStyle(context,
              //         lWeight: FontWeight.w600,
              //         //fontSize: MediaQuery.of(context).size.width * 0.04,
              //         //fontSize: 12,
              //         color: AppColors.bg1)),

              Column(
                children: [
                  const SizedBox(height: 10),
                  TabBarUser(userPostList: getTrendingData)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

 
  Widget topUserProfile(data) {
    return Container(
      height: MediaQuery.of(context).size.height / 5.4,
      // height: 200,
      child: Column(
        children: [
          AvatarProfile(
            name: data['name'],
            width: 5,
            height: 10,
            background: data['avatarBackGround'] ?? defaultBackGround.value,
            flag: true,
          ),
          Text(widget.data['name'].toString(),
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w600, color: AppColors.bg1)),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                networkFriends(ProfileScreenStrings().postsLabel,
                    getTrendingData.length.toString(), Icons.post_add),
                networkFriends(ProfileScreenStrings().networkLabel,
                    count.toString(), Icons.person_2_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget networkFriends(String network, String count, IconData icon) {
    return Container(
        width: MediaQuery.sizeOf(context).width / 2.4,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryColor, width: .5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textStyle(
                context: context,
                text: count.toString(),
                fontWeight: FontWeight.w500,
                c: AppColors.finSpaceColor,
                fontsize: 16),
            const SizedBox(
              width: 5,
            ),
            textStyle(
                context: context,
                text: network.toString(),
                fontWeight: FontWeight.w400,
                c: AppColors.finSpaceColor,
                fontsize: 16),
          ],
        ));
  }
}

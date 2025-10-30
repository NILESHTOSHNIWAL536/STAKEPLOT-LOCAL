import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/tabBarUser.dart';
import 'package:flutter_application_code_stakeplot/routes/route_api.dart';
import 'package:get/get.dart';
import 'dart:io';

import '../routes/route_post.dart';

class CommunityUserProfile extends StatefulWidget {
  final data;
  final List ids;
  bool flag = false;
  bool isMasked = false;
  bool isMaskedConnect = false;
  CommunityUserProfile(
      {Key? key,
      required this.data,
      required this.ids,
      this.flag = false,
      this.isMasked = false,
      this.isMaskedConnect = false})
      : super(key: key);

  @override
  State<CommunityUserProfile> createState() => _CommunityProfileScreenState();
}

class _CommunityProfileScreenState extends State<CommunityUserProfile> {
  TextEditingController about = TextEditingController();
  String dataReport = "";
  RxList<PostModel> getTrendingData = <PostModel>[].obs;
  List frds = [];
  RxBool finduserPost = true.obs;
  bool already = false;
  RxInt count = 0.obs;
  RxInt score = 0.obs;
  RxBool fl = false.obs;
  RxBool reload = false.obs;
  RxString buttonValue = "Add".obs;
  RxString frdRequest = "Friend Request not sent before".obs;
  RxString frdRequestCheck = "Friend Request not sent before".obs;
  RxString connect = ProfileScreenStrings().connected.obs;

  @override
  void initState() {
    getConnections();
    getDis();
    getStatus();
    checkName(widget.data);
  }

  void getDis() async {
    try {
      var response = await getDataApiCall(
          '${PostRoutes.userDiscussions}/${widget.data['_id']}');

      if (getFlagOfResponse(response)) {
        var his = jsonDecode(response.body);
        var obj = his['data'];
        // getTrendingData =  obj;
        getTrendingData.clear();
        getTrendingData.addAll(PostModel.listFromJson(obj));
        getTrendingData.forEach((element) {
          postController.postCount[element.id] =
              element.upvotes < 0 ? 0 : element.upvotes;
        });
      } else {}
    } catch (e) {}

    reload.value = !reload.value;
  }

  void getConnections() async {
    try {
      var response = await getDataApiCall(
          '${UserRoutes.connections}/${widget.data['_id']}/${widget.isMasked}');

      if (getFlagOfResponse(response)) {
        var his = jsonDecode(response.body);
        count.value = his['data']['connections'];
        score.value = his['data']['score'];
      } else {}
    } catch (e) {}
  }

  void getStatus() async {
    var response =
        await postDataApiCall(UserRoutes.acceptRequestStatus, {
      'userName': widget.data['name'],
      'friendUserId': widget.data['_id'],
    });

    if (getFlagOfResponse(response)) {
      var his = jsonDecode(response.body);
      frdRequestCheck.value = his['data'];
      if (frdRequestCheck.value == "Friend Request already sent") {
        buttonValue.value = "Requested";
      } else if (frdRequestCheck.value == "Friend Request not sent before") {
        buttonValue.value = "Connect";
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
              Column(
                children: [
                  const SizedBox(height: 10),
                  Obx(() => reload.value
                      ? TabBarUser(userPostList: getTrendingData)
                      : TabBarUser(userPostList: getTrendingData)),
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
          widget.isMasked
              ? AvatarProfile2(
                  url: data['avatarType'] ?? data['avatar'],
                  width: 20,
                  height: 20,
                  flag: true,
                )
              : AvatarProfile(
                  name: data['name'],
                  width: 5,
                  height: 10,
                  background:
                      data['avatarBackGround'] ?? defaultBackGround.value,
                  flag: true,
                ),
          widget.isMasked
              ? Text(
                  (widget.data['maskedName'] ?? widget.data['name']).toString(),
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w600, color: AppColors.bg1))
              : Text(widget.data['name'].toString(),
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w600, color: AppColors.bg1)),
          SizedBox(
            height: 6,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      if (!widget.isMasked) {
                        ontapConnect(data);
                      } else {
                        if (connect.value == ProfileScreenStrings().connected) {
                          connect.value = "Remove";
                          addUserAsFrd(data['_id'], context, "Masked");
                        } else {
                          getRemoveFrds(
                              context,
                              data['_id'],
                              widget.isMaskedConnect
                                  ? "connected"
                                  : "connection");
                          connect.value = ProfileScreenStrings().connected;
                        }
                        getConnections();
                        getDis();
                        getStatus();
                      }
                    },
                    child: Obx(() => networkFriends(
                        widget.isMasked
                            ? connect.value
                            : buttonValue.value == "Add"
                                ? "Connect"
                                : buttonValue.value,
                        "",
                        Icons.post_add))),
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

  void ontapConnect(data) {
    if (buttonValue.value == "Remove") {
      getRemoveFrds(context, data['_id']);
      buttonValue.value = "Add";
    } else if (buttonValue.value == "Add") {
      buttonValue.value = "Requested";
      addUsersendRequest(data['_id'], data['name'], context);
    } else if (buttonValue.value == "Requested") {
      buttonValue.value = "Add";
      removeRequest(data['_id'], data['name'], context);
    } else {
      buttonValue.value = "Remove";
      addUserAsFrd(data['_id'], context);
    }
  }

  Widget networkFriends(String network, String count, IconData icon) {
    return Container(
        // width: MediaQuery.sizeOf(context).width / 2.4,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color:
              count == "" ? AppColors.primaryColor : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryColor, width: .5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            count == ""
                ? SizedBox.shrink()
                : textStyle(
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
                c: count == ""
                    ? AppColors.backgroundColor
                    : AppColors.finSpaceColor,
                fontsize: 16),
          ],
        ));
  }

  void checkName(data) {
    if (widget.isMasked) {
      UserController userController = ControllerManagement.userController;
      String _id = data['_id'];
      bool exists =
          userController.maskedConnections.any((item) => item['_id'] == _id);
      if (exists) {
        connect.value = "Remove";
      }
    }
  }
}

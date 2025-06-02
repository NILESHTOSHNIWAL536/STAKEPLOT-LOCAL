import 'dart:convert';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/resportHide.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_share.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import 'package:http/http.dart' as http;
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";


List postListIds = [];
bool findData = true;
bool findTranding = true;
RxInt indexFlag = 0.obs;
RxBool  isPost = false.obs;
RxBool  isPostTranding = false.obs;
RxBool  isTrending = false.obs;

Widget noFriend(context, [text = ""]) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, "/TribeSearch");
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            AvatarProfileImage(
              url: ProfileIcons.emptyFrnds,
              height: 4,
              width: 4,
            ),
            const SizedBox(
              height: 30,
            ),
            textStyle(context: context, text: text),
          ],
        ),
      ),
    ),
  );
}

Widget popUpBox(id, context) {
  return PopupMenuButton(
    initialValue: 2,
    color: Colorcodes.appBarColor,
    child: Center(
        child: Icon(
      Icons.more_vert_outlined,
      size: 25,
      color: Colorcodes.white,
    )),
    onSelected: (value) {
      if (value == 1) {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return showModel(context, id);
          },
        );
      } else {
        reportPost(context, id, "hide post","hide",0);
      }
    },
    itemBuilder: (context) {
      return [
        const PopupMenuItem(
          value: 0,
          child: Text("hide"),
        ),
        const PopupMenuItem(
          value: 1,
          child: Text("Report"),
        ),
      ];
    },
  );
}

Widget vote(context, dataObj, data) {
  String idData = dataObj["_id"];
  String likeKey = "liked" + dataObj["_id"];
  bool isLiked = likedList.contains(likeKey);
  return Obx(() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      String likeKey = "liked" + dataObj["_id"];
                      bool isLiked = likedList.contains(likeKey);

                      // Toggle like status
                      if (isLiked) {
                        likedList.remove(likeKey);
                        postCount[idData] = postCount[idData]! - 1;
                        if (postCount[idData]! < 0) {
                          postCount[idData] = 0;
                        }
                      } else {
                        likedList.add(likeKey);
                        postCount[idData] = postCount[idData]! + 1;
                      }

                      // Update the server with new vote status
                      upvoteGlobal(context, "Post", dataObj["_id"], dataObj);
                      reRender.value = !reRender.value;
                    },
                    child: likeIcon(
                        context, likedList.contains("liked" + dataObj["_id"])),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      reRender.value
                          ? postCount[dataObj['_id']]! < 0
                              ? '0'
                              : (postCount[dataObj['_id']].toString())
                          : (postCount[dataObj['_id']].toString()),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w400,
                          fontSize: 20,
                          color: AppColors.bg1),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        Container(
                            height: 22,
                            child: SvgPicture.asset(
                              LikeComment.comments,
                              height: 22,
                            )),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          postCommentCount[idData].toString() == 'null'
                              ? dataObj["comments"].toString()
                              : postCommentCount[idData].toString(),
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w400,
                              fontSize: 20,
                              color: AppColors.likesharecommentCount),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: AppColors.backgroundColor,
                          builder: (context) {
                            return TribeShare(data: data, dataObj: dataObj);
                          },
                        );
                      },
                      child: SvgPicture.asset(
                        LikeComment.share,
                        height: 22,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ));
}

// Helper function to get the appropriate icon based on like status
// Helper function to get the appropriate SVG based on like status
Widget likeIcon(BuildContext context, bool isLiked) {
  return AnimatedContainer(
    width: 50,
   // color: Colors.green,
    duration: const Duration(milliseconds: 300), // Animation duration
    curve: Curves.easeInOut, // Animation curve
    height: isLiked ? 24 : 22, // Change height on like
    child: SvgPicture.asset(
      isLiked
          ? LikeComment.likeIcon2
          : LikeComment.likeIcon, // Path to your outlined heart SVG
    ),
  );
}

void upvoteGlobal(context, String str, String objectId, dataObj) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.post(
    Uri.parse('${url}/upvote/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'onModel': str.toString(),
      'objectId': objectId,
    }),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);

    if (!postListIds.contains(objectId)) {
      dataObj["upvotes"]++;
      postListIds.add(objectId);
    } else {
      dataObj["upvotes"]--;
      postListIds.remove(objectId);
    }
  }
}

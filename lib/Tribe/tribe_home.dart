import "package:flutter/material.dart";
import 'package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/resportHide.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_share.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/repository/post.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';

import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/routes/route_post.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/Constants/colorcodes.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";

import '../Constants/core/app_padding_sizes.dart';
import '../components/shared_utils.dart';

List postListIds = [];
bool findData = true;
bool findTranding = true;
RxInt indexFlag = 0.obs;
// RxBool isPost = false.obs;
// RxBool isPostTranding = false.obs;
// RxBool isTrending = false.obs;

Widget noFriend(
  context, [
  text = "",
  bool isMasked = false,
]) {
  UserController userController = ControllerManagement.userController;
  return GestureDetector(
    onTap: () {
      if (userController.friendsList.isEmpty) {
        if (isMasked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TribeSearch(
                isMasked: true,
              ),
            ),
          );
        } else
          Navigator.pushNamed(context, '/TribeSearch');
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p20),
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
      color: AppColors.backgroundColor,
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
        reportPost(context, id, "hide post", "hide", 0);
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

Widget vote(context, PostModel dataObj, data) {
  String idData = dataObj.id;
  return Padding(
      padding: const EdgeInsets.only(left: AppSizes.p16, right: AppSizes.p28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (dataObj.postType.name == "poll")
            Text(
              '${dataObj.pollData!.options.fold<int>(0, (sum, o) => sum + o.votes.length)} votes',
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w400,
                  fontSize: 12,
                  color: AppColors.primaryColor,
                  lineHeight: 20 / fontSize),
            ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() {
                String likeKey = "liked${dataObj.id}";
                bool isLiked = userController.likedPosts.contains(likeKey);
                int count = postController.postCount[idData] ?? dataObj.upvotes;

                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    if (userController.maskedName.value.trim().isEmpty) {
                      MaskedNameDialogBox.showMaskedNameDialog(context);
                      return;
                    }

                    if (isLiked) {
                      userController.likedPosts.remove(likeKey);
                      postController.postCount[idData] =
                          count <= 0 ? 0 : count - 1;
                    } else {
                      userController.likedPosts.add(likeKey);
                      postController.postCount[idData] = count + 1;
                    }

                    upvoteGlobal(context, "Post", dataObj.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: AppSizes.p6),
                    decoration: BoxDecoration(
                      color: isLiked
                          ? const Color(0xFFFFF1F2)
                          : AppColors.primaryColorOpacity,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isLiked
                              ? Icons.favorite
                              : Icons.favorite_border_rounded,
                          size: 20,
                          color: isLiked
                              ? AppColors.redColor
                              : AppColors.primaryColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          (postController.postCount[idData] ?? dataObj.upvotes)
                              .clamp(0, 999999)
                              .toString(),
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(width: AppSizes.w10),
              SizedBox(
                // color: Colors.green,
                width: MediaQuery.sizeOf(context).width / 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                        onTap: () {
                          if (userController.maskedName.value.trim().isEmpty) {
                            MaskedNameDialogBox.showMaskedNameDialog(context);
                          } else {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: AppColors.unSelectedOption,
                              builder: (context) {
                                return TribeShare(data: data, dataObj: dataObj);
                              },
                            );
                          }
                        },
                        child: AvatarProfileImageZero(
                            url: LikeComment.sharePost, width: 40, height: 34)),
                    SizedBox(width: AppSizes.w12),
                    Obx(() {
                      bool isSaved =
                          userController.savedPostIds.contains(dataObj.id);
                      return GestureDetector(
                          onTap: () {
                            if (userController.maskedName.value
                                .trim()
                                .isEmpty) {
                              MaskedNameDialogBox.showMaskedNameDialog(context);
                            } else {
                              if (isSaved) {
                                userController.savedPostIds.remove(dataObj.id);
                              } else {
                                userController.savedPostIds.add(dataObj.id);
                              }
                              savePostData(context, data);
                            }
                          },
                          child: AvatarProfileImageZero(
                              url: isSaved
                                  ? LikeComment.savedPost
                                  : LikeComment.savePost,
                              width: 40,
                              height: 34));
                    }),
                  ],
                ),
              )
            ],
          ),
        ],
      ));
}

// Helper function to get the appropriate SVG based on like status
Widget likeIcon(BuildContext context, bool isLiked) {
  return AnimatedContainer(
      width: 30,
      duration: const Duration(milliseconds: 300), // Animation duration
      curve: Curves.easeInOut, // Animation curve
      height: isLiked ? 28 : 26, // Change height on like
      child: !isLiked
          ? SvgPicture.asset(
              LikeComment.likeBulb, // Path to your outlined heart SVG
            )
          : SvgPicture.asset(
              LikeComment.likedBulb, //
            ));
}

void upvoteGlobal(context, String str, String objectId, [dataObj]) async {
  final response = await postDataApiCall(UpvoteRoute.upvote, {
    'onModel': str.toString(),
    'objectId': objectId,
  });
  if ((response.statusCode == 200 || response.statusCode == 201) &&
      dataObj is Map) {
    if (!postListIds.contains(objectId)) {
      dataObj["upvotes"]++;
      postListIds.add(objectId);
    } else {
      dataObj["upvotes"]--;
      postListIds.remove(objectId);
    }
  }
}

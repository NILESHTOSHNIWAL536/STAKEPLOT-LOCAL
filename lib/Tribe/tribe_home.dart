import 'dart:convert';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/resportHide.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_share.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/repository/post.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/routes/route_post.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/Constants/colorcodes.dart";
import 'package:http/http.dart' as http;
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";

import '../Constants/core/app_padding_sizes.dart';

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
        padding: const EdgeInsets.only(left:AppSizes.p16, right:AppSizes.p28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (dataObj.postType.name == "poll")
  Text(
    '${dataObj.pollData!.options.fold<int>(0, (sum, o) => sum + o.votes.length)} votes',
    style: FontManager().getTextStyle(
      context,
      lWeight: FontWeight.w400,
      fontSize: 12,
      color: AppColors.primaryColor,
      lineHeight: 20/fontSize
    ),
  ),

            Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                // Container(
                //   child: Row(
                //     children: [
                //       Obx(() {
                //         String likeKey = "liked" + dataObj.id;
                //         bool isLiked = userController.likedPosts.contains(likeKey);
            
                //         return GestureDetector(
                //           onTap: () {
                //             if (userController.maskedName.value.trim().isEmpty) {
                //               MaskedNameDialogBox.showMaskedNameDialog(context);
                //             } else {
                //               if (isLiked) {
                //                 userController.likedPosts.remove(likeKey);
                //                 postController.postCount[idData] =
                //                     postController.postCount[idData]! - 1;
                //                 if (postController.postCount[idData]! < 0) {
                //                   postController.postCount[idData] = 0;
                //                 }
                //               } else {
                //                 userController.likedPosts.add(likeKey);
                //                 postController.postCount[idData] =
                //                     postController.postCount[idData]! + 1;
                //               }
            
                //               // Update the server with new vote status
                //               upvoteGlobal(context, "Post", dataObj.id, dataObj);
                //               reRender.value = !reRender.value;
                //             }
                //           },
                //           child: likeIcon(context, isLiked),
                //         );
                //       }),
                //       Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 5.0),
                //         child: Text(
                //           reRender.value
                //               ? postController.postCount[dataObj.id]! < 0
                //                   ? '0'
                //                   : (postController.postCount[dataObj.id]
                //                       .toString())
                //               : (postController.postCount[dataObj.id].toString()),
                //           style: FontManager().getTextStyle(context,
                //               lWeight: FontWeight.w400,
                //               fontSize: 16,
                //               color: AppColors.bg1),
                //         ),
                //       ),
                //       SizedBox(width: 4),
                //       InkWell(
                //         onTap: () {
                //           if (userController.maskedName.value.trim().isEmpty) {
                //             MaskedNameDialogBox.showMaskedNameDialog(context);
                //           } else {
                //             showModalBottomSheet(
                //               context: context,
                //               backgroundColor: AppColors.commentbg,
                //               isScrollControlled: true,
                //               builder: (context) {
                //                 return Container(
                //                   padding:
                //                       const EdgeInsets.symmetric(vertical: AppSizes.p16),
                //                   width: MediaQuery.sizeOf(context).width,
                //                   decoration: BoxDecoration(
                //                       color: AppColors.commentbg,
                //                       borderRadius: BorderRadius.only(
                //                           topLeft: Radius.circular(36),
                //                           topRight: Radius.circular(36))),
                //                   child: TribeUnique(
                //                     id: dataObj.id,
                //                     dataObj: dataObj,
                //                     popBox: true.obs,
                //                   ),
                //                 );
                //               },
                //             );
                //           }
                //         },
                //         child: Container(
                //           padding: EdgeInsets.symmetric(horizontal: 8, vertical: AppSizes.p6),
                //           child: Row(
                //             children: [
                //               Container(
                //                   height: 24,
                //                   child: SvgPicture.asset(
                //                     LikeComment.commentPost,
                //                     height: 24,
                //                   )),
                //               const SizedBox(
                //                 width: 6,
                //               ),
                //               Text(
                //                 postController.postCommentCount[idData]
                //                             .toString() ==
                //                         'null'
                //                     ? dataObj.comments.toString()
                //                     : postController.postCommentCount[idData]
                //                         .toString(),
                //                 style: FontManager().getTextStyle(context,
                //                     lWeight: FontWeight.w400,
                //                     fontSize: 16,
                //                     color: AppColors.likesharecommentCount),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                
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
                        child:AvatarProfileImageZero(url: 
                                  
                                   LikeComment.sharePost, width: 40, height: 34)
                      ),
                        SizedBox(width: AppSizes.w12),
                      Obx(() {
                        bool isSaved =
                            userController.savedPostIds.contains(dataObj.id);
                        return GestureDetector(
                            onTap: () {
                              if (userController.maskedName.value.trim().isEmpty) {
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
                            child:AvatarProfileImageZero(url: isSaved
                                  ? LikeComment.savedPost
                                  : LikeComment.savePost, width: 40, height: 34)
                           
                            );
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

void upvoteGlobal(context, String str, String objectId, dataObj) async {
  
  final response = await postDataApiCall(UpvoteRoute.upvote,
      {
      'onModel': str.toString(),
      'objectId': objectId,
    }
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

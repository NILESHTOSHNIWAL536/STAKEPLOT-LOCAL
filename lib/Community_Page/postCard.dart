import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/exploreCard.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/pollDisplay.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/pop-up-menu.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/readmore.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';

class ChartData {
  ChartData(this.x, this.y, [this.color, this.name]);
  final String x;
  final double y;
  final Color? color;
  final String? name;
}

class PostCard extends StatelessWidget {
  var data;
  bool flag = false;
  int index;
  bool isTribeOne = false;
  PostCard(
      {Key? key,
      required this.data,
      this.flag = false,
      required this.index,
      this.isTribeOne = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return uploadData(data, flag, context);
  }
  // Determine image height based on crop shape

  Widget uploadData(dataObj, bool flag, BuildContext context) {
    bool isExploria = dataObj['postType'] == "exploria";
    bool isPoll = dataObj['postType'] == "poll";
    bool isWrite = dataObj['postType'] == "write";
    bool isImage = dataObj['postType'] == "image";
    var extractdata = dataObj;
    String idData = dataObj["_id"];
  String likeKey = "liked" + dataObj["_id"];
    double getImageHeight(BuildContext context) {
      double width = MediaQuery.of(context).size.width;
      bool isSquare = dataObj['isSquareImage'] ?? false; // Default to Rectangle
      return isSquare ? width : width * 214 / 402;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Column(
        children: [
          GestureDetector(
            onDoubleTap: (){
              if (maskedName.value.trim().isEmpty) {
                        MaskedNameDialogBox.showMaskedNameDialog(context);
                      } else {
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
                      }
            },
            
            onTap: flag
                ? null
                : () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TribeUnique(
                          id: dataObj["_id"],
                          dataObj: dataObj,
                          popBox: false.obs,
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 0, bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              AvatarProfile2(
                                  url: dataObj["author"]['avatarType'],
                                  width: 20,
                                  height: 20),
                              const SizedBox(width: 3),
                              Text(
                                (dataObj["author"]['maskedName'] ??
                                    dataObj["author"]['name']),
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.bg1),
                              ),
                            ],
                          ),
                        ),
                        maskedName.value.trim().isEmpty
                            ? SizedBox.shrink()
                            : popUpBoxHideDelete(
                                dataObj['_id'],
                                context,
                                dataObj["author"]['name'],
                                index,
                                flag,
                                isTribeOne),
                      ],
                    ),
                  ),
                  // Exploria Post UI
                  isExploria
                      ? ExploreCard(
                          extractdata: extractdata,
                          dataObj: dataObj,
                        )
                      : isPoll &&
                              dataObj['pollData'] != null &&
                              dataObj['pollData']['question'] != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 14.0, right: 12.0),
                              child: Text(
                                dataObj['pollData']['question'],
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: AppColors.bg1),
                              ),
                            )
                          : isWrite
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 14.0, right: 27.0),
                                  child: Text(
                                    (dataObj['title']),
                                    style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: AppColors.bg1),
                                  ),
                                )
                              : SizedBox.shrink(),

                  // Image Section (Exploria or Others)
                  isExploria
                      ? SizedBox.shrink()
                      : dataObj['image'] != null &&
                              (dataObj['image'] != "none" &&
                                  dataObj['image'] != "")
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: Colorcodes.borderRadius / 3),
                              child: Center(
                                child: GFImageOverlay(
                                  width: MediaQuery.of(context).size.width,

                                  height: getImageHeight(context),
                                  boxFit: BoxFit.fill,
                                  image: NetworkImage(dataObj['image']),
                                  colorFilter: null, // Disable any color tint
                                  color: Colors.transparent,
                                ),
                              ),
                            )
                          : isExploria &&
                                  dataObj['backGroundPicture'] != null &&
                                  dataObj['backGroundPicture'] != ""
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: Colorcodes.borderRadius),
                                  child: Center(
                                    child: GFImageOverlay(
                                      width: MediaQuery.of(context).size.width,
                                      height: getImageHeight(context),
                                      boxFit: BoxFit.fill,
                                      image: NetworkImage(
                                          dataObj['backGroundPicture']),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.6),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                  // Content for Non-Exploria Posts
                  !isExploria
                      ? isPoll
                          ? Padding(
                              padding: EdgeInsets.only(left: 12.0, right: 12.0),
                              child: getQuestionsAndOptions(dataObj['pollData'],
                                  context, true, dataObj['_id']),
                            )
                          : Container(
                              padding: !isImage
                                  ? const EdgeInsets.only(
                                      left: 14.0, right: 27.0)
                                  : EdgeInsets.only(left: 0.0, right: 0.0),
                              child: isImage
                                  ? vote(context, dataObj, dataObj)
                                  : text(dataObj),
                            )
                      : SizedBox.shrink(),
                  Padding(
                    padding: isImage
                        ? const EdgeInsets.only(left: 10.0, right: 27.0)
                        : EdgeInsets.only(left: 0.0, right: 0.0),
                    child: !isImage
                        ? vote(context, dataObj, dataObj)
                        : text(
                            dataObj,
                          ),
                  ),
                  if (dataObj['tags'] != null && dataObj['tags'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: dataObj['tags']
                              .map<Widget>((tag) => Container(
                                    margin: const EdgeInsets.only(
                                        right:
                                            6.0), // spacing between containers
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.finSpaceColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tag,
                                      style: FontManager().getTextStyle(
                                        context,
                                        lWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: AppColors.backgroundColor,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),

                  if (dataObj['createdAt'] != null)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 14.0, right: 27.0, top: 6, bottom: 10),
                      child: Text(
                        formatDateToIST(dataObj['createdAt']),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w400,
                            fontSize: 10,
                            color: AppColors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Divider(
            color: AppColors.unSelectedOption,
            thickness: 0.8,
          ),
        ],
      ),
    );
  }

  Widget text(item) {
    try {
      return Readmore(
        str: item['description']['message'].toString(),
        tName: (item['image'] != 'none' && item["postType"] == "feed")
            ? item["author"]['maskedName'] ?? item["author"]['name']
            : "",
      );
    } catch (e) {
      return Readmore(
        str: item['description'].toString(),
        tName: (item['image'] != 'none' && item["postType"] == "feed")
            ? item["author"]['maskedName'] ?? item["author"]['name']
            : "",
      );
    }
  }

  String formatDateToIST(String dateStr) {
    try {
      // Parse input date
      DateTime utcDate = DateTime.parse(dateStr).toUtc();

      // Convert to IST (UTC+5:30)
      DateTime istDate = utcDate.add(Duration(hours: 5, minutes: 30));

      // Get hour in 12-hour format
      int hour = istDate.hour % 12 == 0 ? 12 : istDate.hour % 12;
      String minute = istDate.minute.toString().padLeft(2, '0');
      String period = istDate.hour >= 12 ? 'PM' : 'AM';
      String month = _getMonthAbbreviation(istDate.month);

      return "$hour:$minute $period · $month ${istDate.day}, ${istDate.year}";
    } catch (e) {
      return dateStr; // Return original if parsing fails
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }
}

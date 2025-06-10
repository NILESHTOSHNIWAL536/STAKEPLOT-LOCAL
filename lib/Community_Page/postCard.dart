import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/exploreCard.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/pollDisplay.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/pop-up-menu.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/readmore.dart';
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
  PostCard(
      {Key? key, required this.data, this.flag = false, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return uploadData(data, flag, context);
  }

  Widget uploadData(dataObj, bool flag, BuildContext context) {
    bool isExploria = dataObj['postType'] == "exploria";
    bool isPoll = dataObj['postType'] == "poll";
    bool isWrite = dataObj['postType'] == "write";
    bool isImage = dataObj['postType'] == "image";
    var extractdata = dataObj;
    print('isPoll: $isPoll');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      
      child: Column(
        children: [

          GestureDetector(
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
  //               border: Border(
   
  //   bottom: BorderSide(
  //     color: Colors.grey.shade400,
  //     width: 4.0,          // Thickness of the bottom border
  //   ),
  // ),
                // borderRadius:
                //     BorderRadius.circular(Colorcodes.borderRadius)
              ),
              
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 27.0, top: 0, bottom: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Container(
                                //  color: Colors.green,
                                child: AvatarProfile(
                                  name: (dataObj["author"]['maskedName'] ??
                                      dataObj["author"]['name']),
                                  width: 11,
                                  height: 21,
                                  background: dataObj["author"]
                                          ['avatarBackGround'] ??
                                      defaultBackGround.value,
                                  flag: true,
                                ),
                              ),
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
                              ),
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
                                  left: 10.0, right: 27.0),
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
                                  height: MediaQuery.of(context).size.width *
                                      214 /
                                      402,
                                  boxFit: BoxFit.fill,
                                  // borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
                                  image: NetworkImage(dataObj['image']),
                                  colorFilter: null, // Disable any color tint
                                  color: Colors.transparent,
                                  border: Border.all(color: AppColors.bg5),
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
                                      width: MediaQuery.of(context).size.width /
                                          1.2,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3,
                                      boxFit: BoxFit.fill,
                                      borderRadius: BorderRadius.circular(
                                          Colorcodes.borderRadius),
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
                              padding: EdgeInsets.only(left: 27.0, right: 27.0),
                              child: getQuestionsAndOptions(dataObj['pollData'],
                                  context, true, dataObj['_id']),
                            )
                          : Container(
                              // padding: const EdgeInsets.only(left: 27.0, right: 27.0),
                              // child: !dataObj['isItenary']
                              // ? text(dataObj):SizedBox.shrink()
                              padding:!isImage
                                  ? const EdgeInsets.only(
                                      left: 14.0, right: 27.0)
                                  : EdgeInsets.only(left: 0.0, right: 0.0),
                              // child: !dataObj['isItenary']
                              // ? text(dataObj):SizedBox.shrink()
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
                        : text(dataObj),
                  ),
                 
                  if (dataObj['createdAt'] != null)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 27.0, right: 27.0, top: 4),
                      child: Text(
                        formatDateToIST(dataObj['createdAt']),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w400,
                            fontSize: 9,
                            color: AppColors.bg3),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget text(item) {
    try {
      return Readmore(str: item['description']['message'].toString());
    } catch (e) {
      return Readmore(str: item['description'].toString());
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

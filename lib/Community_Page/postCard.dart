import "package:flutter/material.dart";
import 'package:flutter_application_code_stakeplot/Community_Page/exploreCard.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/pollDisplay.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/pop-up-menu.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/components/readmore.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';

import '../Constants/core/app_padding_sizes.dart';

class ChartData {
  ChartData(this.x, this.y, [this.color, this.name]);
  final String x;
  final double y;
  final Color? color;
  final String? name;
}

class PostCard extends StatelessWidget {
  PostModel data;
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

  Widget uploadData(PostModel dataObj, bool flag, BuildContext context) {
    final colors = context.appColors;
    bool isExploria = dataObj.postType.name == "exploria";
    bool isPoll = dataObj.postType.name == "poll";
    bool isWrite = dataObj.postType.name == "write";
    bool isImage = dataObj.postType.name == "image";
    bool isHidden = dataObj.isHidden || dataObj.visibilityStatus == "hidden";
    var extractdata = dataObj;
    double getImageHeight(BuildContext context) {
      double width = MediaQuery.of(context).size.width;
      bool isSquare = dataObj.isSquareImage; // Default to Rectangle
      return isSquare ? width : width * 214 / 402;
    }

    return Padding(
      padding:const EdgeInsets.symmetric(vertical: AppSizes.p8, horizontal: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: AppSizes.p8, horizontal: AppSizes.w4),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.border,
                width: 1,
              ),
              boxShadow: context.isDarkMode
                  ? []
                  : const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.10),
                        offset: Offset(0, 4),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.10),
                        offset: Offset(0, 10),
                        blurRadius: 15,
                        spreadRadius: 0,
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: AppSizes.p20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: dataObj.tag.isNotEmpty
                            ? SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: dataObj.tag.map<Widget>((tag) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          right: AppSizes.p6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: AppSizes.p4),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tag,
                                        style: FontManager().getTextStyle(
                                          context,
                                          lWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: colors.primary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      // if (isHidden) ...[
                      //   _hiddenBadge(context, dataObj),
                      //   const SizedBox(width: AppSizes.w8),
                      // ],
                      ControllerManagement.userController.maskedName.value
                              .trim()
                              .isEmpty
                          ? const SizedBox.shrink()
                          : popUpBoxHideDelete(
                              dataObj.id,
                              context,
                              dataObj.author.name,
                              index,
                              flag,
                              isTribeOne,
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
                            dataObj.pollData != null &&
                            dataObj.pollData!.question != null
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: AppSizes.p14, right: AppSizes.p12),
                            child: Text(
                              dataObj.pollData!.question.toString(),
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: colors.onSurface),
                            ),
                          )
                        : isWrite
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: AppSizes.p14, right: 27.0),
                                child: Text(
                                  (dataObj.title),
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: colors.onSurface),
                                ),
                              )
                            : SizedBox.shrink(),

                // Image Section (Exploria or Others)
                isExploria
                    ? SizedBox.shrink()
                    : (dataObj.image != "none" && dataObj.image != "")
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: Colorcodes.borderRadius / 3),
                            child: Center(
                              child: GFImageOverlay(
                                width: MediaQuery.of(context).size.width,

                                height: getImageHeight(context),
                                boxFit: BoxFit.fill,
                                image: NetworkImage(dataObj.image),
                                colorFilter: null, // Disable any color tint
                                color: AppColors.transparentColor,
                              ),
                            ),
                          )
                        // : isExploria &&
                        //         dataObj['backGroundPicture'] != null &&
                        //         dataObj['backGroundPicture'] != ""
                        //     ? Padding(
                        //         padding: EdgeInsets.symmetric(
                        //             vertical: Colorcodes.borderRadius),
                        //         child: Center(
                        //           child: GFImageOverlay(
                        //             width: MediaQuery.of(context).size.width,
                        //             height: getImageHeight(context),
                        //             boxFit: BoxFit.fill,
                        //             image: NetworkImage(
                        //                 dataObj.backGroundPicture),
                        //             child: Container(
                        //               decoration: BoxDecoration(
                        //                 gradient: LinearGradient(
                        //                   begin: Alignment.bottomCenter,
                        //                   end: Alignment.topCenter,
                        //                   colors: [
                        //                     AppColors.accentColor.withOpacity(0.6),
                        //                     Colors.transparent,
                        //                   ],
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       )
                        : SizedBox.shrink(),
                // Content for Non-Exploria Posts
                !isExploria
                    ? isPoll
                        ? Padding(
                            padding: EdgeInsets.only(
                                left: AppSizes.p12, right: AppSizes.p12),
                            child: getQuestionsAndOptions(
                                dataObj.pollData, context, true, dataObj.id),
                          )
                        : Container(
                            padding: !isImage
                                ? const EdgeInsets.only(
                                    left: AppSizes.p14, right: 27.0)
                                : EdgeInsets.only(left: 0.0, right: 0.0),
                            child: isImage
                                ? vote(context, dataObj, dataObj)
                                : text(dataObj),
                          )
                    : SizedBox.shrink(),
                Padding(
                  padding: isImage
                      ? const EdgeInsets.only(left: AppSizes.p10, right: 27.0)
                      : EdgeInsets.only(left: 0.0, right: 0.0),
                  child: !isImage
                      ? vote(context, dataObj, dataObj)
                      : text(
                          dataObj,
                        ),
                ),
                const SizedBox(height: AppSizes.p10),
                if (dataObj.createdAt != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: AppSizes.p14,
                            right: 27.0,
                            top: AppSizes.p6,
                            bottom: 10),
                        child: Text(
                          formatDateToIST(dataObj.createdAt.toString()),
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w400,
                              fontSize: 10,
                              color: colors.secondaryText),
                        ),
                      ),
                      if (isHidden) ...[
                        // const SizedBox(width: AppSizes.w8),
                        _hiddenBadge(context, dataObj),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          Divider(
            color: colors.divider,
            thickness: 0.8,
          ),
        ],
      ),
    );
  }

  Widget _hiddenBadge(BuildContext context, PostModel dataObj) {
    final colors = context.appColors;
    final label =
        dataObj.visibilityLabel.isNotEmpty ? dataObj.visibilityLabel : "Hidden";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colors.error.withOpacity(context.isDarkMode ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.error.withOpacity(0.45), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_off_rounded,
            size: 13,
            color: colors.error,
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 112),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w700,
                fontSize: 10,
                color: colors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget text(PostModel item) {
    try {
      return Readmore(
        str: item.description['message'].toString(),
        tName: (item.image != 'none' && item.postType.name == "feed")
            ? item.author.maskedName != ''
                ? item.author.maskedName
                : item.author.name
            : "",
        isImage: item.image != 'none',
      );
    } catch (e) {
      return Readmore(
        str: item.description.toString(),
        tName: (item.image != 'none' && item.postType.name == "feed")
            ? item.author.maskedName != ''
                ? item.author.maskedName
                : item.author.name
            : "",
        isImage: item.image != 'none',
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

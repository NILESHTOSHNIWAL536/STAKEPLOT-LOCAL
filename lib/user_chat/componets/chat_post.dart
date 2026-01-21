import 'dart:async';
import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/repository/post.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/user_chat/message.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../components/shared_utils.dart';


Widget uploadData(String dataObj2, Message message,BuildContext context) {
  PostModel dataObj = PostModel.fromJson(jsonDecode(dataObj2));
  bool isExploria =dataObj.postType.name == "exploria";
  bool isPoll =  dataObj.postType.name == "poll";
  bool isImage = dataObj.postType.name == "image";
  bool isWrite = dataObj.postType.name == "write";

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSizes.p6, horizontal: 8),
    child: GestureDetector(
      onTap: () async{
        getpost(dataObj.id);
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            duration: Durations.long1,
            child: TribeUnique(
              id: dataObj.id,
              dataObj: dataObj,
              popBox: false.obs,

            ),
            isIos: true,
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.4,
        padding: const EdgeInsets.all(AppSizes.p12),
        decoration: BoxDecoration(
          color: AppColors.mt,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: message.isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Section
            Row(
              children: [
                
               
                Expanded(
                  child: Text(
                    (dataObj.author.maskedName==''?  dataObj.author.name: dataObj.author.maskedName),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 15,
                      color:  AppColors.bg1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
             SizedBox(height: AppSizes.h10),
            // Content Preview
            if (isPoll && dataObj.pollData != null && dataObj.pollData!.question!= null)
              Text(
                "${dataObj.pollData!.question}?",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 14,
                  color:  AppColors.bg1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (isWrite)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dataObj.title.isNotEmpty)
                    Text(
                      dataObj.title,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w600,
                        fontSize: 14,
                        color:  AppColors.bg1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (dataObj.title.isNotEmpty) const SizedBox(height: 6),
                  Text(
                    (dataObj.description is Map ? dataObj.description.message : dataObj.description),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 13,
                      color: AppColors.bg1.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            if (isImage)
              Text(
                (dataObj.description is Map ? dataObj.description.message : dataObj.description) ?? '',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 13,
                  color: AppColors.bg1.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (isExploria)
              Text(
                (dataObj.description is Map ? dataObj.description.message : dataObj.description) ?? '',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 13,
                  color: AppColors.bg1.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            // Image Thumbnail (if applicable)
            if (isImage &&  dataObj.image != "none" && dataObj.image != "")
              Padding(
                padding: const EdgeInsets.only(top:AppSizes.p10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                   dataObj.image,
                    width: MediaQuery.of(context).size.width / 1.6,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: MediaQuery.of(context).size.width / 1.6,
                      height: 120,
                      color: AppColors.grey.withOpacity(0.2),
                      child:  Icon(Icons.error, size: 40, color: AppColors.grey),
                    ),
                  ),
                ),
              ),
            if (isExploria && dataObj.images != null && dataObj.images.isNotEmpty && dataObj.images[0] != "none" && dataObj.images[0] != "")
              Padding(
                padding: const EdgeInsets.only(top:AppSizes.p10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    dataObj.images[0],
                    width: MediaQuery.of(context).size.width / 1.6,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: MediaQuery.of(context).size.width / 1.6,
                      height: 120,
                      color: AppColors.grey.withOpacity(0.2),
                      child:  Icon(Icons.error, size: 40, color: AppColors.grey),
                    ),
                  ),
                ),
              ),
            // Tags (Show only one or hint)
            if (dataObj.tag.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top:AppSizes.p8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: AppSizes.p4),
                  decoration: BoxDecoration(
                    color: AppColors.finSpaceColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "#${dataObj.tag[0]}",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 12,
                      color: AppColors.finSpaceColor,
                    ),
                  ),
                ),
              ),
            // Timestamp
            if (dataObj.createdAt.toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top:AppSizes.p8),
                child: Text(
                  formatDateToIST(dataObj.createdAt.toString()),
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 11,
                    color: AppColors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}


  Widget postDisplay(msg, bool, url, Message message,BuildContext context) {
    return  Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               uploadData((message.post), message,context),
            ],
          );
  }
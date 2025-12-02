import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/user_chat/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:get/get.dart';


Widget getQuestionsAndOptions(PollModel? e, context, flag, PostId) {
  String id = userController.userId.value;
  List<PollOptionModel>  options = e!.options;

  int index = -1;
  String s = "";
  for (int i = 0; i < options.length; i++) {
    List votesArray = options[i].votes;
    bool vote = votesArray.contains(id);
    if (vote) {
      index = i;
      s = options[i].option;
      break;
    }
  }
  RxBool myvote = (index != -1).obs;

  int len = 0;

  options.forEach((element) {
    List ll = element.votes;
    len = len + ll.length;
  });

  RxList<PollOptionModel> optionsList = <PollOptionModel>[].obs;

  optionsList.addAll(options);
  int indexVal = -1;
  double width = MediaQuery.of(context).size.width;

  return Obx(() => Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
             
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              width: width <= 500 ? width / 1.2 : width / 1.2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: optionsList.map((op) {
                        List ll = op.votes;
                        indexVal++;

                        String cal = len != 0
                            ? ((ll.length / len) * 100).toStringAsFixed(0)
                            : '0';

                        // if(!flag){
                        //       cal =  s == op['option'] ? "100" :"0";
                        // }
                        bool isSe = op.option == s;
                        String formattedText = op.option.replaceAllMapped(
                            RegExp(r'.{6}'),
                            (match) => '${match.group(0)}\u200B');

                        return Obx(() => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: InkWell(
                                onTap:
                      
                      myvote.value
                                    ? null
                                    : () {
                  if (ControllerManagement.userController.maskedName.value.trim().isEmpty) {
                        MaskedNameDialogBox.showMaskedNameDialog(context);
                      }
                      else{
                                        s = op.option;
                                        //  if(!flag)cal =  s == op['option'] ? "100" :"0";

                                        int place = options.indexOf(op);
                                        optionsList[options.indexOf(op)].votes.add(id);
                                        votePollInPost(context, PostId,
                                            options.indexOf(op));
                                        len++;

                                        myvote.value = true;
                                        e.options[options.indexOf(op)].votes.add(id);

                                        //  if(flag){
                                        //     questionRoom.removeAt(place);
                                        //     questionRoom.insert(place,e);
                                        //  }
                                      }},
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 13, horizontal: 10),
                                    //width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: op.option == s
                                            ? null
                                            : AppColors.unSelectedOption,
                                        borderRadius: BorderRadius.circular(
                                            Colorcodes.borderRadius/2),
                                        gradient: op.option == s
                                            ? LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  AppColors.finSpaceColor,
                                                  AppColors.finSpaceColor,
                                                ],
                                              )
                                            : null,
                                        border: !isSe
                                            ? Border.all(
                                                color: AppColors.button)
                                            : null),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          // width: MediaQuery.of(context).size.width/2,
                                          child: Text(op.option,
                                              //child: Text(formattedText,
                                              maxLines: null,
                                              softWrap: true,
                                              textWidthBasis:
                                                  TextWidthBasis.longestLine,
                                              overflow: TextOverflow.visible,
                                              style: FontManager().getTextStyle(
                                                  context,
                                                  lWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: isSe
                                                      ? AppColors.backgroundColor
                                                      : AppColors.bg1)),
                                        ),
                                        myvote.value
                                            ? Text(
                                                cal == "0.00"
                                                    ? '0%'
                                                    : cal == "100.00"
                                                        ? "100%"
                                                        : cal + "%",
                                                style: FontManager()
                                                    .getTextStyle(context,
                                                        lWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: isSe
                                                            ? AppColors.backgroundColor
                                                            : AppColors.bg1))
                                            : SizedBox.shrink(),
                                      ],
                                    )),
                              ),
                            ));
                      }).toList()),
                ],
              ),
            ),
          ],
        ),
      ));
}

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:get/get.dart';

Widget poll(e, context) {
  List options = e['options'];
  int index = e['selectedOption'];
  int s = -1;

  return Padding(
    padding: const EdgeInsets.only(right: 0.0, top: 5),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(e['question'] + "?",
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.bg1)),
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options.map((op) {
              s++;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                    width: MediaQuery.of(context).size.width / 1.5,
                    decoration: BoxDecoration(
                      color: index == s ? null : Colorcodes.white,
                      borderRadius:
                          BorderRadius.circular(Colorcodes.borderRadius),
                      gradient: index == s
                          ? LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.pollSelected,
                                AppColors.pollSelected,
                              ],
                            )
                          : null,
                      border: index == s
                          ? Border.all(color: AppColors.button)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(op,
                            overflow: TextOverflow.visible,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: 14,
                                color: index == s
                                    ? AppColors.bg1
                                    : AppColors.bg1)),
                      ],
                    )),
              );
            }).toList()),
      ],
    ),
    //),
  );
}

Widget getQuestionsAndOptions(e, context, flag, PostId) {
  String id = currentId.value;
  List options = e['options'];

  int index = -1;
  String s = "";
  for (int i = 0; i < options.length; i++) {
    List votesArray = options[i]['votes'];
    bool vote = votesArray.contains(id);
    if (vote) {
      index = i;
      s = options[i]['option'];
      break;
    }
  }
  RxBool myvote = (index != -1).obs;

  int len = 0;

  options.forEach((element) {
    List ll = element['votes'];
    len = len + ll.length;
  });

  RxList optionsList = [].obs;

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
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              width: width <= 500 ? width / 1.3 : width / 1.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: optionsList.map((op) {
                        List ll = op['votes'];
                        indexVal++;

                        String cal = len != 0
                            ? ((ll.length / len) * 100).toStringAsFixed(0)
                            : '0';

                        // if(!flag){
                        //       cal =  s == op['option'] ? "100" :"0";
                        // }
                        bool isSe = op['option'] == s;
                        String formattedText = op['option'].replaceAllMapped(
                            RegExp(r'.{6}'),
                            (match) => '${match.group(0)}\u200B');

                        return Obx(() => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: InkWell(
                                onTap: myvote.value
                                    ? null
                                    : () {
                                        s = op['option'];
                                        //  if(!flag)cal =  s == op['option'] ? "100" :"0";

                                        int place = options.indexOf(op);
                                        optionsList[options.indexOf(op)]
                                                ['votes']
                                            .add(id);
                                        votePollInPost(context, PostId,
                                            options.indexOf(op));
                                        len++;

                                        myvote.value = true;
                                        e['options'][options.indexOf(op)]
                                                ['votes']
                                            .add(id);

                                        //  if(flag){
                                        //     questionRoom.removeAt(place);
                                        //     questionRoom.insert(place,e);
                                        //  }
                                      },
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 13, horizontal: 10),
                                    //width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: op['option'] == s
                                            ? null
                                            : AppColors.backgroundColor,
                                        borderRadius: BorderRadius.circular(
                                            Colorcodes.borderRadius),
                                        gradient: op['option'] == s
                                            ? LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  AppColors.pollSelected,
                                                  AppColors.pollSelected,
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
                                          child: Text(op['option'],
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
                                                      ? AppColors.bg1
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
                                                            ? AppColors.bg1
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

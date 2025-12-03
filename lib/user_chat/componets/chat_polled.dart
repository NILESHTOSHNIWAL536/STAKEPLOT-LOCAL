

 import 'package:flutter/material.dart';

import '../../Constants/colors.dart';
import '../../Constants/font_manager.dart';
import '../../Constants/colorcodes.dart';

Widget polled(isme, pollObj,BuildContext context) {
    return !isme
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //  profilepath(isme),
              poll(pollObj,context),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              poll(pollObj,context),
              // profilepath(isme),
            ],
          );
  }



   Widget poll(e,BuildContext context) {
    List options = e['options'] ?? [];
    int index = 0; // e['selectedOption'];
    int s = -1;

    return Padding(
      padding: const EdgeInsets.only(right: 0.0, top: 5),
      child: Container(
        padding: EdgeInsets.only(right: 5.0, left: 5.0, top: 10, bottom: 3.0),
        width: MediaQuery.of(context).size.width / 1.4,
        decoration: BoxDecoration(
          //  color: Colorcodes.appBarColor,
          color: AppColors.mt,
          // border: Border.all(width: .5, color: Colorcodes.poll1),
          borderRadius: BorderRadius.circular(9),
        ),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        width: MediaQuery.of(context).size.width / 1.5,
                        decoration: BoxDecoration(
                          color: index == s ? null : AppColors.backgroundColor,
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
                              ? Border.all(color: Colorcodes.poll1)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(op['option'].toString(),
                                  maxLines: null,
                                  softWrap: true,
                                  textWidthBasis: TextWidthBasis.longestLine,
                                  overflow: TextOverflow.visible,
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: index == s
                                          ? AppColors.backgroundColor
                                          : AppColors.accentColor)),
                            ),
                          ],
                        )),
                  );
                }).toList()),
          ],
        ),
      ),
    );
  }

  Widget demiData(BuildContext context) {
    var options = [1, 2, 3, 4];
    return Padding(
      padding: const EdgeInsets.only(right: 0.0, top: 5),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        width: MediaQuery.of(context).size.width / 1.4,
        decoration: BoxDecoration(
          //  color: Colorcodes.appBarColor,
          border: Border.all(width: .5),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("",
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppColors.accentColor)),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options.map((op) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                        width: MediaQuery.of(context).size.width / 1.5,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(5),
                          // border: Border.all()
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("",
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColors.accentColor)),
                          ],
                        )),
                  );
                }).toList()),
          ],
        ),
      ),
    );
  }

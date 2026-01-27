import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/font_manager.dart';

Widget text(msg, isme,BuildContext context) {
  return !isme
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // profilepath(isme),
            textIsme(msg, isme,context),
          ],
        )
      : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            textIsme(msg, isme,context),
            // profilepath(isme),
          ],
        );
}

Widget textIsme(String msg, bool isme,BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0.0),
    child: Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width / 1.4,
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSizes.p14, vertical: AppSizes.p10),
      decoration: BoxDecoration(
        color: isme ? AppColors.appIcon : null,
        borderRadius: BorderRadius.only(
          bottomRight: isme ? Radius.zero : Radius.circular(10),
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
          bottomLeft: !isme ? Radius.zero : Radius.circular(10),
        ),
        gradient: !isme
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.mt,
                  AppColors.mt,
                ],
              )
            : null,
      ),
      child: SelectableText(
        msg,
        style: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: 0.0,
          color: isme ? AppColors.backgroundColor : AppColors.bg1,
        ),
        textAlign: TextAlign.left,
        onTap: () {
          // Optional: Handle tap if needed
        },
        contextMenuBuilder: (context, editableTextState) {
          return AdaptiveTextSelectionToolbar(
            anchors: editableTextState.contextMenuAnchors,
            children: [
              TextSelectionToolbarTextButton
              (
                padding: EdgeInsets.all(AppSizes.p8),
                child: Text('Copy'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: msg));
                },
              ),
            ],
          );
        },
      ),
    ),
  );
}

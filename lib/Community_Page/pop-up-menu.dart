import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/resportHide.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

Widget popUpBoxHideDelete(id, context, userId, int index,bool flag2) {
     
    return PopupMenuButton(
      initialValue: 2,
      color: Colorcodes.white,
      child: Center(
          child: Icon(
        Icons.more_vert_outlined,
        size: 25,
        color: AppColors.bg2,
      )),
      onSelected: (value) {
        if (value == 0 && userId == userName.value)
        {
          deletePost(id, context);
          clearPostReportHide(index);
        }
        else if (value == 1) {
          BuildContext c=context;
          showModalBottomSheet(
            context: context,
            builder: (contextBuild) {
              return showModel(c, id, flag2,index);
            },
          );

        } else {
          reportPost(context, id, "hide post", "hide",index);
          if (flag2)
          {
            getPost();
            Navigator.pop(context);
          }
         
        }

    
      },
      itemBuilder: (context) {
        return userId == userName.value
            ? [
                PopupMenuItem(
                  value: 0,
                  child: getTextMenuItem(
                    context: context,
                    text: "Delete",
                    color: Colorcodes.red,
                  ),
                ),
              ]
            : [
                PopupMenuItem(
                  value: 0,
                  child: getTextMenuItem(context: context, text: "Hide"),
                ),
                PopupMenuItem(
                  value: 1,
                  child: getTextMenuItem(context: context, text: "Report"),
                ),
              ];
      },
    );
  }




  Widget getTextMenuItem({
    required BuildContext context,
    text,
    Color color = AppColors.bg1,
  }) {
    return textStyle(
        context: context, text: text, c: color, fontWeight: FontWeight.bold);
}
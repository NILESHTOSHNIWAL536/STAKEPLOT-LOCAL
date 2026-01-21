import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/resportHide.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/repository/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

Widget popUpBoxHideDelete(id, context, userId, int index,bool flag2,bool isTribeOne) {
     
    return PopupMenuButton(
      initialValue: 2,
      color: Colorcodes.white,
      child: Center(
          child: Icon(
        Icons.more_vert_outlined,
        size: 25,
        color: AppColors.finSpaceColor,
      )),
      onSelected: (value) {
        if (value == 0 && userId == ControllerManagement.userController. userName.value)
        {
          deletePost(id, context);
           if(isTribeOne)
            {
                Navigator.pop(context);
            }
           clearPostReportHide(index,context);
        }
        else if (value == 1) {
          BuildContext c=context;
          showModalBottomSheet(
            
            context: context,
            builder: (contextBuild) {
              return showModel(c, id, flag2,index,isTribeOne);
            },
          );

           

        } else {
          reportPost(context, id, "hide post", "hide",index);
          if (flag2)
          {
            getPost(context);
            clearPostReportHide(index,context);
            Navigator.pop(context);
          }
        }
      
    
      },
      itemBuilder: (context) {
        return userId == ControllerManagement.userController. userName.value
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
                  child: getTextMenuItemForReport(context: context, text: "Report"),
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
     return Row(
      children: [
        text=="Hide"?
        Icon(Icons.visibility_off, color: AppColors.accentColor,size: 20,): 
        Icon(text=="Delete" ?Icons.delete: Icons.warning_rounded, color: AppColors.redColor,size: 20,),
        SizedBox(width: 12,),
        textStyle(
            context: context, text: text, c: text== "Hide"?AppColors.accentColor: AppColors.redColor, fontWeight: FontWeight.bold, fontsize: 14),
      ],
    );
}
  Widget getTextMenuItemForReport({
    required BuildContext context,
    text,
    Color color = AppColors.bg1,
  }) {
    return Row(
      children: [
        Icon(Icons.warning_rounded, color: AppColors.redColor,size: 20,),
        SizedBox(width: 12,),
        textStyle(
            context: context, text: text, c: AppColors.redColor, fontWeight: FontWeight.bold, fontsize: 14),
      ],
    );
}
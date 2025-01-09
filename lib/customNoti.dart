import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';


RxBool hasGetNewNotifications=false.obs;

class NotificationsBudget extends StatelessWidget {
Widget child;
 NotificationsBudget({ Key? key, required  this.child }) : super(key: key);

  @override
  Widget build(BuildContext context){
    // return Obx(() =>  GFIconBadge(
    //                  position: !hasGetNewNotifications.value?  GFBadgePosition(top:15,end: 15) : GFBadgePosition(top:7,end: 8),
    //                 //  padding: EdgeInsets.only(top: 10,right: 10),
    //                   counterChild: GFBadge(
    //                     size:14,
    //                     color: hasGetNewNotifications.value? Colorcodes.redDeleteIcon:Colorcodes.budgetLightGreen,
    //                     shape: GFBadgeShape.circle,
    //                     child: Container(
    //                       width: 1,
    //                       height: 1,
    //                       // child: Text("",style: FontManager().getTextStyle(
    //                       //                         context,
    //                       //                         lWeight: FontWeight.w100,
    //                       //                         fontSize: 1,
    //                       //                         color:  Colorcodes.black
    //                       // ),
    //                     ),
    //                 ),
    //               child: child
    //     ));
    return Text("Nilesh");
  }
}
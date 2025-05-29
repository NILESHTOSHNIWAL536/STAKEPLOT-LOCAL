import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';


class NotificationsBudget extends StatelessWidget {
Widget child;
 NotificationsBudget({ Key? key, required  this.child }) : super(key: key);

  @override
  void initState() {
  }

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
    // return InkWell(
    //                   onTap: (){
    //                       Navigator.pushNamed(context, '/Notifications');
    //                   },
    //                   child: SvgPicture.asset(HomePageIcons.notification,
    //                       height: 30, width: 15),
    //           );
   return  Container(
     width: MediaQuery.of(context).size.width/6,
    //  color: Colorcodes.billBody,
     padding: EdgeInsets.symmetric(horizontal: 10),
     child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                     InkWell(
                      onTap: (){
                        HapticFeedback.mediumImpact();
                              Navigator.pushNamed(context, '/Notifications');
                          },
                       child: Container(
                         padding: EdgeInsets.all(8),
                         decoration: BoxDecoration(
                            color: AppColors.button,
                            borderRadius: BorderRadius.circular(10)
                         ),
                         
                            child: SvgPicture.asset(HomePageIcons.notification,
                                height: 22, width: 10,color: Colorcodes.black,),
                                         ),
                     ),
                     
             Obx(()=> !hasGetNewNotifications.value?   SizedBox.shrink():   Positioned(
                        right: 10,
                        top: 9,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
             ),
   );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';


class NotificationsBudget extends StatefulWidget {
Widget child;
 NotificationsBudget({ Key? key, required  this.child }) : super(key: key);

  @override
  State<NotificationsBudget> createState() => _NotificationsBudgetState();
}

class _NotificationsBudgetState extends State<NotificationsBudget> {



   @override
  void initState() {
    super.initState();
    getAck();
  }
 

  @override
  Widget build(BuildContext context){
   return  Container(
     width: MediaQuery.of(context).size.width/6,
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
                          decoration: BoxDecoration(
                            color: AppColors.redColor,
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
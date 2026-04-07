import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/notification_repository.dart';
import 'package:get/get.dart';
import '../Constants/core/app_component_sizes.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Home_Screen/Home/new_updates_screen.dart';


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
     width: AppComponentSizes.w4,
     padding:const EdgeInsets.symmetric(horizontal: 10),
     child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                   onTap: (){
                     HapticFeedback.mediumImpact();
                           Navigator.pushNamed(context, '/Notifications');
                    },
                    child: Obx(()=> !hasGetNewNotifications.value? 
                    AvatarProfileImageZero(url: HomePageIcons.notification, width: 30, height: 30):
                     AvatarProfileImageZero(url: HomePageIcons.notificationStack, width: 30, height: 30)
                    )
                    
                  ),
                   SizedBox(width: AppSizes.w10),
                  InkWell(
                   onTap: (){
                     HapticFeedback.mediumImpact();
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UpdatesScreen(),
                            ),
                          );
                       },
                    child: 
                    AvatarProfileImageZero(url: HomePageIcons.appUpdates, width: 30, height: 30)
                     
                    )
                    
                  
                             
                ],
             ),
   );
  }
}
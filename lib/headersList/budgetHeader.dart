import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/customNoti.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';


class BudgetHeader extends StatefulWidget {
  String name;
  Color color;
  bool flag;
  bool isBack;
   BudgetHeader({ Key? key,required this.name ,this.color=Colors.white,this.flag=false,this.isBack=true}) : super(key: key);

  @override
  _BudgetHeaderState createState() => _BudgetHeaderState();
}

class _BudgetHeaderState extends State<BudgetHeader> {
  @override
  Widget build(BuildContext context) {
    return  Container(
           padding:  EdgeInsets.symmetric(horizontal: 0,vertical: 50),
           width: MediaQuery.of(context).size.width,
           color: widget.color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [

                    // widget.isBack?
                      InkWell(
                        onTap: !widget.isBack?null:
                        (){
                          Navigator.pop(context);
                        },
                       child: Icon(Icons.arrow_back_sharp,color: !widget.isBack? Colors.transparent:widget.flag? Colorcodes.budgetLightGreen:Colorcodes.budgetDarkGreen,)
                      ),
                      // :SizedBox.shrink(),
                       
                        Text((widget.name),
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w500,
                                fontSize: 24,
                                color: Colors.black)),
                        
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                          [
                                GestureDetector(
                                  onTap: (){
                                      Navigator.pushNamed(context, '/Notifications');
                                  },
                                  child: NotificationsBudget(
                                    
                                    child: CircleAvatar(
                                      backgroundColor:Colorcodes.budgetLightGreen ,
                                      child: Center(child:
                                       AvatarProfileImage(url: svgIconPath.notifications, width: 10, height: 20))
                                    ),
                                  ),
                                ),    
                                 const SizedBox(width: 3,),  
                                 GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, "/Profile");
                                    },
                                   child: CircleAvatar(
                                    backgroundColor:Colorcodes.budgetLightGreen ,
                                    child: ProfileImage(url: avatar.value)
                                                                   ),
                                 )       
                          ]
                    ),

                        

               ],
          ),

           
       );
  }
}
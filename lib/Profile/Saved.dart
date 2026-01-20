
import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Community_Page/postCard.dart";
import "package:flutter_application_code_stakeplot/Constants/colors.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/repository/profileUser.dart";
import "package:flutter_application_code_stakeplot/Constants/colorcodes.dart";
import "package:flutter_application_code_stakeplot/controllers/controllerManagement.dart";
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import "package:get/get.dart";

import "../Community_Page/widgets/buildbutton.dart";
import "../Constants/core/app_padding_sizes.dart";




class Saved extends StatefulWidget {
   Saved({ Key? key}) : super(key: key);

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Saved> {

   @override
  void initState() {
    super.initState();
    getSaved();
  }

  @override
  Widget build(BuildContext context) {
       UserController userController=ControllerManagement.userController;

    return Scaffold(
       backgroundColor: AppColors.backgroundColor,
     
      body:Column(
        children: [
           ArenaHeaderForSaved(
      initialTab: 1, // Polls
      onTabChanged: (index) {
      
      },
    ),
          Container(
             height: MediaQuery.of(context).size.height/1.3,
             width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                   color: Colorcodes.white,
                   borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Colorcodes.borderCut),
                    topRight: Radius.circular(Colorcodes.borderCut),
                   )
                
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            Obx(() => userController.savedList.isEmpty? 
                            Center(child: Container(
                              height: MediaQuery.of(context).size.height/1.2,
                              alignment: Alignment.center,
                              child: Text("No Post Saved",style: FontManager().getTextStyle(context))
                            )):
                            Container(
                                child: feed(userController),
                                )),
                              ],  
                      ), 
                  ]),
            ),
          )
            ])
      );
  }


Widget feed(UserController userController){

    return  Column(
                    children: [
                      Container(
                        child: Column(
                          children: userController.savedList.asMap().entries.map((entry) {
                            int index = entry.key;
                            var dataObj = entry.value;
                            return PostCard(data: dataObj, index: index);
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: AppSizes.h100,),
                ],
        );
  }
}

import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Community_Page/postCard.dart";
import "package:flutter_application_code_stakeplot/Constants/colors.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/repository/profileUser.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/controllers/controllerManagement.dart";
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import "package:get/get.dart";




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
      appBar: AppBar(
        title: Text(
          'Saved Posts',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.bg1,
          ),
        ),
        backgroundColor: AppColors.mt,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.bg1),
            onPressed: () => Navigator.pop(context)),
      ),
      body:Column(
        children: [
          Container(
             height: MediaQuery.of(context).size.height/1.165,
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
                      SizedBox(height: 100,),
                ],
        );
  }
}
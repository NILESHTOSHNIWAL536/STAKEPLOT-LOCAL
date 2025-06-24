
import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Community_Page/postCard.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/controllers/controllerManagement.dart";
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import "package:flutter_application_code_stakeplot/headersList/userProfileHeader.dart";
import "package:get/get.dart";




class Saved extends StatefulWidget {
  var data;
   Saved({ Key? key,required this.data }) : super(key: key);

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Saved> {


  // https://stakeplot.in/api/v1/post/saved
  var getTrendingData=[];
  bool isfound=false;
  List<Color> color=[Colors.blue,Colors.redAccent,Colors.green,Colors.amber,Colors.cyanAccent];
    @override
  void initState() {
    super.initState();
    getSaved();
  }

  @override
  Widget build(BuildContext context) {
       UserController userController=ControllerManagement.userController;

    return Scaffold(
       extendBody: true,
        backgroundColor: Colorcodes.budgetDarkGreen, 
      
      body:Column(
        children: [
           UserProfileHeader(name: "Saved"),
          Expanded(
            child: Padding(
              padding:  EdgeInsets.only(top: Colorcodes.paddingTopDesign),
              child: Container(
                 height: MediaQuery.of(context).size.height/1.165,
                 width: MediaQuery.of(context).size.width,
                  padding:  EdgeInsets.only(top: Colorcodes.paddingTopScroll),
                decoration: BoxDecoration(
                       color: Colorcodes.white,
                       borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Colorcodes.borderCut),
                        topRight: Radius.circular(Colorcodes.borderCut),
                       )
                    
                ),
                child: ListView(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const SizedBox(width: 10,),
                    Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 0),
                      child: Column(
                         mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    
                
                                Obx(() => userController.savedList.isEmpty? Center(child: Text("No Post Saved",style: FontManager().getTextStyle(context))):Container(
                                    height: MediaQuery.of(context).size.height,
                                    padding:const EdgeInsets.symmetric(horizontal: 0,vertical: 10),
                                    child: SingleChildScrollView(
                                          child: feed(userController),
                                    ),
                                    )),
                                  
                                    const SizedBox(height: 100,)
                   
                 
                                  ],  
                          ),
                              
                        ), 
                    ]),
              )),
          )
            ])
      );
  }








Widget feed(UserController userController){

    return  userController.savedList.isEmpty?Text("No Post yet"):
            Column(
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
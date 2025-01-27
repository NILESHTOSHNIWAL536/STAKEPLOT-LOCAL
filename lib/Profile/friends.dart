
import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Community_Page/postCard.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/Tribe/userDetails.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/controller.dart/userController.dart";
import "package:flutter_application_code_stakeplot/headersList/userProfileHeader.dart";
import "package:flutter_application_code_stakeplot/profile.dart";
import "package:get/get.dart";
import 'package:http/http.dart' as http;

class Friends extends StatefulWidget {
  const Friends({ Key? key }) : super(key: key);

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {

  List frdsList=[];
  bool frdsThere=true;


  @override
  void initState() {
    super.initState();
    
  }


  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
   
    return Scaffold(
       extendBody: true,
        backgroundColor: Colorcodes.budgetDarkGreen,
      //  bottomNavigationBar:logoutWidget(),
      
      
      body:Column(
        children: [
           UserProfileHeader(name:"Friends List"),
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
              
                  children: [
                    
                   Obx(() => userController.friendsList.isEmpty?Center(child: Text("No Frds Yet",style:FontManager().getTextStyle(context,))):Column(
                          children: userController.friendsList.map((d) => d==null? Text(""):profileContainer(d)).toList(),
                      )),
                  
                          ],
                      ),
                    ),
                  
                 
                        
                 ),
          ),
                  
            
            ]));
  }



  Widget profileContainer(data) {
   
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
        child: Center(
          child: InkWell(
            onTap: (){
       
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetails(data: data,ids:[],flag: true,),
                      ),
                  );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
               decoration: BoxDecoration(
              //  color:const Color.fromRGBO(249, 246, 238, 1),
                   borderRadius: BorderRadius.circular(10)
               ),
              width: MediaQuery.of(context).size.width/1.1,
              child: Row(
                   children: [
                           AvatarProfileImage(url:data['avatar'] ?? userAvatar , width: 7, height: 12),
                          const SizedBox(width:  10,),
              
                        Text((data['name']),
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.black)),
                        
                        const Spacer(),


                         GestureDetector(
                           onTap: (){
                          

                          showDialog(context: context, builder: (context){
                                return Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width/1.2,
                                    height: MediaQuery.of(context).size.height/4,
                                    padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                                    decoration: BoxDecoration(
                                          color: Colorcodes.white,
                                          borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    
                                      children: [

                                         Text("Are you sure you want to remove ${data['name']} ?",
                                         style: FontManager().getTextStyle(context,
                                            fontSize: 18,
                                            color: Colorcodes.budgetDarkGreen,
                                            lWeight: FontWeight.bold,
                                            //  fontFamily: AutofillHints.birthdayDay
                                        ),),
                           const SizedBox(height: 20,),
                                        Row(
                                             mainAxisAlignment: MainAxisAlignment.end,
                                             children: [
                                                  textStyleColor("Remove",Colorcodes.red,data),
                                                  const SizedBox(width: 20,),
                                                  textStyleColor("Go Back",Colorcodes.blue,data),
                                             ],
                                        ),
                                         
                                        
                                       
                                      ],
                                    ),
                                  ),
                                );

                           },);

                          //        showModalBottomSheet(
                          //     context: context,
                          //     builder: (BuildContext context) {
                          //       return Container(
                          //         height: MediaQuery.of(context).size.height/6,
                          //         width: MediaQuery.of(context).size.width/1.5, // Adjust height as needed
                          //         child: Column(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           crossAxisAlignment: CrossAxisAlignment.center,
                          //           children: [
                          //             Container(
                          //                   child: style("Remove ${data['name']}"),
                          //             ),
                          //             Padding(
                          //              padding: EdgeInsets.only(right: 20,top: 10),
                          //               child: Align(
                          //                 alignment: Alignment.centerRight,
                          //                 child: GestureDetector(
                          //                      onTap: (){
                                                 
                          //                          getRemoveFrds(context,data['_id']);
                                                  
                          //                      },
                          //                      child: Container(
                          //                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                          //                        decoration: BoxDecoration(
                          //                            border: Border.all(),
                          //                            borderRadius: BorderRadius.circular(10)
                          //                        ),
                          //                       child: style("Remove")),
                          //                 ),
                          //               ),
                          //             )
                          //           ],
                          //         ),
                          //       );
                          //     },
                          // );
                          
                          
                          
                           },
                           child:Container(child:  ProfileImage(url: "assets/images2/user-minus.svg",))
                         ),


                    
                   ],
              ),
            ),
          )
          ),
      );
 }


Widget textStyleColor(str,color,data){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: () {
              if(str=="Remove")
              {
                      getRemoveFrds(context,data['_id']);    
                      getUserInfomations();  
              }
             Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
           decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5)
           ),
          child: Text(str,style: FontManager().getTextStyle(context,
                 fontSize: 17,
                 lWeight: FontWeight.w500,
                 color: Colorcodes.white
                //  fontStyle: FontStyle.italic
          ),),
        ),
      ),
    );
}



Widget style(str){
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(str,style: FontManager().getTextStyle(context,
                       fontSize: 16,
                       lWeight: FontWeight.bold,
                      //  fontFamily: AutofillHints.birthdayDay
                   ),),
    );
}



}
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/helper.dart";
import "package:flutter_application_code_stakeplot/Tribe/tribe_home.dart";
import "package:flutter_application_code_stakeplot/Tribe/tribe_search.dart";
import "package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import "package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart";
import "package:flutter_application_code_stakeplot/profile_screen/usercommunityProfile.dart";
import "package:get/get.dart";
import 'package:flutter_application_code_stakeplot/Constants/search.dart';


class Friends extends StatefulWidget {
  bool isMasked=false;
  bool isMaskedConnect=false;

   Friends({Key? key,this.isMasked=false,this.isMaskedConnect=false}) : super(key: key);

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  RxList frdsList = [].obs;
  bool frdsThere = true;
  final TextEditingController _searchController = TextEditingController();
   final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    frdsList.clear();
    frdsList.addAll(widget.isMasked ? widget.isMaskedConnect?userController.maskedConnected :userController.maskedConnections: userController.friendsList);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        extendBody: true,
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: textStyle(
                  context: context,
                  text: widget.isMasked? ProfileScreenStrings().friendsListTitle:ProfileScreenStrings().friendsListTitle,
                  fontsize: 18,
                  fontWeight: FontWeight.w600),
        ),
        //  bottomNavigationBar:logoutWidget(),

        body: SafeArea(
          child: Column(children: [  
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/1.14,
             // padding: EdgeInsets.only(top: Colorcodes.paddingTopDesign/2),
              child: ListView(
                children: [
                  Hero(
                    tag: "TribeSearch",
                    child: GestureDetector(
                      onTap: () {
                        if(userController.friendsList.isEmpty)
                        {
                          if(widget.isMasked){
                             Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>TribeSearch(isMasked: true,),
                            ),
                          );
                          }else Navigator.pushNamed(context, '/TribeSearch');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width / 3,
                          height: 50,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                                frdsList.clear();
                                frdsList.addAll(getLastTenUsers(getSearchData(value,userController.friendsList )));
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              filled: true,
                              enabled: userController.friendsList.isEmpty,
                              hintText:  ProfileScreenStrings().searchHint,
                              fillColor: AppColors.button,
                              hintStyle: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: Colors.black),
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Obx(() => frdsList.isEmpty
                      ? noFriend(context,"",widget.isMasked)
                      : Column(
                          children: frdsList
                              .map((d) =>
                                  d == null ? Text("") : profileContainer(d))
                              .toList(),
                        )),
                ],
              ),
            ),
          ]),
        ));
  }

  Widget profileContainer(data) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Center(
          child: GestureDetector(
        onTap: () {
        
          Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityUserProfile(data: data,ids:[],flag: true,isMasked: widget.isMasked,isMaskedConnect: widget.isMaskedConnect,),
                      ),
                  );
        },
        child: Container(
          
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
          decoration: BoxDecoration(
            
              //  color:const Color.fromRGBO(249, 246, 238, 1),
              borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width / 1.1,
          child: Row(
             mainAxisAlignment: MainAxisAlignment.start,
             crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // AvatarProfileImage(
              //     url:avaterUrlPath(data['name']), width: 15, height: 15),

           widget.isMasked?  AvatarProfile2(url: data['avatarType'], width: 20, height: 20): AvatarProfile(name: data['name'], width: 30, height: 13,background:data['avatarBackGround'] ?? defaultBackGround.value,),
             
              // Text((data),
              Text((data['name']),
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.black)),
             
             
            ],
          ),
        ),
      )),
    );
  }

  Widget textStyleColor(str, color, data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: () {
          if (str == "Remove") {
            getRemoveFrds(context, data['_id']);
            userController.fetchUserInfo();    
          }
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(5)),
          child: Text(
            str,
            style: FontManager().getTextStyle(context,
                fontSize: 17, lWeight: FontWeight.w500, color: Colorcodes.white
                //  fontStyle: FontStyle.italic
                ),
          ),
        ),
      ),
    );
  }

  Widget style(str) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        str,
        style: FontManager().getTextStyle(
          context,
          fontSize: 16,
          lWeight: FontWeight.bold,
          //  fontFamily: AutofillHints.birthdayDay
        ),
      ),
    );
  }
}

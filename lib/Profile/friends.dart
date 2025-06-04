import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/helper.dart";
import "package:flutter_application_code_stakeplot/Tribe/tribe_home.dart";
import "package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/controller.dart/userController.dart";
import "package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart";
import "package:flutter_application_code_stakeplot/profile_screen/usercommunityProfile.dart";
import "package:get/get.dart";

class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  RxList frdsList = [].obs;
  bool frdsThere = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    frdsList.clear();
    frdsList.addAll(friendsList);
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Scaffold(
        extendBody: true,
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: textStyle(
                  context: context,
                  text: ProfileScreenStrings().friendsListTitle,
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
                        if( friendsList.isEmpty)Navigator.pushNamed(context, '/TribeSearch');
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
                                frdsList.addAll(getLastTenUsers(getSearchData(value,friendsList )));
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              filled: true,
                              enabled: !friendsList.isEmpty,
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
                      ? noFriend(context)
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
        
          // Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => CommunityUserProfile(data: data,ids:[],flag: true,),
          //             ),
          //         );
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

              AvatarProfile(name: data['name'], width: 30, height: 13,background:data['avatarBackGround'] ?? defaultBackGround.value,),
             
              Text((data['name']),
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.black)),
              const Spacer(),
              // GestureDetector(
              //     onTap: () {
              //       showDialog(
              //         context: context,
              //         builder: (context) {
              //           return Center(
              //             child: Container(
              //               width: MediaQuery.of(context).size.width / 1.2,
              //               height: MediaQuery.of(context).size.height / 4,
              //               padding: EdgeInsets.symmetric(
              //                   vertical: 20, horizontal: 10),
              //               decoration: BoxDecoration(
              //                   color: Colorcodes.white,
              //                   borderRadius: BorderRadius.circular(5)),
              //               child: Column(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 crossAxisAlignment: CrossAxisAlignment.center,
              //                 children: [
              //                   Text(
              //                     "Are you sure you want to remove ${data['name']} ?",
              //                     style: FontManager().getTextStyle(
              //                       context,
              //                       fontSize: 18,
              //                       color: Colorcodes.budgetDarkGreen,
              //                       lWeight: FontWeight.bold,
              //                       //  fontFamily: AutofillHints.birthdayDay
              //                     ),
              //                   ),
              //                   const SizedBox(
              //                     height: 20,
              //                   ),
              //                   Row(
              //                     mainAxisAlignment: MainAxisAlignment.end,
              //                     children: [
              //                       textStyleColor(
              //                           "Remove", Colorcodes.red, data),
              //                       const SizedBox(
              //                         width: 20,
              //                       ),
              //                       textStyleColor(
              //                           "Go Back", Colorcodes.blue, data),
              //                     ],
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           );
              //         },
              //       );

                   
              //     },
              //     child: Container(
              //         child: ProfileImage(
              //       url: "assets/images2/user-minus.svg",
              //     ))
              //     ),
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
            getUserInfomations();
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

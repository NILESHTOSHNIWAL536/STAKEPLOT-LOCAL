import "dart:convert";
import "package:flutter/cupertino.dart";
import "package:flutter/widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Community_Page/community_screen.dart";
import "package:flutter_application_code_stakeplot/Constants/app_styles.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/home_page.dart";
import "package:flutter_application_code_stakeplot/Profile/profile.dart";
import "package:flutter_application_code_stakeplot/Tribe/tribe_home.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart";
import "package:flutter_application_code_stakeplot/profile_screen/profile_screen.dart.dart";

import "package:get/get.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavigations extends StatefulWidget {
  int data;
  BottomNavigations({Key? key, required this.data}) : super(key: key);

  @override
  _BottomNavigationsState createState() => _BottomNavigationsState();
}

class _BottomNavigationsState extends State<BottomNavigations> {
  @override
  void initState() {
    super.initState();
    getRoom();
  }

  void getRoom() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('${url}/room/find'),
      // Uri.parse('https://stakeplot.in/api/v1/post/all'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );

    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    //int selectedIndex = 0;
    return Container(
      //color: Colorcodes.white,
      padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 1.5),
      child: Card(
        elevation: Colorcodes.elevation,
        color: AppColors.accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              getContainer(NavBarIcons.home, 0),
              getContainer(NavBarIcons.screen2, 1),
              if (sizeRoom)
                getContainer(
                  'assets/images/room.svg',
                  2,
                ),
              getContainer(
                NavBarIcons.community,
                sizeRoom ? 3 : 2,
              ),
              getContainer(
                svgIconPath.bottom4,
                sizeRoom ? 4 : 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageurl(url, int index) {
    return SvgPicture.asset(
      url,
      width: 40,
      height: 40,
      color: widget.data == index ? Colorcodes.debtBody : Colorcodes.black,
    );
  }

  Widget getContainer(url, i) {
    bool isSelected =
        widget.data == i; // Check if the current index is selected

    return InkWell(
      onLongPress: () {
        if (i == 0) {
          // Handle long press for index 0
        } else if (i == 2 && widget.data != i) {
          // Handle long press for index 2
        }
      },
      onTap: () {
        if (i == 0 && widget.data != i) pushName(HomePage());
        // else if (i == 1 && widget.data != i) pushName(Budget());
        // if (i == 1 && widget.data != i) pushName(ProfileScreenDart());

        if (!sizeRoom) {
          if (i == 2 && widget.data != i)
            pushName(Community());
          else if (i == 3 && widget.data != i) pushName(ProfileScreenDart());
        } else {
          // if (i == 2 && widget.data != i) pushName(RoomHome());
          if (i == 3 && widget.data != i)
            pushName(Community());
          else if (i == 4 && widget.data != i) pushName(ProfileScreenDart());
        }

        setState(() {
          widget.data = i; // Update selected index
        });
      },
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.bg5, // White background for the selected item
                borderRadius: BorderRadius.circular(24), // Rounded corners
              )
            : null, // No special decoration for unselected items
        padding: EdgeInsets.symmetric(
            horizontal: 6, vertical: 3), // Adjust padding as needed
        child: imageurl(url, i),
      ),
    );
  }

  void pushName(widgetName) {
    // Get.to(widgetName)
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => widgetName,
      ),
    );
    //  Navigator.push(
    //       context,

    // PageTransition(
    //    type: PageTransitionType.fade,
    //   alignment: Alignment.bottomRight,
    //    duration: Durations.long1,

    //   child: widgetName,
    //   isIos: true,
    // ),
    // );
  }

//  handleTap(i){
//     if (i == 0 && widget.data != i) pushName( Home());
//         else if (i == 1 && widget.data != i)pushName(Budget());

//         if(!sizeRoom)
//         {
//               if (i == 2 && widget.data != i)pushName(TribeHome());
//               else if (i == 3 && widget.data != i)pushName(ImageDisplay());
//         }else{

//             if (i == 2 && widget.data != i)  pushName(RoomHome());
//             else  if (i == 3 && widget.data != i)pushName(TribeHome());
//             else if (i == 4 && widget.data != i)pushName(ImageDisplay());
//       }

//       //  setState(() {
//       //      widget.data=i;
//       //  });
// }
}

Widget showUserData(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;

  List<String> loginUsers = loginUsersList.keys.toList();

  loginUsers.remove(userName.value);
  loginUsers.insert(0, userName.value);

  return Container(
    width: width,
    height: loginUsers.length == 0 ? height / 5 : height / 2.7,
    decoration: BoxDecoration(
      color: Colorcodes.budgetLightGreen,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: width / 8,
          height: 4,
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: Colorcodes.white, borderRadius: BorderRadius.circular(10)),
        ),
        loginUsers.length == 0
            ? SizedBox.shrink()
            : Container(
                width: width / 1.1,
                height:
                    loginUsers.length == 1 ? height / 5.7 / 2 : height / 5.7,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    color: Colorcodes.white,
                    borderRadius: BorderRadius.circular(20)),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    String name = loginUsers[index];
                    dynamic user = loginUsersList[name];

                    return InkWell(
                      onTap: () async {
                        TextEditingController emailController =
                            TextEditingController(text: user['email']);
                        TextEditingController passwordController =
                            TextEditingController(text: user['password']);
                        final SharedPreferences _pref =
                            await SharedPreferences.getInstance();
                        _pref.remove("accessToken").then((_) {
                          // Code to execute after token removal
                          _pref.setString("accessToken", user['accessToken']);
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/', (Route<dynamic> route) => false);
                          Navigator.pushReplacementNamed(context, '/home');

                          //  Navigator.pushReplacementNamed(context, '/');
                        }).catchError((error) {
                          // Error handling if token removal fails
                        });

                        clearGetX();

                        loginUser(emailController, passwordController, context);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        child: Row(
                          children: [
                            AvatarProfileImage(
                                url: user['avatar'], width: 16, height: 16),
                            Container(
                              width: width / 1.8,
                              // color: Colorcodes.bedgetBody,
                              child: Text(
                                user['name'],
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colorcodes.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Obx(() => user['name'] == userName.value
                                ? Container(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.check_circle_outlined,
                                      color: Colorcodes.budgetDarkGreen,
                                    ),
                                  )
                                : SizedBox.shrink()),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: loginUsers.length,
                ),
              ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/');
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 10),
              child: Row(
                children: [
                  CircleAvatar(
                      backgroundColor: Colorcodes.white,
                      child: AvatarProfileImage(
                          url: svgIconPath.account, width: 10, height: 10)),
                  const SizedBox(
                    width: 20,
                  ),
                  Text("Add StakePlot Account",
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Colorcodes.black)),
                ],
              ),
            ),
          ),
        ),
        logoutWidget(context, true),
      ],
    ),
  );
}

Widget logoutWidget(context, [flag = false]) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      // height: 50,
      //  alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              //  home
              final SharedPreferences _pref =
                  await SharedPreferences.getInstance();

              await _pref.remove("accessToken");
              await _pref.remove("token");
              await _pref.remove("ConsentHandleId");
              await _pref.remove("consentId");
              await _pref.remove("from");
              await _pref.remove("to");
              await _pref.remove("sessionId");

              _pref.remove("accessToken").then((_) {
                // Code to execute after token removal
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/', (Route<dynamic> route) => false);
                Navigator.pushReplacementNamed(context, '/');
                //  Navigator.pushReplacementNamed(context, '/');
              }).catchError((error) {
                // Error handling if token removal fails
              });

              clearGetX();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: flag
                  ? MediaQuery.of(context).size.width / 1.1
                  : MediaQuery.of(context).size.width / 1.2,
              decoration: BoxDecoration(
                  color: Colorcodes.budgetDarkGreen,
                  borderRadius: BorderRadius.circular(100)),
              child: Center(
                child: Text(("LogOut"),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colorcodes.white)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

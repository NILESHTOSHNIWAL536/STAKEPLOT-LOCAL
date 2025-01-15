import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_application_code_stakeplot/Tribe/tribe_home.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends.dart";
import "package:flutter_application_code_stakeplot/bottomNavigations.dart";
import "package:flutter_application_code_stakeplot/loader.dart";
import "package:flutter_application_code_stakeplot/profile.dart";
import "package:get/get.dart";
import "package:get/get_rx/src/rx_types/rx_types.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import "package:flutter_application_code_stakeplot/Community_Page/postCard.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/headersList/userProfileHeader.dart";

class UserDetails extends StatefulWidget {
  final data;
  final List ids;
  bool flag = false;
  UserDetails(
      {Key? key, required this.data, required this.ids, this.flag = false})
      : super(key: key);

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  TextEditingController about = TextEditingController();
  String dataReport = "";

  List getTrendingData = [];
  List frds = [];
  bool findData = true;
  bool already = false;
  RxInt count = 0.obs;
  RxInt score = 0.obs;
  RxBool fl = false.obs;
  RxBool reload = false.obs;
  RxString buttonValue="Add".obs;
  RxString frdRequest="Friend Request not sent before".obs;
  RxString frdRequestCheck="Friend Request not sent before".obs;

  @override
  void initState() {
    super.initState();
    getStatus();
    getConnections();
    getDis();

  }

  void getDis() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse(
          '${url}/post/userDiscussions/${widget.data['_id']}'),
      // Uri.parse('https://stakeplot.in/api/v1/post/all'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );

    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];

      setState(() {
        getTrendingData = obj;
        findData = false;
      });

      getTrendingData.forEach((element) {
        postCount[element["_id"]] =
            element['upvotes'] < 0 ? 0 : element['upvotes'];
      });
      print("getTrendingData");
      print(getTrendingData);
    } else {}
  }

  void getConnections() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    
    final response = await http.get(
      Uri.parse(
          '${url}/user/connections/${widget.data['_id']}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );

    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      
       count.value = his['data']['connections'];
       score.value = his['data']['score'];
      // fl.value = !fl.value;
    } else {}
  }
  void getStatus() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    
    final response = await http.post(
      Uri.parse("${url}/user/friend/acceptRequestStatus"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
       body: jsonEncode({
          'userName':widget.data['name'],
          'friendUserId':widget.data['_id'],
       }),
    );

    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
       frdRequestCheck.value=his['data'];
        if(frdRequestCheck.value=="Friend Request already sent"){
                    buttonValue.value="Requested";
        }
        else if(frdRequestCheck.value=="Friend Request not sent before"){
                    buttonValue.value="Add";
        }
        else if(frdRequestCheck.value=="User is already your friend")
        {
                    buttonValue.value="Remove";
        }else{
             buttonValue.value="Accept";
        }
      
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    return Scaffold(
        bottomNavigationBar: BottomNavigations(data: sizeRoom ? 3 : 2),
        backgroundColor: Colorcodes.budgetDarkGreen,
        extendBody: true,
        body: Column(children: [
          UserProfileHeader(name: userName.value),
          Padding(
            padding: EdgeInsets.only(top: Colorcodes.paddingTopDesign),
            child: Container(
              height: MediaQuery.of(context).size.height / 1.2,
              width: MediaQuery.of(context).size.width,
              padding:
                  EdgeInsets.symmetric(vertical: Colorcodes.paddingTopScroll),
              decoration: BoxDecoration(
                  color: Colorcodes.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Colorcodes.borderCut),
                    topRight: Radius.circular(Colorcodes.borderCut),
                  )),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colorcodes.white,
                        // color: const Color.fromRGBO(249, 246, 238, 1),
                        borderRadius: BorderRadius.circular(100)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reportShowDilaog(),
                        size(10),
                        nameAndAddFrd(data),
                        size(20),
                        Obx(() => fl.value ?  text('${count.value} Networks') :  text('${count.value} Networks'),),

                        size(20),
                           textStyleDesign("Score "+doubleToFixed(score.value.toString()),Colorcodes.dropdown,18,context),
                        size(20),
                        aboutUser(),
                      ],
                    ),
                  ),
                  myDis(),
                  size(50),
                ],
              ),
            ),
          ),
        ]));
  }

  Widget text(String str) {
    
    // return Text(('${ data['friendsList']==null? count.value:data['friendsList'].length } Networks'),
    return Text((str),
        style: FontManager().getTextStyle(context,
            lWeight: FontWeight.bold,
            fontSize: 16,
            color: Colorcodes.barGraphOrange2));
  }

  Widget size(double val) {
    return SizedBox(
      height: val,
    );
  }
  

  Widget uploadData1() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              //  TribeUnique
              Navigator.pushNamed(context, '/TribeUnique');
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(249, 246, 238, 1),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(('Title'),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.black)),
                  ),
                  Center(
                    child: Text(('Content'),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.black)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_drop_up_outlined,
                              size: 35,
                              color: Colors.black,
                            ),
                            Text(('1'),
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 18,
                                    color: Colors.black)),
                            const Icon(
                              Icons.arrow_drop_down_outlined,
                              size: 30,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      imageurl('assets/images/Share.svg')
                    ],
                  ),
                ],
              ),
            ),
          ),

          // index==id ?commentedData():SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget imageurl(url) {
    return SvgPicture.asset(
      url,
      height: 25,
    );
  }

  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: 2),
        // color:  Color.fromRGBO(246, 246, 246, 1),
        // height: 50,
        width: MediaQuery.of(context).size.width / 1.1,
        child: Center(
          child: TextFormField(
            keyboardType: keyBoard,
            controller: Textcontroller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              filled: true,
              hintText: lableText,
              enabledBorder: const OutlineInputBorder(
                  // borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(color: Colors.white
                      // color: Color.fromRGBO(249, 246, 238, 1)
                      )),
              focusedBorder: const OutlineInputBorder(
                  // borderRadius: BorderRadius.circular(40),
                  borderSide:
                      BorderSide(color: Color.fromRGBO(246, 246, 246, 1))),
              fillColor: const Color.fromRGBO(246, 246, 246, 1),
              border: InputBorder.none,
              enabled: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget reportData() {
//    Report
// User will not know that you have reported them
// I am not interested.
// Inappropriate Post.
// Spam
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Report",
            style: FontManager().getTextStyle(
              context,
              fontSize: 18,
              lWeight: FontWeight.bold,
              //  fontFamily: AutofillHints.birthdayDay
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          style("User will not know that you have reported them"),
          style(" I am not interested."),
          style("Inappropriate Post."),
          style("Spam"),
        ],
      ),
    );
  }

  Widget style(str) {
    return InkWell(
      onTap: () {
        setState(() {
          dataReport = str;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          str,
          style: FontManager().getTextStyle(
            context,
            fontSize: 14,
            //  fontWeight: FontWeight.w400,
            //  fontFamily: AutofillHints.birthdayDay
          ),
        ),
      ),
    );
  }

  Widget myDis() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text("Discussions:",style: FontManager().getTextStyle(context,
        //                                                lWeight: FontWeight.w400,
        //                                                fontSize: 18,
        //                                                color: Colors.black)),
        findData
            ? Loader()
            : getTrendingData.length == 0
                ? Center(
                    child: Text("No Post Yet",
                        style: FontManager().getTextStyle(context)))
                : Column(
                    children: getTrendingData
                        .map((dataObj) => PostCard(data: dataObj))
                        .toList()),
      ],
    );
  }

  Widget uploadData2(dataObj) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color.fromRGBO(249, 246, 238, 1),
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_pin_sharp,
                            size: 35,
                            color: Colors.black,
                          ),
                          // ProfileImage(),
                          SizedBox(
                            width: 20,
                          ),
                          Text((dataObj["author"]['name']),
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color: Colors.black)),
                        ],
                      ),
                    ),
                    // Icon(
                    //   Icons.more_vert_outlined,
                    //   size: 25,
                    //   color: Colors.black,
                    // ),
                    popUpBox(dataObj['_id'], context),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text((dataObj['title']),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black)),
                ),

                // Padding(
                //   padding: const EdgeInsets.only(bottom: 10.0),
                //   child: Text((dataObj['description']['message']),
                //       style: FontManager().getTextStyle(context,
                //           lWeight: FontWeight.w400,

                //           fontSize: 16,
                //           color: Colors.black)),
                // ),

                dataObj['image'] != null && dataObj['image'] != "none"
                    ? Container(
                        width: MediaQuery.of(context).size.width / 1.1,
                        height: MediaQuery.of(context).size.height / 3,
                        child: Image.network(
                          dataObj['image'],
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        // child: Image.asset("assets/images/news.jpg", fit: BoxFit.fill),
                      )
                    : SizedBox.shrink(),
                const SizedBox(
                  height: 20,
                ),
                vote(context, dataObj, dataObj),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     Container(
                //       child: Row(
                //         children: [
                //            GestureDetector(
                //             onTap: (){
                //                  upvote(context,"Post",dataObj["_id"]);
                //             },
                //             child: const Icon(
                //               Icons.arrow_drop_up_outlined,
                //               size: 35,
                //               color: Colors.black,
                //             ),
                //           ),
                //           Text((dataObj["upvotes"].toString()),
                //               style: FontManager().getTextStyle(context,
                //                   lWeight: FontWeight.w400,
                //                   fontSize: 18,
                //                   color: Colors.black)),
                //           GestureDetector(
                //             onTap: (){
                //                  downvote(context,"Post",dataObj["_id"]);
                //             },
                //             child: const Icon(
                //               Icons.arrow_drop_down_outlined,
                //               size: 35,
                //               color: Colors.black,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //     Container(
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Container(
                //             height: 20,
                //             child: ProfileImage(url: "assets/images/comment.svg",)
                //             ),
                //           const SizedBox(width: 2,),
                //           Text(dataObj["comments"].toString(),style: FontManager().getTextStyle(context,
                //                                  lWeight: FontWeight.w400,
                //                                  fontSize: 18,
                //                                  color: Colors.black)),
                //            const SizedBox(width: 15),
                //           imageurl('assets/images2/share.svg'),
                //         ],
                //       ),
                //     )
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget reportShowDilaog() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // text('Score ${score.value} '),
          // textStyleDesign("Score "+doubleToFixed(score.value.toString()),Colorcodes.dropdown,18,context),
          Container(
            height: MediaQuery.of(context).size.height / 22,
            width: MediaQuery.of(context).size.width / 10,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context)
                          .size
                          .width, // Adjust height as needed
                      child: dataReport == ""
                          ? reportData()
                          : Container(
                              child: Center(
                                  child: style("Report has been submitted.")),
                            ),
                    );
                  },
                );
              },
              child: ProfileImage(
                url: svgIconPath.settingUser,
              ),
              // child: Icon(
              // Icons.settings,
              // size: 25,
              // color: Colorcodes.red,
              //                       ),
            ),
          )
        ],
      ),
    );
  }

  Widget nameAndAddFrd(data) {
    String avatar= data['avatarType'] !=null ? data['avatarType']
    :data['avatar']!=null?data['avatar']:userAvatar;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            // Container(
            //     // color: Colorcodes.black,
            //     child: AvatarProfileImage(
            //         url: data['avatarType'] ?? data['avatar'] ?? userAvatar,
            //         width: 10,
            //         height: 18)),
            const SizedBox(
              width: 5,
            ),
            Text((data['name']??""),
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black)),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        InkWell(
          onTap: () {
            //  addUserAsFrd(data['_id'], context);

            if (buttonValue.value=="Remove") {
                getRemoveFrds(context, data['_id']);
                 buttonValue.value="Add";
            } else if (buttonValue.value=="Add"){
                buttonValue.value="Requested";
                addUsersendRequest(data['_id'], data['name'], context);
            }
              else if(buttonValue.value=="Requested"){
                   buttonValue.value="Add";
                   removeRequest(data['_id'], data['name'], context);
              }
            else {
               buttonValue.value="Remove";
               addUserAsFrd(data['_id'], context);
            }

            ///removded
            // if (widget.flag) {
            //     getRemoveFrds(context, data['_id']);
            //     widget.flag=false;
            // } else if (already)
            //   addUsersendRequest(data['_id'], data['name'], context);
            //   else if(frdRequestCheck.value!=frdRequest.value){
            //        frdRequestCheck.value==frdRequest.value;
            //        removeRequest(data['_id'], data['name'], context);
            //   }
            // else {
            //   already=false;
            //   widget.flag=false;
            //   addUserAsFrd(data['_id'], context);
            // }


          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
            decoration: BoxDecoration(
                color: Colorcodes.cardShade3,
                borderRadius: BorderRadius.circular(5)),
            child:Obx(() =>textButton()),
          ),
        ),
      ],
    );
  }


  Widget textButton(){
    return Text(buttonValue.value,
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.white));
    // return Text(
    //             (widget.flag
    //                 ? "Remove"
    //                 : already
    //                     ? "Accept"
    //                     :frdRequestCheck.value!=frdRequest.value? "Requested" : "Add"),
    //             style: FontManager().getTextStyle(context,
    //                 lWeight: FontWeight.w400,
    //                 fontSize: 18,
    //                 color: Colors.white));
  }

  Widget aboutUser() {
    return Text(widget.data['aboutMe'] ?? "",
        style: FontManager().getTextStyle(context,
            lWeight: FontWeight.w400, fontSize: 16, color: Colors.black));
  }
}

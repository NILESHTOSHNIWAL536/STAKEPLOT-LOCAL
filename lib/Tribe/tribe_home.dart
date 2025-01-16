import 'dart:convert';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_share.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/readmore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter_application_code_stakeplot/Community_Page/postCard.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/headersList/userProfileHeader.dart";
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

List postListIds = [];

// RxList getTrendingData=[].obs;
// RxList historyListData=[].obs;
bool findData = true;
bool findTranding = true;
RxInt indexFlag = 0.obs;

class TribeHome extends StatefulWidget {
  const TribeHome({Key? key}) : super(key: key);

  @override
  _TribeHomeState createState() => _TribeHomeState();
}

class _TribeHomeState extends State<TribeHome> {
  int index = 1;
  List data = [0, 1, 2, 3];
  RxBool fill = false.obs;

  List<Color> color = [
    Colors.blue,
    Colors.redAccent,
    Colors.green,
    Colors.amber,
    Colors.cyanAccent
  ];

  @override
  void initState() {
    super.initState();
    getTransaction();
    getTrending();
    getChatLoader();
  }

  void getTransaction() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    // https://stakeplot.in/api/v1/post/feed
    final response = await http.get(
      Uri.parse('${url}/post/feed'),
      // Uri.parse('https://stakeplot.in/api/v1/post/all'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );

    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];

      historyListData.clear();
      historyListData.addAll(obj);

      historyListData.forEach((element) {
        postCount[element["_id"]] =
            element['upvotes'] < 0 ? 0 : element['upvotes'];
      });
      //  setState(() {
      findData = false;
      // });
    } else {}
  }

  void getTrending() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('${url}/post/trending'),
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
        getTrendingData.clear();
        getTrendingData.addAll(obj);
        findTranding = false;
      });

      getTrendingData.forEach((element) {
        postCount[element["_id"]] =
            element['upvotes'] < 0 ? 0 : element['upvotes'];
      });
    } else {}
  }

// final GFBottomSheetController _controller = GFBottomSheetController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //    bottomSheet: GFBottomSheet(
      // controller: _controller,
      // maxContentHeight: 150,
      // stickyHeaderHeight: 100,

      //  contentBody: Container(
      //   height: 200,
      //   margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      //   child: ListView(
      //     shrinkWrap: true,
      //     physics: const ScrollPhysics(),
      //     children: const [
      //       Center(
      //           child: Text(
      //             'Getwidget reduces your overall app development time to minimum 30% because of its pre-build clean UI widget that you can use in flutter app development. We have spent more than 1000+ hours to build this library to make flutter developer’s life easy.',
      //             style: TextStyle(
      //                 fontSize: 15, wordSpacing: 0.3, letterSpacing: 0.2),
      //           ))
      //     ],
      //   ),
      // ),
      // ),

      appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  ("Tribe"),
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colorcodes.services),
                ),
                const Spacer(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     PageTransition(
                        //           type: PageTransitionType.fade,
                        //           duration: Durations.long1,
                        //           child:TribeSearch(),
                        //           isIos: true,
                        //     ),
                        //   );
                        Navigator.pushNamed(context, '/TribeSearch');
                      },
                      child: Container(
                          width: 30,
                          height: 40,
                          padding: EdgeInsets.all(0),
                          child: ProfileImage(url: svgIconPath.search)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          //                   Navigator.push(
                          //   context,
                          //   PageTransition(
                          //         type: PageTransitionType.fade,
                          //         duration: Durations.long1,
                          //         child:TribeChats(),
                          //         isIos: true,
                          //   ),
                          // );
                          Navigator.pushNamed(context, '/TribeChats');
                        },
                        child: Container(
                            height: 40,
                            width: 30,
                            child: ProfileImage(url: svgIconPath.message)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),

      floatingActionButton: Obx(() => indexFlag.value == 1
          ? SizedBox.shrink()
          : InkWell(
              onTap: () {
                //  PostData
                Navigator.pushNamed(context, '/PostData');
              },
              child: CircleAvatar(
                  backgroundColor: Colorcodes.debtBody,
                  // backgroundColor: Color.fromRGBO(246, 246, 246, 1)
                  child: Icon(
                    Icons.edit,
                    color: Colorcodes.white,
                  )),
            )),
      //  bottomNavigationBar: MyHomePage(data: 2,),
      bottomNavigationBar: BottomNavigations(data: sizeRoom ? 3 : 2),
      extendBody: true,
      body: Obx(() => Container(
            height: MediaQuery.of(context).size.height,
            // color: Colors.black,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //  tribeHeader(context,"home"),

                  const SizedBox(
                    height: 10,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        getFeedReward(0, "Feed"),
                        getFeedReward(1, "Trending"),
                        // InkWell(
                        //     onTap: () {
                        //         //  setState(() {
                        //              indexFlag.value=0;
                        //         //  });
                        //     },
                        //      child: Container(
                        //          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                        //           decoration: BoxDecoration(
                        //            color:indexFlag.value==0? Color.fromRGBO(249, 246, 238, 1):Colors.white,
                        //                 borderRadius: BorderRadius.circular(10)
                        //           ),
                        //        child: Text(("Feed"),
                        //                style: FontManager().getTextStyle(context,
                        //                  lWeight: FontWeight.w400,
                        //                  fontSize: 20,
                        //                  color: Colors.black)),
                        //      ),
                        //    ),

                        //  InkWell(
                        //   onTap: () {

                        //            indexFlag.value=1;

                        //   },
                        //    child: Container(
                        //        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                        //         decoration: BoxDecoration(
                        //         color:indexFlag.value==1? Color.fromRGBO(249, 246, 238, 1):Colors.white,
                        //          borderRadius: BorderRadius.circular(10)
                        //         ),
                        //      child: Text(("Trending"),
                        //                                                  style: FontManager().getTextStyle(context,
                        //                lWeight: FontWeight.w400,
                        //                fontSize: 20,
                        //                color: Colors.black)),
                        //    ),
                        //  ),
                        //  InkWell(
                        //   onTap: () {
                        //        setState(() {
                        //            indexFlag.value=3;
                        //        });
                        //   },
                        //    child: Container(
                        //        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                        //         decoration: BoxDecoration(
                        //         color:indexFlag.value==3? Color.fromRGBO(249, 246, 238, 1):Colors.white,
                        //          borderRadius: BorderRadius.circular(10)
                        //         ),
                        //      child: Text(("Rewards"),
                        //                                                  style: FontManager().getTextStyle(context,
                        //                lWeight: FontWeight.w400,
                        //                fontSize: 20,
                        //                color: Colors.black)),
                        //    ),
                        //  ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  AnimatedCrossFade(
                      secondChild:
                          Obx(() => historyListData.length == 0 && findData
                              ? Loader()
                              : !findData && historyListData.length == 0
                                  ? addFrd()
                                  : Column(
                                      children: [
                                        Container(
                                            child: Column(
                                                children: historyListData
                                                    .map((dataObj) =>
                                                        PostCard(data: dataObj))
                                                    .toList())),
                                        SizedBox(
                                          height: 100,
                                        ),
                                      ],
                                    )),
                      firstChild:
                          Obx(() => getTrendingData.length == 0 && findTranding
                              ? Loader()
                              : !findTranding && getTrendingData.length == 0
                                  ? Text("No Post yet")
                                  : Column(
                                      children: [
                                        Container(
                                            child: Column(
                                                children: getTrendingData
                                                    .map((dataObj) =>
                                                        PostCard(data: dataObj))
                                                    .toList())),
                                        SizedBox(
                                          height: 100,
                                        ),
                                      ],
                                    )),
                      crossFadeState: indexFlag.value == 1
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 500))
                ],
              ),
            ),
          )),
    );
  }

  Widget imageurl(url) {
    return SvgPicture.asset(
      url,
      height: 30,
    );
  }

  Widget getFeedReward(int value, String title) {
    return InkWell(
      onTap: () {
        //  setState(() {
        indexFlag.value = value;
        //  });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        decoration: BoxDecoration(
            //  color:indexFlag.value==value? Color.fromRGBO(249, 246, 238, 1):Colors.white,
            borderRadius: BorderRadius.circular(10),
            color: indexFlag.value == value
                ? Colorcodes.budgetDarkGreen
                : Colorcodes.budgetLightGreen,
            border: Border.all(color: Colorcodes.budgetDarkGreen)),
        child: Text((title),
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.w400,
                fontSize: 20,
                color: indexFlag.value == value
                    ? Colorcodes.white
                    : Colors.black)),
      ),
    );
  }

  Widget uploadData(dataObj) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: Card(
        elevation: Colorcodes.elevation5,
        // color: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    duration: Durations.long1,
                    child: TribeUnique(
                      id: dataObj["_id"],
                      dataObj: dataObj,
                    ),
                    isIos: true,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 3, 20, 20),
                decoration: BoxDecoration(
                    color: Colorcodes.dropdown,
                    // color: const Color.fromRGBO(249, 246, 238, 1),
                    // color: Colorcodes.textFeild,
                    borderRadius:
                        BorderRadius.circular(Colorcodes.borderRadius)),
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
                              AvatarProfileImage(
                                url: dataObj["author"]['avatar'],
                                width: 8,
                                height: 12,
                              ),
                              const SizedBox(
                                width: 10,
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
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 10),
                    //   child: Text((dataObj['title']),
                    //       style: FontManager().getTextStyle(context,
                    //           lWeight: FontWeight.w400,
                    //           fontSize: 16,
                    //           color: Colors.black)),
                    // ),
                    Readmore(
                      str: dataObj['title'].toString(),
                    ),
                    //   ReadMoreText(
                    //     dataObj['title'].toString(),
                    //     trimMode: TrimMode.Line,
                    //     trimLines: 2,

                    //     colorClickableText: Colors.pink,
                    //     trimCollapsedText: 'Show more',
                    //     trimExpandedText: 'Show less',
                    //     moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    // ),
                    Container(
                        child: !dataObj['isItenary']
                            ? text(dataObj)
                            : dataObj['chartType'] == "bargraph"
                                ? barGraph(dataObj)
                                : pieChart(dataObj)),
                    //  Readmore(str:dataObj['description']['message'].toString(),),
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 10.0),
                    //   child: Text((dataObj['description']['message']),
                    //       style: FontManager().getTextStyle(context,
                    //           lWeight: FontWeight.w400,

                    //           fontSize: 16,
                    //           color: Colors.black)),
                    // ),

                    const SizedBox(
                      height: 20,
                    ),

                    //  dataObj['image']  != null && dataObj['image'] !="none"  ?     GFImageOverlay(
                    //           width: MediaQuery.of(context).size.width / 1.1,
                    //           height: MediaQuery.of(context).size.height/2.5,
                    //           shape: BoxShape.rectangle,
                    //           // image: NetworkImage("https://res.cloudinary.com/deus5rcgl/image/upload/v1712693443/public/jznh2qhs2dbduf7ff0t2.jpg"),
                    //           image: NetworkImage(dataObj['image']),
                    //           colorFilter:ColorFilter.mode(Colors.black.withOpacity(0.0),
                    //           BlendMode.exclusion),
                    //      ):SizedBox.shrink(),

                    const SizedBox(
                      height: 5,
                    ),

                    vote(context, dataObj, data),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget commentedData() {
    TextEditingController calController1 = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: const Color.fromRGBO(249, 246, 238, 1),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              dataComment(),
              dataComment(),
              dataComment(),
              dataComment(),
              InputDate(
                  "write comment..", TextInputType.number, calController1),
            ],
          )),
    );
  }

  Widget dataComment() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.person_pin_sharp,
              size: 35,
              color: Colors.black,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(('user'),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.black)),
                ),
                Text(('comment'),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Colors.black)),
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
                        size: 35,
                        color: Colors.black,
                      ),
                      Text(('reply'),
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Colors.black)),
                    ],
                  ),
                ),
              ],
            )
          ]),
    );
  }

  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        // color:  Color.fromRGBO(246, 246, 246, 1),
        width: MediaQuery.of(context).size.width / 1.3,
        child: TextFormField(
          keyboardType: keyBoard,
          controller: Textcontroller,
          decoration: InputDecoration(
            filled: true,
            hintText: lableText,
            enabledBorder: OutlineInputBorder(
                // borderRadius: BorderRadius.circular(40),
                borderSide: const BorderSide(color: Colors.white
                    // color: Color.fromRGBO(249, 246, 238, 1)
                    )),
            focusedBorder: OutlineInputBorder(
                // borderRadius: BorderRadius.circular(40),
                borderSide:
                    BorderSide(color: Color.fromRGBO(246, 246, 246, 1))),
            fillColor: Color.fromRGBO(246, 246, 246, 1),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget feedWidgets() {
    return Column(
      children: [
        Container(
          child: Wrap(
            children: historyListData
                .map((item) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 1, vertical: 5),
                      child: Card(
                        elevation: Colorcodes.elevation3,
                        color: Colors.grey,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                duration: Durations.long1,
                                child: TribeUnique(
                                  id: item["_id"],
                                  dataObj: item,
                                ),
                                isIos: true,
                              ),
                            );
                          },
                          child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 20),
                              width: MediaQuery.of(context).size.width,
                              //  height:MediaQuery.of(context).size.height/2.9,
                              decoration: BoxDecoration(
                                color: Colorcodes.appBarColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Row(
                                          children: [
                                            // Icon(
                                            //   Icons.person_pin_sharp,
                                            //   size: 35,
                                            //   color: Colors.black,
                                            // ),
                                            AvatarProfileImage(
                                              url: item["author"]['avatar'],
                                              width: 8,
                                              height: 11,
                                            ),
                                            // ProfileImage(),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text((item["author"]['name']),
                                                style: FontManager()
                                                    .getTextStyle(context,
                                                        lWeight:
                                                            FontWeight.w400,
                                                        fontSize: 18,
                                                        color: Colors.black)),
                                          ],
                                        ),
                                      ),
                                      popUpBox(item['_id'], context),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),

                                  Readmore(
                                    str: item['title'].toString().toString(),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  //   item['image'] != null && item['image'] !="none" ?  GFImageOverlay(
                                  //       width: MediaQuery.of(context).size.width / 1.1,
                                  //       height: MediaQuery.of(context).size.height/3,
                                  //       shape: BoxShape.rectangle,
                                  //       //  image: NetworkImage("https://res.cloudinary.com/deus5rcgl/image/upload/v1712693443/public/jznh2qhs2dbduf7ff0t2.jpg"),

                                  //       image: NetworkImage(item['image']),
                                  //       colorFilter:ColorFilter.mode(Colors.black.withOpacity(0.0),
                                  //       BlendMode.exclusion),
                                  // ):SizedBox.shrink(),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  Container(
                                      child: !item['isItenary']
                                          ? text(item)
                                          : item['chartType'] == "bargraph"
                                              ? barGraph(item)
                                              : pieChart(item)),

                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   crossAxisAlignment: CrossAxisAlignment.center,
                                  //   children: [
                                  //     Container(
                                  //       child: Row(
                                  //         children: [
                                  //            GestureDetector(
                                  //             onTap: (){
                                  //                  upvote(context,"Post",item["_id"],item);

                                  //                 // //  setState(() {
                                  //                 //       getTransaction();
                                  //                 //       //  getTrending();
                                  //                 // //  });
                                  //             },
                                  //             child: const Icon(
                                  //               Icons.arrow_drop_up_outlined,
                                  //               size: 35,
                                  //               color: Colors.black,
                                  //             ),
                                  //           ),
                                  //           Text((item["upvotes"].toString()),
                                  //               style: FontManager().getTextStyle(context,
                                  //                   lWeight: FontWeight.w400,
                                  //                   fontSize: 18,
                                  //                   color: Colors.black)),
                                  //           GestureDetector(
                                  //             onTap: (){
                                  //                  downvote(context,"Post",item["_id"],item);

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
                                  //           Text(item["comments"].toString(),style: FontManager().getTextStyle(context,
                                  //                                  lWeight: FontWeight.w400,
                                  //                                  fontSize: 18,
                                  //                                  color: Colors.black)),
                                  //            const SizedBox(width: 15),
                                  //           InkWell(
                                  //             onTap: () {

                                  //   showModalBottomSheet(context: context,
                                  //    backgroundColor: Colorcodes.appBarColor,

                                  //    builder: (context) {
                                  //           return TribeShare(data: data,dataObj:item);
                                  //        },);

                                  //             },
                                  //             child: imageurl('assets/images2/share.svg')),
                                  //         ],
                                  //       ),
                                  //     )
                                  //   ],
                                  // ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  vote(context, item, data),
                                ],
                              )),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        SizedBox(
          height: 100,
        ),
      ],
    );
  }

  Widget text(item) {
    return Readmore(
      str: item['description']['message'].toString(),
    );
  }

  Widget barGraph(item) {
    List<SalesData> chartData = <SalesData>[];
    List list = item['description']['itemlist'];

    int j = 0;
    list.forEach(
      (element) {
        String t1 = element['item'];
        String t2 = element['amount'].toString();
        if (j == color.length) j = 0;
        String b = t2 == "" ? "0" : t2;

        chartData.add(
          SalesData(t1, double.parse(b)),
        );
      },
    );

    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 30),
      // width: MediaQuery.of(context).size.width/2,
      // width: 300,
      // height:170,
      height: MediaQuery.of(context).size.height / 4.7,

      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        isTransposed: true,
        series: <CartesianSeries>[
          BarSeries<SalesData, String>(
            dataSource: chartData,
            onPointTap: (pointInteractionDetails) {
              Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    duration: Durations.long1,
                    child: TribeUnique(
                      id: item["_id"],
                      dataObj: item,
                    ),
                    isIos: true,
                  ));
            },
            xValueMapper: (SalesData sales, _) => sales.month,
            yValueMapper: (SalesData sales, _) => sales.sales,
          )
        ],
      ),
    );
  }

  Widget pieChart(item) {
    final List<ChartData> chartData = [];

    if (item['description'] == null || item['description']['itemlist'] == null)
      return SizedBox.shrink();

    List list = item['description']['itemlist'];

    int j = 0;

    list.forEach((element) {
      String t1 = element['item'];
      String t2 = element['amount'].toString();
      if (j == color.length) j = 0;
      String b = t2 == "" ? "0" : t2;

      chartData.add(
        ChartData(t1, list.length == 1 ? 100 : double.parse(b), color[j++], t1),
      );
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(

          //  width: 30,
          height: MediaQuery.of(context).size.height / 4.7,
          child: SfCircularChart(series: <CircularSeries>[
            // Render pie chart
            PieSeries<ChartData, String>(
              dataSource: chartData,

              radius: "100",
              explodeOffset: "4%",

              dataLabelMapper: (ChartData data, _) => '${data.name}',
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              onPointTap: (pointInteractionDetails) {
                Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      duration: Durations.long1,
                      child: TribeUnique(
                        id: item["_id"],
                        dataObj: item,
                      ),
                      isIos: true,
                    ));
              },
              // strokeWidth: 5.0,
              dataLabelSettings: DataLabelSettings(
                isVisible: true, // Show labels
              ),
            )
          ])),
    );
  }

  void pushName(widgetName) {
    getTransaction();
    getTrending();
  }

  Widget addFrd() {
    return Container(
        width: MediaQuery.of(context).size.width / 1.2,
        height: MediaQuery.of(context).size.height / 1.6,
        // color: Colorcodes.billBody,
        child: Center(
            child: Text(StringConstant.tribeText,
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 24,
                    lineHeight: 1.3,
                    color: Colorcodes.dropdown))));
  }

// void upvote(context,String str,String objectId,dataObj)async{
//     final SharedPreferences _pref = await SharedPreferences.getInstance();
//      var  accessToken=_pref.getString("accessToken");
//     final response = await http.post(
//     Uri.parse('${url}/upvote/'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//        "Authorization": "$accessToken",
//     },
//     body: jsonEncode({
//             'onModel': str.toString(),
//             'objectId':objectId,
//        }),
//   );
//       if(response.statusCode==200 || response.statusCode==201){
//             final body = json.decode(response.body);

//              if(!postListIds.contains(objectId)){
//                    setState(() {
//                     dataObj["upvotes"]++;
//                   });
//                    snackBarCalled(context,"Liked!",Colors.black);
//                   postListIds.add(objectId);
//              }else{
//                  setState(() {
//                     dataObj["upvotes"]--;
//                   });
//                    snackBarCalled(context,"Removed Liked!",Colors.black);
//                   postListIds.remove(objectId);
//              }
//             //  Navigator.pop(context);
//             //  Navigator.pushNamed(context, '/TribeHome');

//       }else{
//            snackBarCalled(context,"error while Liked!",Colors.red);
//       }

// }

// Widget vote(dataObj){
//   return  Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 8,vertical: 6),
//                            decoration: BoxDecoration(
//                                 border: Border.all(),
//                                 borderRadius: BorderRadius.circular(100)
//                            ),
//                           child: Row(
//                             children: [
//                                GestureDetector(
//                                 onTap: (){
//                                      upvote(context,"Post",dataObj["_id"],dataObj);
//                                 },
//                                 child: upvoteLiked(context),

//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 5.0),
//                                 child: Text((dataObj["upvotes"].toString()),
//                                     style: FontManager().getTextStyle(context,
//                                         lWeight: FontWeight.w400,
//                                         fontSize: 18,
//                                         color: Colors.black)),
//                               ),
//                               GestureDetector(
//                                 onTap: (){
//                                      downvote(context,"Post",dataObj["_id"],dataObj);

//                                 },
//                                  child: downvoteLike(context),
//                                 // child: const Icon(
//                                 //   Icons.arrow_drop_down_outlined,
//                                 //   size: 35,
//                                 //   color: Colors.black,
//                                 // ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Container(
//                                padding: EdgeInsets.symmetric(horizontal: 8,vertical: 6),
//                                decoration: BoxDecoration(
//                                 border: Border.all(),
//                                 borderRadius: BorderRadius.circular(100)
//                            ),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       height: 25,
//                                       child: ProfileImage(url: "assets/images/comment.svg",)
//                                       ),
//                                       const SizedBox(width: 6,),
//                               Text(dataObj["comments"].toString(),style: FontManager().getTextStyle(context,
//                                                      lWeight: FontWeight.w400,
//                                                      fontSize: 18,
//                                                      color: Colors.black)),
//                                const SizedBox(width: 7),
//                                   ],
//                                 ),
//                               ),

//                                const SizedBox(width: 15),

//                               InkWell(
//                                 onTap: () {

//                            showModalBottomSheet(context: context,
//                             backgroundColor: Colorcodes.appBarColor,
//                            builder: (context) {
//                                 return TribeShare(data: data,dataObj:dataObj);
//                            },);

//                                 },
//                                 child: imageurl('assets/images2/share.svg')),
//                             ],
//                           ),
//                         )
//                       ],
//                     );
// }
}

class SalesData {
  final String month;
  final double sales;

  SalesData(this.month, this.sales);
}

Widget popUpBox(id, context) {
  return PopupMenuButton(
    initialValue: 2,
    color: Colorcodes.appBarColor,
    child: Center(
        child: Icon(
      Icons.more_vert_outlined,
      size: 25,
      color: Colorcodes.white,
    )),
    onSelected: (value) {
      if (value == 1) {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return showModel(context, id);
          },
        );
      } else {
        reportPost(context, id, "hide post");
      }
    },
    itemBuilder: (context) {
      return [
        const PopupMenuItem(
          value: 0,
          child: Text("hide"),
        ),
        const PopupMenuItem(
          value: 1,
          child: Text("Report"),
        ),
      ];
    },
  );
}

Widget vote(context, dataObj, data) {
  String idData = dataObj["_id"];
  // String countComment=postCommentCount[idData].toString();
  return Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            color: Colorcodes.iconBackGround,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            //  decoration: BoxDecoration(
            //       // border: Border.all(),
            //       // borderRadius: BorderRadius.circular(100)
            //  ),
            child: Row(
              children: [
                // const SizedBox(width: 2,),
                Container(
                  height: 25,
                  child: GestureDetector(
                    onTap: () {
                      String l1 = "liked" + dataObj["_id"];
                      bool liked = likedList.contains(l1);

                      String l2 = "disliked" + dataObj["_id"];
                      bool disliked = likedList.contains(l2);
                      upvoteGlobal(context, "Post", dataObj["_id"], dataObj);
                      // likedList.remove("liked"+dataObj["_id"])  :likedList.add("liked"+dataObj["_id"]);

                      if (liked) {
                        likedList.remove(l1);
                        postCount[idData] = postCount[idData]! - 1;
                        // if(postCount[idData]!<0)
                        // {
                        //   postCount[idData]=0;
                        // }
                      } else {
                        likedList.add(l1);
                        postCount[idData] = postCount[idData]! + 1;
                      }
                      likedList.remove(l2);
                      reRender.value = !reRender.value;
                    },
                    child: likedList.contains("liked" + dataObj["_id"])
                        ? upvoteLiked(context)
                        : upvoteLike(context),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                      reRender.value
                          ? postCount[dataObj['_id']]! < 0
                              ? postCount[dataObj['_id']].toString()
                              : (postCount[dataObj['_id']].toString())
                          : (postCount[dataObj['_id']].toString()),
                      // child: Text(reRender.value? postCount[dataObj['_id']]!<0? '0':  (postCount[dataObj['_id']].toString()):(postCount[dataObj['_id']].toString()),
                      // child: Text((dataObj["upvotes"].toString()),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colorcodes.white)),
                ),

                Container(
                  height: 25,
                  child: GestureDetector(
                    onTap: () {
                      downvoteBlobal(context, "Post", dataObj["_id"], dataObj);
                      String l1 = "liked" + dataObj["_id"];
                      bool liked = likedList.contains(l1);

                      String l2 = "disliked" + dataObj["_id"];
                      bool disliked = likedList.contains(l2);
                      // likedList.remove("liked"+dataObj["_id"])  :likedList.add("liked"+dataObj["_id"]);
                      reRender.value = !reRender.value;
                      if (disliked) {
                        if (liked) {
                          postCount[idData] = postCount[idData]! - 1;
                          if (postCount[idData]! < 0) {
                            postCount[idData] = 0;
                          }
                          likedList.remove(l1);
                        }
                        likedList.remove(l2);
                      } else {
                        //  likedList.add(l1);
                        if (liked) {
                          postCount[idData] = postCount[idData]! - 1;
                          if (postCount[idData]! < 0) {
                            postCount[idData] = 0;
                          }
                          likedList.remove(l1);
                        }

                        //  postCount[idData]=postCount[idData]!-1;
                        likedList.add(l2);
                      }
                    },
                    child: likedList.contains("disliked" + dataObj["_id"])
                        ? downvoteLiked(context)
                        : downvoteLike(context),
                    // child: const Icon(
                    //   Icons.arrow_drop_down_outlined,
                    //   size: 35,
                    //   color: Colors.black,
                    // ),
                  ),
                ),

                //  const SizedBox(width: 2,),
              ],
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  color: Colorcodes.iconBackGround,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  //      decoration: BoxDecoration(
                  //       border: Border.all(),
                  //       borderRadius: BorderRadius.circular(100)
                  //  ),
                  child: Row(
                    children: [
                      Container(
                          height: 25,
                          child: SvgPicture.asset(
                            svgIconPath.comment,
                            color: Colorcodes.white,
                          )
                          // child: ProfileImage(url: "assets/images/comment.svg",)
                          ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                          postCommentCount[idData].toString() == 'null'
                              ? dataObj["comments"].toString()
                              : postCommentCount[idData].toString(),
                          style: FontManager().getTextStyle(context,
                              // Text(dataObj["comments"].toString(),style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Colorcodes.white)),
                      const SizedBox(width: 7),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  color: Colorcodes.iconBackGround,
                  child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colorcodes.appBarColor,
                          builder: (context) {
                            return TribeShare(data: data, dataObj: dataObj);
                          },
                        );
                      },
                      child: imageurlcard(svgIconPath.share)),
                ),
              ],
            ),
          )
        ],
      ));
}

void upvoteGlobal(context, String str, String objectId, dataObj) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.post(
    Uri.parse('${url}/upvote/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'onModel': str.toString(),
      'objectId': objectId,
    }),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);

    if (!postListIds.contains(objectId)) {
      //  setState(() {
      dataObj["upvotes"]++;
      // });
      //  snackBarCalled(context,"Liked!",Colors.black);
      postListIds.add(objectId);
    } else {
      //  setState(() {
      dataObj["upvotes"]--;
      // });
      //  snackBarCalled(context,"Removed Liked!",Colors.black);
      postListIds.remove(objectId);
    }
    //  Navigator.pop(context);
    //  Navigator.pushNamed(context, '/TribeHome');
  } else {
    //  snackBarCalled(context,"error while Liked!",Colors.red);
  }
}

void downvoteBlobal(context, String str, String objectId, dataObj) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.post(
    Uri.parse('${url}/downvote/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'onModel': str.toString(),
      'objectId': objectId,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    //  snackBarCalled(context,"DisLiked!",Colors.black);

    if (postListIds.contains(objectId)) {
      // setState(() {
      dataObj["upvotes"]--;
      // });
      postListIds.remove(objectId);
    }
  } else {
    //  snackBarCalled(context,"error while DisLiked!",Colors.red);
  }
}

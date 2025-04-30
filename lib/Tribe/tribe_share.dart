import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/readmore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
// import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:page_transition/page_transition.dart';
import "package:flutter_application_code_stakeplot/Community_Page/postCard.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import 'package:http/http.dart' as http;
import "package:shared_preferences/shared_preferences.dart";
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TribeShare extends StatefulWidget {
  var data;
  var dataObj;
  TribeShare({Key? key, required this.data, required this.dataObj})
      : super(key: key);

  @override
  _TribeHomeState createState() => _TribeHomeState();
}

class _TribeHomeState extends State<TribeShare> {
  // RxList frdsList=[].obs;
  // RxList  frdsListOrigin=[].obs;
  RxBool frdsThere = false.obs;
  List addedUser = [];
  List nameList = [];
  late IO.Socket socket;
  RxString roomId = "".obs;

  @override
  void initState() {
    super.initState();
    getTransaction();
    socket = IO.io(urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    setUpSocketListener();
  }

  void getTransaction() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('https://stakeplot.in/api/v1/user/info'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];
      frdsList.clear();
      frdsListOrigin.clear();
      frdsList.addAll(obj['friendsList']);
      frdsListOrigin.addAll(frdsList);
      frdsThere = false.obs;
    } else {}
  }

  TextEditingController Textcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return commentedData();

    // return Scaffold(
    //   bottomNavigationBar:  BottomNavigations(data: sizeRoom?3:2),
    //    extendBody: true,
    //   body: Container(
    //     height: MediaQuery.of(context).size.height,
    //     color: Colors.white,
    //     // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    //     child: SingleChildScrollView(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //            tribeHeader(context),
    //            Container(
    //                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    //             child: uploadData(widget.data)
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  setUpSocketListener() {
    socket.on(
        "disconnect",
        (data) => {
              socket.close(),
            });
  }

  Widget imageurl(url) {
    return SvgPicture.asset(
      url,
      height: 30,
    );
  }

  Widget uploadData(dataObj) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(15),
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
                      // )
                      popUpBox(dataObj['_id']),
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

                  //  dataObj['image'] != null
                  //     ? Container(
                  //         width: MediaQuery.of(context).size.width / 1.3,
                  //         child: Image.network(dataObj['image']['filePath'],
                  //             fit: BoxFit.fill),
                  //         // child: Image.asset("assets/images/news.jpg", fit: BoxFit.fill),
                  //       )
                  //     : SizedBox.shrink(),

                  //  dataObj['image'] != null?  GFImageOverlay(
                  //         width: MediaQuery.of(context).size.width / 1.1,
                  //         height: MediaQuery.of(context).size.height/2.5,
                  //         shape: BoxShape.rectangle,
                  //         image: NetworkImage(dataObj['image']),
                  //         colorFilter:ColorFilter.mode(Colors.black.withOpacity(0.0),
                  //         BlendMode.exclusion),
                  //    ):SizedBox.shrink(),

                  Container(
                      child: !dataObj['isItenary']
                          ? text(dataObj)
                          : dataObj['chartType'] == "bargraph"
                              ? barGraph(dataObj)
                              : pieChart(dataObj)),

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
                            GestureDetector(
                              onTap: () {
                                upvote(
                                    context, "Post", dataObj['_id'], dataObj);
                                // navigate();
                              },
                              child: const Icon(
                                Icons.arrow_drop_up_outlined,
                                size: 35,
                                color: Colors.black,
                              ),
                            ),
                            Text((dataObj["upvotes"].toString()),
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 18,
                                    color: Colors.black)),
                            GestureDetector(
                              onTap: () {
                                downvote(
                                    context, "Post", dataObj['_id'], dataObj);
                                // navigate();
                              },
                              child: const Icon(
                                Icons.arrow_drop_down_outlined,
                                size: 35,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      imageurl('assets/images2/share.svg')
                    ],
                  ),
                ],
              ),
            ),
          ),
          commentedData(),
        ],
      ),
    );
  }

  Widget commentedData() {
    double height = MediaQuery.of(context).size.height / 3;
    return Container(
      //  padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            InputDate('Search', TextInputType.name, Textcontroller),
            frdsThere.value
                ? Container(height: height, child: Center(child: Loader()))
                : frdsList.isEmpty
                    ? Container(
                        height: height,
                        child: Center(child: Text("No Friend Found")))
                    : listOfUsres(height),
            shareButton()
          ],
        ),
      ),
    );
  }

  Widget shareButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            //  home
            //  Navigator.pushNamed(context, '/home');
            if (frdsList.isEmpty) {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/TribeSearch');
              return;
            }

            if (addedUser.isEmpty) {
              snackBarCalled(context, "No friends have been added.");
              return;
            }

            int index = 0;
            addedUser.forEach((rec) {
              String room1 = nameList[index] + userName.value;
              String room2 = userName.value + nameList[index];

              String roomId = (room1.compareTo(room2) <= 0) ? room1 : room2;

              // socketConnection();
              var jsonData = {
                "messageType": "post",
                "receiver": rec,
                "sender": currentId.value,
                "message": null,
                "image": null,
                "poll": null,
                "post": {
                  "postTitle": widget.dataObj['title'],
                  "postDescription": widget.dataObj['description'].toString(),
                  "postImage": widget.dataObj['image'],
                  "postId": widget.dataObj['_id'],
                  "postLocation": jsonEncode(widget.dataObj),
                },
                "split": null,
                "roomId": roomId,
              };
              socket.emit("joinRoom", roomId);
              socket.emit("message", jsonData);

              String userToSend = nameList[index] + "" + nameList[index];
              socket.emit("LoadCharts", {
                "roomId": userToSend,
              });
              index++;
              sendNotificationsToDevice(rec, context,"Hey there! 👋, ${userName.value} has shared a post 📩. Please check it out 🛒 ","/chat/${currentId.value}",widget.dataObj['title'],widget.dataObj['image']);
            });
            Navigator.pop(context);
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 1.4,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
                color:
                    addedUser.isEmpty ? AppColors.bg6 : AppColors.primaryColor,
                borderRadius: BorderRadius.circular(24)),
            child: Center(
              child: Text((frdsList.isEmpty ? "Add Friends" : "Share"),
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.mt)),
            ),
          ),
        ),
      ],
    );
  }

  Widget listOfUsres(height) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        height: height,
        child: GridView.builder(
          itemCount: frdsList.length, // +1 for loading more indicator
          itemBuilder: (context, index) {
            String values = frdsList[index]['_id'];
            String name = frdsList[index]['name'];
            return InkWell(
              onTap: () {},
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        addedUser.contains(values)
                            ? addedUser.remove(values)
                            : addedUser.add(values);
                        nameList.contains(name)
                            ? nameList.remove(name)
                            : nameList.add(name);
                      });
                    },
                    child: Container(
                      // color:Colors.deepOrangeAccent,
                      width: MediaQuery.of(context).size.width / 5,
                      //  height: 50,
                      // backgroundColor:const Color.fromRGBO(249, 246, 238, 1),
                      child: Stack(
                        children: [
                          Center(
                              child: AvatarProfileImage(
                                  url: avaterUrlPath(frdsList[index]['name'] ?? userAvatar),
                                  width: 8,
                                  height: 18)),
                          // const SizedBox(width:  10,),
                          addedUser.contains(values)
                              ? const Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 30,
                                    color: Colors.green,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    (frdsList[index]['name']),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.bg1),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Number of columns
            crossAxisSpacing: 0.0, // Spacing between columns
            mainAxisSpacing: 0.0, // Spacing between rows
          ),
        ),
      ),
    );
  }

  void sendPost(context, jsonData) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.post(
      Uri.parse('${url}/chat/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode(jsonData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);

      snackBarCalled(context, 'Post sent successfully!');
      Navigator.pop(context);
    } else {
      snackBarCalled(context, "can't add!", Colors.red);
    }
  }

  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        width: MediaQuery.of(context).size.width / 1.1,
        // height: 50,
        child: Center(
          child: TextFormField(
            keyboardType: keyBoard,
            controller: Textcontroller,
            onChanged: (value) {
              //  setState((){
              frdsList.clear();
              frdsList.addAll(getSearchDataRx(value, frdsListOrigin));
              //  });
            },
            decoration: InputDecoration(
              //contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              filled: true,
              hintText: lableText,

              
              fillColor: AppColors.mt,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(24), // Add your desired radius here
                borderSide:
                    BorderSide.none, // Keep the border invisible if needed
              ),
            ),
          ),
        ),
      ),
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

  void upvote(context, String str, String objectId, dataObj) async {
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
      snackBarCalled(context, "You liked this post!");

      if (!postListIds.contains(objectId)) {
        setState(() {
          dataObj["upvotes"]++;
        });
        postListIds.add(objectId);
      } else {
        setState(() {
          dataObj["upvotes"]--;
        });
        postListIds.remove(objectId);
      }
      //  Navigator.pop(context);
      //  Navigator.pushNamed(context, '/TribeHome');
    } else {
      snackBarCalled(context, "Error while liking the post!", Colors.red);
    }
  }

  void downvote(context, String str, String objectId, dataObj) async {
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
      snackBarCalled(context, "You disliked this post!");

      if (postListIds.contains(objectId)) {
        setState(() {
          dataObj["upvotes"]--;
        });
        postListIds.remove(objectId);
      }
    } else {
      snackBarCalled(context, "Error while disliking the post!", Colors.red);
    }
  }
}

Widget popUpBox(id) {
  return PopupMenuButton(
    initialValue: 2,
    color: Colorcodes.appBarColor,
    child: const Center(
        child: Icon(
      Icons.more_vert_outlined,
      size: 25,
      color: Colors.black,
    )),
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

class SalesData {
  final String month;
  final double sales;

  SalesData(this.month, this.sales);
}

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/exploreCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/readmore.dart';
import 'package:flutter_application_code_stakeplot/userAvatar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class ChartData {
  ChartData(this.x, this.y, [this.color, this.name]);
  final String x;
  final double y;
  final Color? color;
  final String? name;
}

class PostCard extends StatefulWidget {
  var data;
  bool flag = false;
  PostCard({
    Key? key,
    required this.data,
    this.flag = false,
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  RxBool fill = false.obs;

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    return uploadData(data, widget.flag);
  }

  void getInfo() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('${url}/user/info'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];

      setState(() {
        var postList = obj['saved'];
        fill.value = postList.contains(widget.data['_id']);
      });
    } else {}
  }

  Widget uploadData(dataObj, bool flag) {
    bool isExploria = dataObj['postType'] == "explore";
    var extractdata = isExploria
        ? dataObj['description']['message']
        : {}; //  dataObj.containsKey('place') && dataObj.containsKey('tripHighlight')
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Card(
        elevation: Colorcodes.elevation3,
        color: AppColors.mt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: flag
                  ? null
                  : () {
                      print(
                          'uploadData: Navigating to TribeUnique for post ID: ${dataObj["_id"]}');
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  TribeUnique(
                            id: dataObj["_id"],
                            dataObj: dataObj,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 7),
                decoration: BoxDecoration(
                    color: AppColors.mt,
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
                              UserAvatar(
                                url:avaterUrlPath( dataObj["author"]['name']),
                                width: 10,
                                height: 15,
                              ),
                              // UserAvatar(
                              //   url: dataObj["author"]['avatar'],
                              //   width: 10,
                              //   height: 15,
                              // ),
                              const SizedBox(width: 2),
                              Text(
                                (dataObj["author"]['name']),
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.bg1),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            flag ? saved() : SizedBox.shrink(),
                            popUpBox(dataObj['_id'], context,
                                dataObj["author"]['name']),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ],
                    ),
                    // Exploria Post UI
                    isExploria
                        ? ExploreCard(
                            extractdata: extractdata,
                            dataObj: dataObj,
                          )
                        : (dataObj['isPoll'] ?? false)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  dataObj['pollData']['question'] + "?",
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: AppColors.bg1),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                child: Text(
                                  (dataObj['title']),
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.bg1),
                                ),
                              ),
                    // Image Section (Exploria or Others)
                    isExploria
                        ? SizedBox.shrink()
                        : dataObj['image'] != null &&
                                (dataObj['image'] != "none" &&
                                    dataObj['image'] != "")
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: Colorcodes.borderRadius),
                                child: Center(
                                  child: GFImageOverlay(
                                    width:MediaQuery.of(context).size.width / 1.2,
                                    height: MediaQuery.of(context).size.height /2.7,
                                    boxFit: BoxFit.fill,
                                    borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
                                    image: NetworkImage(dataObj['image']),
                                  ),
                                ),
                              )
                            : isExploria &&
                                    dataObj['backGroundPicture'] != null &&
                                    dataObj['backGroundPicture'] != ""
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: Colorcodes.borderRadius),
                                    child: Center(
                                      child: GFImageOverlay(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.2,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2.7,
                                        boxFit: BoxFit.fill,
                                        borderRadius: BorderRadius.circular(
                                            Colorcodes.borderRadius),
                                        image: NetworkImage(
                                            dataObj['backGroundPicture']),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.6),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                    // Content for Non-Exploria Posts
                    !isExploria
                        ? (dataObj['isPoll'] ?? false)
                            ? getQuestionsAndOptions(dataObj['pollData'],
                                context, true, dataObj['_id'])
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                child: !dataObj['isItenary']
                                    ? text(dataObj)
                                    : dataObj['chartType'] == "bargraph"
                                        ? barGraph(dataObj)
                                        : pieChart(dataObj),
                              )
                        : SizedBox.shrink(),
                    vote(context, dataObj, dataObj),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<ui.Image> _loadImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));

    final bytes = response.bodyBytes;
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    return frame.image;
  }

  Widget imageget(imageUrl) {
    return FutureBuilder<ui.Image>(
      future: _loadImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return RawImage(image: snapshot.data);
        }
        return CircularProgressIndicator();
      },
    );
  }

  Future<void> _redirectToURL(String url) async {
    // final Uri uri = Uri.parse(url);
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri, mode: LaunchMode.externalApplication);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  Widget saved() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
          onTap: () {
            if (!fill.value) {
              savePostData(context, widget.data);
              snackBarCalled(context, "Saved post successfully!!");
              fill.value = true;
            } else
              snackBarCalled(context, "You have already saved the post!!");
          },
          child: Obx(() => SvgPicture.asset(
                fill.value
                    ? "assets/images/Saved.svg"
                    : "assets/images/Save.svg",
                height: 25,
                width: 25,
                color: Colorcodes.white,
              ))),
    );
  }

  Widget text(item) {
    try {
      return Readmore(str: item['description']['message'].toString());
    } catch (e) {
      return Readmore(str: item['description'].toString());
    }
  }

  Widget popUpBox(id, context, userId) {
    return PopupMenuButton(
      initialValue: 2,
      color: Colorcodes.white,
      child: Center(
          child: Icon(
        Icons.more_vert_outlined,
        size: 25,
        color: AppColors.bg2,
      )),
      onSelected: (value) {
        if (value == 0 && userId == userName.value) {
           print("value $value");
          deletePost(id, context);
        }
        if (value == 1) {
          print(value);
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return showModel(context, id, widget.flag);
            },
          );
        } else {
          reportPost(context, id, "hide post","hide");
          if (widget.flag) {
            getPost();
            Navigator.pop(context);
          }
        }
      },
      itemBuilder: (context) {
        return userId == userName.value
            ? [
                PopupMenuItem(
                  value: 0,
                  child: getTextMenuItem(
                    context: context,
                    text: "Delete",
                    color: Colorcodes.red,
                  ),
                ),
              ]
            : [
                PopupMenuItem(
                  value: 0,
                  child: getTextMenuItem(context: context, text: "Hide"),
                ),
                PopupMenuItem(
                  value: 1,
                  child: getTextMenuItem(context: context, text: "Report"),
                ),
              ];
      },
    );
  }

  Widget getTextMenuItem({
    required BuildContext context,
    text,
    Color color = AppColors.bg1,
  }) {
    return textStyle(
        context: context, text: text, c: color, fontWeight: FontWeight.bold);
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
          SalesData(t1, double.parse(b), color[j]),
        );
        j++;
      },
    );

    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 30),
      // width: MediaQuery.of(context).size.width/2,
      // width: 300,
      // height:170,
      height: MediaQuery.of(context).size.height / 4.7,

      child: SfCartesianChart(
        //  primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          labelStyle: FontManager().getTextStyle(context,
              color: Colorcodes.white,
              fontSize: 13,
              // color: Colorcodes.white,
              lWeight: FontWeight.bold),
          // borderWidth: 0,
          // majorGridLines: MajorGridLines(
          //     color: Colorcodes.iconBackGround,
          //     dashArray: [3, 3, 3, 3]),
          // axisLine: AxisLine(color: Colorcodes.black),
          numberFormat: NumberFormat.compact(),
        ),
        primaryXAxis: CategoryAxis(
          labelStyle: FontManager().getTextStyle(context,
              color: Colorcodes.white, fontSize: 11, lWeight: FontWeight.bold),
          // axisLine: AxisLine(color: Colorcodes.black),
        ),
        isTransposed: true,
        series: <CartesianSeries>[
          BarSeries<SalesData, String>(
            dataSource: chartData,
            onPointTap: (pointInteractionDetails) {
              print(widget.flag);
              if (widget.flag) return;
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
            pointColorMapper: (SalesData data, _) => data.color,
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
          height: MediaQuery.of(context).size.height / 4.4,
          child: SfCircularChart(series: <CircularSeries>[
            // Render pie chart
            PieSeries<ChartData, String>(
              dataSource: chartData,

              radius: "100",
              explodeOffset: "20%",

              dataLabelMapper: (ChartData data, _) => '${data.name}',
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              onPointTap: (pointInteractionDetails) {
                if (widget.flag) return;

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
                isVisible: true,
                textStyle: FontManager().getTextStyle(context,
                    color: Colorcodes.black,
                    fontSize: 12,
                    lWeight: FontWeight.w500), // Show labels
                labelIntersectAction: LabelIntersectAction.hide,
                connectorLineSettings: ConnectorLineSettings(
                  type: ConnectorType.curve,
                ),
              ),
            )
          ])),
    );
  }
}

class SalesData {
  final String month;
  final double sales;
  final Color? color;
  SalesData(this.month, this.sales, this.color);
}

Widget poll(e, context) {
  List options = e['options'];
  int index = e['selectedOption'];
  int s = -1;

  return Padding(
    padding: const EdgeInsets.only(right: 0.0, top: 5),
    // child: Container(
    //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    //   width: MediaQuery.of(context).size.width / 1.4,
    //   decoration: BoxDecoration(
    //     //  color: Colorcodes.appBarColor,
    //     border: Border.all(width: .5, color: Colorcodes.poll1),
    //     borderRadius: BorderRadius.circular(9),
    //   ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(e['question'] + "?",
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.bg1)),
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options.map((op) {
              // List ll=op['votes'];
              // String cal=((ll.length/len)* 100).toStringAsFixed(2);
              // len += ll.length ;
              s++;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                    width: MediaQuery.of(context).size.width / 1.5,
                    decoration: BoxDecoration(
                      color: index == s ? null : Colorcodes.white,
                      borderRadius:
                          BorderRadius.circular(Colorcodes.borderRadius),
                      gradient: index == s
                          ? LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.pollSelected,
                                AppColors.pollSelected,
                              ],
                            )
                          : null,
                      border: index == s
                          ? Border.all(color: AppColors.button)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(op,
                            overflow: TextOverflow.visible,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: 14,
                                color: index == s
                                    ? AppColors.bg1
                                    : AppColors.bg1)),
                      ],
                    )),
              );
            }).toList()),
      ],
    ),
    //),
  );
}

Widget demiData(context) {
  var options = [1, 2, 3, 4];
  return Padding(
    padding: const EdgeInsets.only(right: 0.0, top: 5),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: MediaQuery.of(context).size.width / 1.4,
      decoration: BoxDecoration(
        //  color: Colorcodes.appBarColor,
        border: Border.all(width: .5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("",
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Colors.black)),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: options.map((op) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                      width: MediaQuery.of(context).size.width / 1.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        // border: Border.all()
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("",
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.black)),
                        ],
                      )),
                );
              }).toList()),
        ],
      ),
    ),
  );
}

Widget getQuestionsAndOptions(e, context, flag, PostId) {
  String id = currentId.value;
  List options = e['options'];

  int index = -1;
  String s = "";
  for (int i = 0; i < options.length; i++) {
    List votesArray = options[i]['votes'];
    bool vote = votesArray.contains(id);
    if (vote) {
      index = i;
      s = options[i]['option'];
      break;
    }
  }
  RxBool myvote = (index != -1).obs;

  int len = 0;

  options.forEach((element) {
    List ll = element['votes'];
    len = len + ll.length;
  });

  RxList optionsList = [].obs;

  optionsList.addAll(options);
  int indexVal = -1;
  double width = MediaQuery.of(context).size.width;
  
  return Obx(() => Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              width: width <= 500 ? width / 1.3 : width / 1.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: optionsList.map((op) {
                        List ll = op['votes'];
                        indexVal++;

                        String cal = len != 0
                            ? ((ll.length / len) * 100).toStringAsFixed(0)
                            : '0';

                        // if(!flag){
                        //       cal =  s == op['option'] ? "100" :"0";
                        // }
                        bool isSe = op['option'] == s;
String formattedText = op['option'].replaceAllMapped(RegExp(r'.{6}'), (match) => '${match.group(0)}\u200B');

                        return Obx(() => Padding(
                          
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: InkWell(
                                onTap: myvote.value
                                    ? null
                                    : () {
                                        s = op['option'];
                                        //  if(!flag)cal =  s == op['option'] ? "100" :"0";

                                        int place = options.indexOf(op);
                                        optionsList[options.indexOf(op)]
                                                ['votes']
                                            .add(id);
                                        votePollInPost(context, PostId,
                                            options.indexOf(op));
                                        len++;

                                        myvote.value = true;
                                        e['options'][options.indexOf(op)]
                                                ['votes']
                                            .add(id);

                                        //  if(flag){
                                        //     questionRoom.removeAt(place);
                                        //     questionRoom.insert(place,e);
                                        //  }
                                      },
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 13, horizontal: 10),
                                    //width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: op['option'] == s
                                            ? null
                                            : AppColors.backgroundColor,
                                        borderRadius: BorderRadius.circular(
                                            Colorcodes.borderRadius),
                                        gradient: op['option'] == s
                                            ? LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  AppColors.pollSelected,
                                                  AppColors.pollSelected,
                                                ],
                                              )
                                            : null,
                                        border: !isSe
                                            ? Border.all(
                                                color: AppColors.button)
                                            : null),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          // width: MediaQuery.of(context).size.width/2,
                                           child: Text(op['option'],
                                           //child: Text(formattedText,
                                          maxLines: null,
                                          softWrap: true,
                                           textWidthBasis: TextWidthBasis.longestLine,
                                          overflow: TextOverflow.visible,
                                              style: FontManager().getTextStyle(
                                                  context,
                                                  lWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: isSe
                                                      ? AppColors.bg1
                                                      : AppColors.bg1)),
                                        ),
                                        myvote.value
                                            ? Text(
                                                cal == "0.00"
                                                    ? '0%'
                                                    : cal == "100.00"
                                                        ? "100%"
                                                        : cal + "%",
                                                style: FontManager()
                                                    .getTextStyle(context,
                                                        lWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: isSe
                                                            ? AppColors.bg1
                                                            : AppColors.bg1))
                                            : SizedBox.shrink(),
                                      ],
                                    )),
                              ),
                            ));
                      }).toList()),
                ],
              ),
            ),
          ],
        ),
      ));
}

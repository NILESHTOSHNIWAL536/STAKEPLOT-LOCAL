import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/exploreCard.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/pop-up-menu.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/readmore.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
class ChartData {
  ChartData(this.x, this.y, [this.color, this.name]);
  final String x;
  final double y;
  final Color? color;
  final String? name;
}

class PostCard extends StatelessWidget {
  var data;
  bool flag = false;
  int index;
  PostCard({
    Key? key,
    required this.data,
    this.flag = false,
    required this.index
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  uploadData(data, flag,context) ;
  }

  Widget uploadData(dataObj, bool flag,BuildContext context) {  
    bool isExploria = dataObj['postType'] == "explore";
    var extractdata = isExploria
        ? dataObj['description']['message']
        : {}; //  dataObj.containsKey('place') && dataObj.containsKey('tripHighlight')
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Card(
       // elevation: Colorcodes.elevation3,
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
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 4),
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
                              
                              AvatarProfile(name: dataObj["author"]['name'], width: 4, height: 10,background:dataObj["author"]['avatarBackGround'] ?? defaultBackGround.value,flag: false,),
                            
                              const SizedBox(width: 2),
                              Text(
                                (dataObj["author"]['name']),
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: AppColors.bg1),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            // Save user posts 
                           // flag ? saved() : SizedBox.shrink(),
                            popUpBoxHideDelete(dataObj['_id'], context,
                                dataObj["author"]['name'],index,flag),
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
                                    vertical: 4, horizontal: 10),
                                child: Text(
                                  (dataObj['title']),
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w500,
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
                                    vertical: Colorcodes.borderRadius/3),
                                child: Center(
                                  child: GFImageOverlay(
                                    width:MediaQuery.of(context).size.width / 1.2,
                                    height: MediaQuery.of(context).size.height /3,
                                    boxFit: BoxFit.fill,
                                    borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
                                    image: NetworkImage(dataObj['image']),
                                    colorFilter: null, // Disable any color tint
                                    color: Colors.transparent,
                                    border: Border.all(color: AppColors.bg5),
                                    
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
                                                3,
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
                                    ? text(dataObj):SizedBox.shrink()
      
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

  Widget text(item) {
    try {
      return Readmore(str: item['description']['message'].toString());
    } catch (e) {
      return Readmore(str: item['description'].toString());
    }
  }
}

Widget poll(e, context) {
  List options = e['options'];
  int index = e['selectedOption'];
  int s = -1;

  return Padding(
    padding: const EdgeInsets.only(right: 0.0, top: 5),
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

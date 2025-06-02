import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/exploreCard.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/pollDisplay.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/pop-up-menu.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/readmore.dart';
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

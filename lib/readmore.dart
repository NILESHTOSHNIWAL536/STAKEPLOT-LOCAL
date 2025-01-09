import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:readmore/readmore.dart";



class Readmore extends StatelessWidget {
String str;
 Readmore({ Key? key,required this.str }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return ReadMoreText(
                                                    str.toString(),
                                                    style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colorcodes.white),
                                                    trimMode: TrimMode.Line,
                                                    trimLines: 4,
                                                    
                                                    colorClickableText:  Colorcodes.black,
                                                    trimCollapsedText: 'Show more',
                                                    trimExpandedText: 'Show less',
                                                    moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                    lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';



class GoogleSignIn extends StatelessWidget {
const GoogleSignIn({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    double width=MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Card(
                  
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
                ),
                elevation: 5,
                    
          child: Container(
            width: MediaQuery.of(context).size.width/1.6,
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                    Image.network(svgIconPath.google,height: 30,width: 30,),
                    const SizedBox(width: 10,),
                    Container(
                      // width: MediaQuery.of(context).size.width/1.8,
                      child: Text(("Continue with Google"),
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: width<=300? 9: width<=320? 11:width<=400? 13: width<=500?15:16,
                                color: Colorcodes.barGraphOrange2),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                ),
                    ),
                 ],
              ),
          ),
        ),
      ),
    );
  }
}
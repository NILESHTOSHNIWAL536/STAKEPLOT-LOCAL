

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';

class UserLoginedAlready extends StatelessWidget {
  var data;
 UserLoginedAlready({ Key? key,required this.data }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
       padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height/1.5,
      decoration: BoxDecoration(
        color: Colorcodes.white,
        borderRadius:const BorderRadius.only(
          topLeft:Radius.circular(20), 
          topRight:Radius.circular(20), 
        )
      ),

    );
  }
}
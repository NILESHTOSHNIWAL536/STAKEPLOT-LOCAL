import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class Loader extends StatelessWidget {
const Loader({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:  [
          SizedBox(width: 20,),
         Text("Loading.....   ",style: FontManager().getTextStyle(context)),
        const  CircularProgressIndicator(
           strokeWidth: 1.3,
           color: Colors.black,
        )
      ],
    );
  }
}

class Verify extends StatelessWidget {
  String str;
  Color color;
 Verify({ Key? key ,this.str="Verifying.....",this.color=Colors.black }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:  [

         Text(str,style: FontManager().getTextStyle(context,lWeight: FontWeight.bold,fontSize: 13,color: color),),
        Container(
          height: 20,
          width: 20,
          child:  CircularProgressIndicator(
             strokeWidth: 2,
             color: color
          ),
        )
      ],
    );
  }
}
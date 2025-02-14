import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
class Spinner extends StatelessWidget {
double size;
Color color;
 Spinner({ Key? key ,this.size=50.0,this.color=AppColors.primaryColor}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return 
           SpinKitCircle(
              color: color, // Use a single color
                size: size,
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
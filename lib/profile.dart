
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_svg/flutter_svg.dart';



class ProfileImage extends StatelessWidget {
String url;
bool flag;
 ProfileImage({ Key? key, this.url="assets/images2/user.svg",this.flag=false }) : super(key: key);
//  ProfileImage({ Key? key, this.url="assets/images/profile2.svg" }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  flag? SvgPicture.asset(url,color: Colorcodes.textColor,) :SvgPicture.asset(url);
  }
}

int val=19;
int val2=15;

Color flagdata(bool flag){
    Color color= flag? Colorcodes.white:Colorcodes.dropdown;
    return color;
}

Widget upvoteLiked(context,[bool flag=true])
{
   double height=MediaQuery.of(context).size.height;
   double width=MediaQuery.of(context).size.width;

   return Container(
          width: width/val,
          height: height/val,
        child: SvgPicture.asset("assets/svgs/up-voted.svg",color:  flagdata(flag))
    );
}



Widget upvoteLike(context,[bool flag=true]){
    double height=MediaQuery.of(context).size.height;
   double width=MediaQuery.of(context).size.width;
   return Container(
    width: width/val,
          height: height/val,
    child: SvgPicture.asset("assets/svgs/up-vote.svg",color:  flagdata(flag)));
}

Widget downvoteLiked(context,[bool flag=true]){
    double height=MediaQuery.of(context).size.height;
   double width=MediaQuery.of(context).size.width;

   return Container(
      width: width/val,
      height: height/val,
    child: SvgPicture.asset("assets/svgs/down-voted.svg",color:  flagdata(flag)));
}

Widget downvoteLike(context,[bool flag=true]){
    double height=MediaQuery.of(context).size.height;
   double width=MediaQuery.of(context).size.width;
   return Container(
    width: width/val,
          height: height/val,
    
    child: SvgPicture.asset("assets/svgs/down-vote.svg",color:  flagdata(flag)));
}
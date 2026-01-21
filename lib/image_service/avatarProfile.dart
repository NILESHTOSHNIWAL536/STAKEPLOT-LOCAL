
// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';

import '../Constants/core/app_padding_sizes.dart';



class AvatarProfileImagePng extends StatelessWidget {
String url;
double width;
double height;
AvatarProfileImagePng({ Key? key,required this.url,required this.width,required this.height }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsetsDirectional.all(AppSizes.p4),
        alignment: Alignment.center,
        child:Image.asset(
            url.toString().trim(),
              width: MediaQuery.of(context).size.width/ width,
              height: MediaQuery.of(context).size.height/ height,
        )
    );
  }
}

class AvatarProfileImage extends StatelessWidget {
String url;
double width;
double height;
AvatarProfileImage({ Key? key,required this.url,required this.width,required this.height }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsetsDirectional.all(AppSizes.p4),
        alignment: Alignment.center,
        child: isSvgUrl(url)? SvgPicture.asset(url.toString().trim(),
              width: MediaQuery.of(context).size.width/ width,
              height: MediaQuery.of(context).size.height/ height,
        ):Container(
           width: MediaQuery.of(context).size.width /width,
           height: MediaQuery.of(context).size.height/height,
          child: GFImageOverlay(     
                                shape: BoxShape.circle,
                                boxFit: BoxFit.contain,
                                image: NetworkImage(url),
                                colorFilter:ColorFilter.mode(AppColors.accentColor.withOpacity(0.0),
                                BlendMode.exclusion
                        ),
                 ),
        )
        
    );
  }
}
class AvatarProfileImageZero extends StatelessWidget {
String url;
double width;
double height;
AvatarProfileImageZero({ Key? key,required this.url,required this.width,required this.height }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  SvgPicture.asset(url.toString().trim(),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height/ height,
    );
  }
}

class AvatarProfileImageNextFetch extends StatelessWidget {
String url;
double width;
double height;
AvatarProfileImageNextFetch({ Key? key,required this.url,required this.width,required this.height }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Container(
        margin: EdgeInsets.symmetric(horizontal: 0),
        padding: EdgeInsetsDirectional.all(AppSizes.p4),
        alignment: Alignment.center,
        // color: AppColors.primaryColor,
        child: isSvgUrl(url)? SvgPicture.asset(url.toString().trim(),
              width: MediaQuery.of(context).size.width/ width,
              height: MediaQuery.of(context).size.height/ height,
        ):Container(
           width: MediaQuery.of(context).size.width /width,
           height: MediaQuery.of(context).size.height/height,
          child: GFImageOverlay(     
                                shape: BoxShape.circle,
                                boxFit: BoxFit.contain,
                                image: NetworkImage(url),
                                colorFilter:ColorFilter.mode(AppColors.accentColor.withOpacity(0.0),
                                BlendMode.exclusion
                        ),
                 ),
        )
        
    );
  }
}
class chatAvatartImage extends StatelessWidget {
String url;
double width;
double height;
chatAvatartImage({ Key? key,required this.url,required this.width,required this.height }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Container(
        padding: EdgeInsetsDirectional.all(0),
        alignment: Alignment.center,
        child: SvgPicture.asset(url.toString().trim(),
              width: MediaQuery.of(context).size.width/ width,
              height: MediaQuery.of(context).size.height/ height,
        )
        
    );
  }
}





class PrefixIcon extends StatelessWidget {
String url;
double width;
double height;
PrefixIcon({ Key? key,required this.url,required this.width,required this.height }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Padding(
      padding: const EdgeInsets.all(3.0),
      child: SvgPicture.asset(url.toString().trim(),
            width: MediaQuery.of(context).size.width/ width,
            height: MediaQuery.of(context).size.height/ height,
      ),
    );
  }
}


class AvatarProfile extends StatelessWidget {
  final String name;
  final String background;
  final double width;
  final double height;
   double fontsize=25;
   bool flag=false;


   AvatarProfile({
    Key? key,
    required this.name,
    required this.width,
    required this.height,
    required this.background,
     this.flag=false,
     this.fontsize=20,
  }) : super(key: key);

  Color getBackgroundColor(String hexw) {
   String  hex="#48484A";
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.greyColor; // Fallback color
    }
  }

  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return flag?Container(
      padding: EdgeInsets.all(AppSizes.p2),
      width: MediaQuery.of(context).size.width/ width,
      height: MediaQuery.of(context).size.height/ height,
      alignment: Alignment.center,
      child: img2(context,width,size)
      ):Container(
      margin: EdgeInsets.all(AppSizes.p4),
      padding: EdgeInsets.all(AppSizes.p2),
      alignment: Alignment.center,
      child: img(context,size)
    );
  }

  Widget img(BuildContext context, double size) {
  return Container(
    width: size / 10,  // Diameter
    height: size / 10, // Diameter
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          getBackgroundColor(background).withOpacity(0.7),
          getBackgroundColor(background),
        ],
      ),
    ),
    child: Center(
      child: textStyleImage(
        context: context,
        text: name.isEmpty ? "L" : name[0].toUpperCase(),
        fontsize: 20,
        c: Colorcodes.appBarColor,
      ),
    ),
  );
}

  Widget img2(context,width,size){
    return Container(
      width: size / width, // diameter
      height: size / width,
      decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          getBackgroundColor(background).withOpacity(0.7),
          getBackgroundColor(background),
        ],
      ),
    ),
      child: Center(
        child: textStyleImage(
          context: context,
          text: name[0].toUpperCase(),
          fontsize: 20,
          c: Colorcodes.appBarColor,
        ),
      ),
    );

  }

}





bool isSvgUrl(String url) {
  return url.toLowerCase().endsWith('.svg');
}





class AvatarProfile2 extends StatelessWidget {
  final String url;
  final double width;
  final double height;
   double fontsize=25;
   bool flag=false;

   AvatarProfile2({
    Key? key,
    required this.url,
    required this.width,
    required this.height,
     this.flag=false,
     this.fontsize=20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return flag? Container(
          padding: EdgeInsets.all(AppSizes.p2),
          alignment: Alignment.center,
          // color: AppColors.appIcon,
          child: CircleAvatar(
              radius:35,
             backgroundImage: AssetImage(url.toString().trim()),
             backgroundColor: AppColors.transparentColor, // optional: removes default grey bg
          ),
      ):Container(
          padding: EdgeInsets.all(AppSizes.p2),
          alignment: Alignment.center,
          child: CircleAvatar(
             backgroundImage: AssetImage(url.toString().trim()),
             backgroundColor: AppColors.transparentColor, // optional: removes default grey bg
          ),
      );
  }
}
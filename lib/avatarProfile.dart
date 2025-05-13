
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';



class AvatarProfileImage extends StatelessWidget {
String url;
double width;
double height;
AvatarProfileImage({ Key? key,required this.url,required this.width,required this.height }) : super(key: key);
//  ProfileImage({ Key? key, this.url="assets/images/profile2.svg" }) : super(key: key);

  @override
  Widget build(BuildContext context){
    // url="https://lh3.googleusercontent.com/a/ACg8ocKYmUXUyRRJMokLs9MV_LdZsO3-x8WJJGTOtPw41A72KO-4QMaF=s96-c";
    return  Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsetsDirectional.all(4),
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
                                colorFilter:ColorFilter.mode(Colors.black.withOpacity(0.0),
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
//  ProfileImage({ Key? key, this.url="assets/images/profile2.svg" }) : super(key: key);

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


class IconImage extends StatelessWidget {
String url;
double width;
double height;
IconImage({ Key? key,required this.url,required this.width,required this.height }) : super(key: key);
//  ProfileImage({ Key? key, this.url="assets/images/profile2.svg" }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Container(
        alignment: Alignment.topLeft,
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
   bool flag=false;

   AvatarProfile({
    Key? key,
    required this.name,
    required this.width,
    required this.height,
    required this.background,
     this.flag=false,
  }) : super(key: key);

  Color getBackgroundColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey; // Fallback color
    }
  }

  @override
  Widget build(BuildContext context) {
    return flag?Container(
      // color: AppColors.bg1,
      width: MediaQuery.of(context).size.width/ width,
      height: MediaQuery.of(context).size.height/ height,
      alignment: Alignment.center,
      child: img2(context,MediaQuery.of(context).size.width/ width)
      ):Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(2),
      alignment: Alignment.center,
      child: img(context)
    );
  }


  Widget img(context){
    return CircleAvatar(
        backgroundColor: getBackgroundColor(background),
        child: Center(
          child: textStyleImage(
            context: context,
            text: name[0].toUpperCase(),
            fontWeight: FontWeight.bold,
            fontsize: 25,
            c: Colorcodes.appBarColor,
          ),
        ),
      );
  }

  Widget img2(context,width){
    return CircleAvatar(
        backgroundColor: getBackgroundColor(background),
        radius: width,
        child: Center(
          child: textStyleImage(
            context: context,
            text: name[0].toUpperCase(),
            fontWeight: FontWeight.bold,
            fontsize: 30,
            c: Colorcodes.appBarColor,
          ),
        ),
      );
  }
}



bool isSvgUrl(String url) {
  return url.toLowerCase().endsWith('.svg');
}
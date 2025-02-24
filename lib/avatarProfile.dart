
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
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


bool isSvgUrl(String url) {
  return url.toLowerCase().endsWith('.svg');
}
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';

class UserAvatar extends StatelessWidget {
String url;
double width;
double height;
UserAvatar({ Key? key,required this.url,required this.width,required this.height }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Container(
        margin: EdgeInsets.only(top: 4),
        alignment: Alignment.center,
        child: isSvgUrl(url)? Center(
          child: SvgPicture.asset(url.toString().trim(),
                width: MediaQuery.of(context).size.width/ width,
                height: MediaQuery.of(context).size.height/ height,
          ),
        ):Center(
          child: Container(
             width: MediaQuery.of(context).size.width /width,
             height: MediaQuery.of(context).size.height/height,
             padding: EdgeInsets.all(0),
            child: GFImageOverlay(     
                                  shape: BoxShape.circle,
                                  boxFit: BoxFit.contain,
                                  image: NetworkImage(url),
                                  colorFilter:ColorFilter.mode(Colors.black.withOpacity(0.0),
                                  BlendMode.exclusion
                          ),
                   ),
          ),
        )
        
    );
  }
}
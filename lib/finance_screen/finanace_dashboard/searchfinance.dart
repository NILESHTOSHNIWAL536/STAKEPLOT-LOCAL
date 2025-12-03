  import 'package:flutter/material.dart';

import '../../image_service/avatarProfile.dart';
import '../../Constants/colorcodes.dart';
import '../../user_chat/tribe_chart.dart';

Widget buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colorcodes.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 8.0,
      ),
      child:InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/TribeSearch');
        },
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:  [
          AvatarProfileImage(url: svgIconPath.financeSeach, width: 20, height: 40),
          Row(
            children: [
              AvatarProfileImage(url: svgIconPath.financeLine, width: 20, height: 40),
              InkWell(
                  onTap: (){
                      ismaskedUsers.value=false;
                    Navigator.pushNamed(context, '/TribeChats');
                  },
                child: AvatarProfileImage(url: svgIconPath.financeChat, width: 20, height: 40),
              ),
            ],
          ),
        ],
      )),
    );
  }

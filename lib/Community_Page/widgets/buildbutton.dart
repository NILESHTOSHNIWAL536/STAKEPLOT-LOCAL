

 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/NavigatorScreens/userNavigator.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';

Widget buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final double iconSize =
        MediaQuery.of(context).size.width * 0.07; // Responsive icon size
    final double fontSize =
        MediaQuery.of(context).size.width * 0.04; // Responsive font size

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                EdgeInsets.all(iconSize * 0.3), // Padding scales with icon size
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.25),
            child: Text(
              label,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: fontSize,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }


Widget buildWelcomeRow(context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
      final CommunityScreenStrings strings = CommunityScreenStrings();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
         padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    strings.welcomeBack,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppColors.welcomeBack),
                  ),
                  Text(
                    strings.finspace,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.finSpaceColor),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                         ismaskedUsers.value=true;
                         Navigator.pushNamed(context, '/TribeChats');
                      },
                      child: AvatarProfileImage(
                        url: LikeComment.chatMessage,
                        height: 26,
                        width: 26,
                      ),
                    ),
                    Container(
                     
                      child: GestureDetector(
                        onTap: () async {
                          navigatorToMyOwnPage(context);
                        },
                        child: AvatarProfile2 (
                          url: avatar.value,
                          width: 9,
                          height: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: GestureDetector(
            onTap: () {
              // Navigator.pushNamed(context, '/TribeSearch');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TribeSearch(isMasked: true),
                ),
              );
            },
            child: Material(
              child: Container(
                width: MediaQuery.sizeOf(context).width/1.07,
                height: MediaQuery.sizeOf(context).width *(32/348),
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    filled: true,
                    enabled: false,
                    hintText: strings.searchHint,
                    fillColor: AppColors.backgroundColor,
                    hintStyle: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: Colors.black),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
       
       
      ],
    );
  }
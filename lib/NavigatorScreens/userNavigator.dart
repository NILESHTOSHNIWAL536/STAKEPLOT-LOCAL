import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/communityUserProfile.dart';

void navigatorToMyOwnPage(context)
{
        Navigator.push(
         context,
         MaterialPageRoute(
             builder: (context) =>CommunityUserProfileScreen( )),
       );
      
}
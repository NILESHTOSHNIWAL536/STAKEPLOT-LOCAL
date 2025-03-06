

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/communityProfileScreen.dart';

void navigatorToMyOwnPage(context)
{
       Navigator.push(
         context,
         MaterialPageRoute(
             builder: (context) =>CommunityProfileScreen( id: currentId.value,)),
       );
}
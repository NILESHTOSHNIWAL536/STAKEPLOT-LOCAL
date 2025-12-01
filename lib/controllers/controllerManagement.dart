import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/community_screen.dart';
import 'package:flutter_application_code_stakeplot/controllers/post-controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/theme_controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:get/get.dart';

class ControllerManagement {
  static UserController get userController => Get.find<UserController>();
  static PostController get postController => Get.find<PostController>();
  static ThemeController get themeController => Get.find<ThemeController>();
  // final GlobalKey<CommunityState> communityKey = GlobalKey<CommunityState>();
  
}

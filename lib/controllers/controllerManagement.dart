
import 'package:flutter_application_code_stakeplot/controllers/finora_controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/post-controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/theme_controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:get/get.dart';

import '../repository/budget_apis.dart';

class ControllerManagement {
  static UserController get userController => Get.find<UserController>();
  static PostController get postController => Get.find<PostController>();
  static ThemeController get themeController => Get.find<ThemeController>();
  static BudgetControllerScreenModel get budgetController => Get.find<BudgetControllerScreenModel>();
  static FinoraController get finoraController => Get.find<FinoraController>();
  
  // static FinoraController get finoraController => Get.find<FinoraController>();
  // final GlobalKey<CommunityState> communityKey = GlobalKey<CommunityState>();
  
  
}

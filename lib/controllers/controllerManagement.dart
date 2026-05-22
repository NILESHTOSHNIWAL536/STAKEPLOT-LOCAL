import 'package:flutter_application_code_stakeplot/controllers/finora_controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/post-controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/theme_controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:get/get.dart';

import '../repository/budget_apis.dart';

class ControllerManagement {
  static UserController get userController {
    if (Get.isRegistered<UserController>()) {
      return Get.find<UserController>();
    }
    return Get.put(UserController());
  }

  static PostController get postController {
    if (Get.isRegistered<PostController>()) {
      return Get.find<PostController>();
    }
    return Get.put(PostController());
  }

  static ThemeController get themeController {
    if (Get.isRegistered<ThemeController>()) {
      return Get.find<ThemeController>();
    }
    return Get.put(ThemeController());
  }

  static BudgetControllerScreenModel get budgetController =>
      Get.isRegistered<BudgetControllerScreenModel>()
          ? Get.find<BudgetControllerScreenModel>()
          : Get.put(BudgetControllerScreenModel());

  static FinoraController get finoraController {
    if (Get.isRegistered<FinoraController>()) {
      return Get.find<FinoraController>();
    }
    return Get.put(FinoraController());
  }

  // static FinoraController get finoraController => Get.find<FinoraController>();
  // final GlobalKey<CommunityState> communityKey = GlobalKey<CommunityState>();
}

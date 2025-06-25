import 'package:flutter_application_code_stakeplot/controllers/post-controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:get/get.dart';

class ControllerManagement {
  static UserController get userController => Get.find<UserController>();
  static PostController get postController => Get.find<PostController>();
}

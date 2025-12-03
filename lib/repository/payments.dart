import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/routes/route_post.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backed_connections/apiAutomations/secure_storage.dart';



 Future<PostModel?> fetchPostById(String postId, BuildContext context) async {
    try {
      final response = await getDataApiCall(
          '${PostRoutes.post}$postId'); // Adjust the endpoint based on your API);
      if (getFlagOfResponse(response)) {
        var jsonData = jsonDecode(response.body);
        // Adjust based on your API response structure, e.g., jsonData['data']
        return PostModel.fromJson(jsonData['data'][0] ?? jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
Future<String?> getToken() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken =await SecureStorageService().read("accessToken");
  if (accessToken == null) {
    return null;
  } else {
    return accessToken;
  }
}

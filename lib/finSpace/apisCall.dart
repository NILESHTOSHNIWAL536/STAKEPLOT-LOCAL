import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finSpace/marks.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:get/get.dart';

RxSet<String> selectedCategories = <String>{}.obs;
RxSet<String> selectedSubCategories = <String>{}.obs;
RxBool isListEnabled = false.obs;
Future<void> getMaskedNumber(BuildContext context) async {
  maskNameController.clear();
  var response = await getDataApiCall(UserRoutes.maskedName);
  
  if (getFlagOfResponse(response)) {
    var body = jsonDecode(response.body);
    if (body['data'] != null) {
      maskNameController.text = body['data'];
      maskedNameLocal.value = body['data'];
    } else {
      maskNameController.text = "";
    }
  }
}

Future<void> addMyIntreastAndName(BuildContext context, var body,
    [bool falg = false, bool ifFromUpdate = false]) async {
  try {
    var response = await updateDataApiCall2(UserRoutes.update, body);
    if (getFlagOfResponse(response)) {
      if (falg) {
        userController.maskedName.value = maskedNameLocal.value;
        if (ifFromUpdate) {
          Navigator.pop(context);
          Navigator.pop(context);
        } else
          Navigator.pushNamed(context, '/interestScreen');
        return;
      } else {
        userController.interestedTags.clear();
        userController.interestedTags
            .addAll([...selectedSubCategories, ...selectedCategories]);
        selectedSubCategories.clear();
        selectedCategories.clear();
      }
      if (ifFromUpdate) {
        Navigator.pop(context);
        return;
      }
    }
  } catch (e) {}

  Navigator.of(context).pushNamedAndRemoveUntil(
      '/interestScreen', (Route<dynamic> route) => false);
  Navigator.pushNamed(context, '/post');
}

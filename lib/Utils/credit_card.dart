import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

import '../routes/route_constant.dart'; // For url

class CreditCardScreenStrings {
  static final CreditCardScreenStrings _instance =
      CreditCardScreenStrings._internal();

  factory CreditCardScreenStrings() => _instance;

  CreditCardScreenStrings._internal();

   RxBool showCreditCard=false.obs;
   RxBool showRevokeScreen=false.obs;

   Future<void> fetchConstants() async {
    try {
      final response = await getDataApiCall(ConstantRoutes.creditCard);
     
      if (getFlagOfResponse(response)) 
      {
            var data = jsonDecode(response.body)['data'] ?? {};
            showCreditCard.value= data['showCreditCard'] ??  showCreditCard.value;
            showRevokeScreen.value= data['showRevokeScreen'] ??  showRevokeScreen.value;
      } 
    } catch (e) {
    } 
  }

}
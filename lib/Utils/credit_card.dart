import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart'; // For url

class CreditCardScreenStrings {
  static final CreditCardScreenStrings _instance =
      CreditCardScreenStrings._internal();

  factory CreditCardScreenStrings() => _instance;

  CreditCardScreenStrings._internal();

   RxBool showCreditCard=false.obs;

   void fetchConstants() async {
    try {
      final response = await http.get(Uri.parse("$url/constant/creditCard"));
      if (response.statusCode == 200) {
            var data = jsonDecode(response.body)['data'] ?? {};
            showCreditCard.value=data['showCreditCard'] ??  showCreditCard.value;
      } 
    } catch (e) {
    }
  }

}
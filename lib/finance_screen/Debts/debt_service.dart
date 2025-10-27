import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/routers_api.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DebtService {
  static String baseUrl = '${url}/debt';

  static Future<Map<String, dynamic>?> createDebt(
      Map<dynamic, dynamic> debtData) async {
    try {
      final response = await postDataApiCall(baseUrl, debtData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // Return the JSON response
      }
    } catch (e) {}

    return null;
  }

  static Future<bool> deleteDebt(String debtId) async {
    try {
      final String apiUrl = '$baseUrl/$debtId';
      var response = await deleteDataApiCall(apiUrl);

      if (getFlagOfResponse(response)) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Debt>> fetchDebts() async {
    try {
      final response = await getDataApiCall(baseUrl);

      if (getFlagOfResponse(response)) {
        List<dynamic> body =
            jsonDecode(response.body)['data']; // Decode as a list
        List<Debt> debts = body
            .map((item) => Debt.fromJson(item))
            .toList(); // Convert each item to a Debt object
        return debts;
      } else {
        throw Exception(
            'Failed to load debts: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      return [];
    }
  }
}

Future<void> calculateInflation() async {
  try {
    isLoadingInflation.value = true;
    var body = {
      'amount': originalAmount.value,
      'years_ahead': inflatedYears.value,
    };
   
    var response=await postDataApiCall(UserRoutes.inflation,body);
   
    if (getFlagOfResponse(response))
    {
      final data = jsonDecode(response.body);
      if (data.containsKey('final_future_value') &&
          data.containsKey('predictions')) {
        inflatedFutureValue.value =
            data['final_future_value']?.toDouble() ?? 0.0;
        inflationPredictions.value =
            List<Map<String, dynamic>>.from(data['predictions'] ?? []);
        showResults.value = true;
      } else {}
    } else {}
  } catch (e) {
  } finally {
    isLoadingInflation.value = false;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
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
   
    var uri = Uri.parse(
        "https://predict.stakeplot.com/predict_inflation/"); // Ensure trailing slash
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var requestBody = jsonEncode(body);
    const maxRedirects = 5;
    var redirectCount = 0;

    http.Response? response;

    // Follow redirects
    while (redirectCount < maxRedirects) {
      response = await http.post(
        uri,
        headers: headers,
        body: requestBody,
      );

      // Check for redirect status codes (301, 302, 307, 308)
      if ([301, 302, 307, 308].contains(response.statusCode)) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          uri = Uri.parse(redirectUrl);
          redirectCount++;
          continue; // Follow the redirect
        } else {
          
          return;
        }
      } else {
        break; // Not a redirect, exit loop
      }
    }

    // Ensure we have a response before proceeding
    if (response == null) {
      return;
    }

    // Check for too many redirects
    if (redirectCount >= maxRedirects) {
      return;
    }

    // Process the final response
    if (response!.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Verify expected keys exist
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

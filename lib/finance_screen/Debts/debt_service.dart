import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
class DebtService {
  static String baseUrl = '${url}/debt';

  static Future<Map<String, dynamic>?> createDebt(
      Map<dynamic, dynamic> debtData) async {
    try {
      // print(
      //     "Attempting to create debt with data: $debtData"); // Debug statement
      var accessToken = await getToken();
      if (accessToken == null) {
      //  print("Error: No access token available");
        return null;
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "$accessToken",
        },
        body: jsonEncode(debtData),
      );

      // print('Response status code: ${response.statusCode}'); // Debug statement
      // print('Response body: ${response.body}'); // Debug statement
      if (response.statusCode == 200 || response.statusCode == 201) {
      //  print("Debt created successfully."); // Debug statement
        return jsonDecode(response.body); // Return the JSON response
      } else {
        // print(
        //     "Failed to create debt: ${response.statusCode} - ${response.body}"); // Debug statement
      }
    } catch (e) {
    //  print("Error occurred while creating debt: $e"); // Debug statement
    }
    return null;
  }
static Future<bool> deleteDebt(String debtId) async {
    try {
      var accessToken = await getToken();
      if (accessToken == null) {
        return false;
      }
      final String apiUrl = '$baseUrl/$debtId';   
      var response = await deleteDataApiCall(apiUrl);
      if (response.statusCode == 200 || response.statusCode == 204) {
        
        return true;

      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<List<Debt>> fetchDebts() async {
    try {
    // Debug statement
      var accessToken = await getToken();
      if (accessToken == null) {
      
        return [];
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "$accessToken"
        },
      );

    //  print('Response status code: ${response.statusCode}'); // Debug statement
      if (response.statusCode == 200) {
        List<dynamic> body =
            jsonDecode(response.body)['data']; // Decode as a list
    //    print("Debts fetched successfully."); // Debug statement
        List<Debt> debts = body
            .map((item) => Debt.fromJson(item))
            .toList(); // Convert each item to a Debt object
        return debts;
      } else {
        // print(
        //     "Failed to load debts: ${response.statusCode} - ${response.body}"); // Debug statement
        throw Exception(
            'Failed to load debts: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
     // print("Error occurred while fetching debts: $error"); // Debug statement
      return [];
    }
  }
}

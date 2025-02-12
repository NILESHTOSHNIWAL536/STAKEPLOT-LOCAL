import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/CreateDebtScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DebtService {
  static String _baseUrl = 'http://${portNo}:5000/api/v1/debt';

  static Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var accessToken = pref.getString("accessToken");

    if (accessToken == null) {
      print("No access token found in SharedPreferences");
      return null;
    } else {
      print("Token: $accessToken");
      return accessToken;
    }
  }

  static Future<Map<String, dynamic>?> createDebt(
      Map<dynamic, dynamic> debtData) async {
    try {
      var accessToken = await getToken();
      if (accessToken == null) {
        print("Error: No access token available");
        return null;
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "$accessToken",
        },
        body: jsonEncode(debtData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Debt created successfully');
        return jsonDecode(response.body); // Return the JSON response
      } else {
        print('Failed to create debt. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error creating debt: $e');
    }
    return null;
  }

  static Future<List<Debt>> fetchDebts() async {
    try {
      var accessToken = await getToken();
      if (accessToken == null) {
        print("Error: No access token available");
      }

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "$accessToken"
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> body =
            jsonDecode(response.body); // Decode full JSON
        List<dynamic> data = body['data']; // Extract 'data' list
        List<Debt> debts = data
            .map((item) => Debt.fromJson(item))
            .toList(); // Convert list items to Debt objects

        return debts;
      } else {
        throw Exception('Failed to load debts');
      }
    } catch (error) {
      print('Error fetching debts: $error');
      return [];
    }
  }
}

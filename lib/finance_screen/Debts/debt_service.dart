
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DebtService {
  static String _baseUrl = 'http://${portNo}:5000/api/v1/debt';

  

  static Future<Map<String, dynamic>?> createDebt(
      Map<dynamic, dynamic> debtData) async {
    try {
      print(
          "Attempting to create debt with data: $debtData"); // Debug statement
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

    //  print('Response status code: ${response.statusCode}');
    //   print('Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
       
        return jsonDecode(response.body); // Return the JSON response
      } else {
        
      }
    } catch (e) {
     
    }
    return null;
  }

  static Future<List<Debt>> fetchDebts() async {
    try {
     // Debug statement
      var accessToken = await getToken();
      if (accessToken == null) {
       
        return [];
      }

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "$accessToken"
        },
      );

    
      if (response.statusCode == 200) {
        
        List<dynamic> body = jsonDecode(response.body)['data']; // Decode as a list
       // Debug statement
        List<Debt> debts = body.map((item) => Debt.fromJson(item)).toList(); // Convert each item to a Debt object
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

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
final FlutterSecureStorage secureStorage = FlutterSecureStorage();
Future postDataApiCall(String urlPath, Map body) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");
 
  final response = await http.post(
    Uri.parse(urlPath),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    
    body: jsonEncode(body),
  );
  return response;
}

Future postDataApiCallwithOutSharedPref(String urlPath, Map body) async {
  final response = await http.post(
    Uri.parse(urlPath),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(body),
  );
  return response;
}

Future<http.Response> updateDataApiCall(urlPath) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");

  final response = await http.patch(Uri.parse(urlPath),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({}));
  return response;
}

Future<http.Response> updateDataApiCall2(
    String urlPath, Map<String, dynamic> body) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");

  final response = await http.patch(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode(body),
  );
  return response;
}

Future<http.Response> updateDataApiCallWithoutBody(String urlPath) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");

  final response = await http.patch(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  return response;
}

Future<http.Response> updateDataApiCall3(String urlPath,
    {required Map<String, dynamic> data}) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");

  final response = await http.patch(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode(data),
  );
  return response;
}

// Future<http.Response> getDataApiCall(urlPath) async {
//   final SharedPreferences pref = await SharedPreferences.getInstance();
//   var  accessToken= pref.getString("accessToken");
  
//   final response = await http.get(
//     Uri.parse(urlPath),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//       "Authorization": "$accessToken",
//     },
//   );
//   return response;
// }
Future<http.Response> getDataApiCall(String urlPath) async {
  // Read token securely
  String? accessToken = await secureStorage.read(key: "accessToken");

  final response = await http.get(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '$accessToken',
    },
  );

  return response;
}

Future<http.Response> deleteDataApiCall(urlPath) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");
  final response = await http.delete(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  return response;
}

Future<http.Response> deleteDataApiCallBody(urlPath, body) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");
  final response = await http.delete(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode(body),
  );
  return response;
}

bool getFlagOfResponse(response) {
  if (response.statusCode == 200 || response.statusCode == 201) return true;
  return false;
}

void printData(response, [context = ""]) {
   print("Response Data $context : ${response.body}");
   print("Response Status Code  : ${response.statusCode}");  
}

Future<http.Response> getTransactionsWithAmount({
  required String urlPath,
  String minAmount = "",
  String maxAmount = "",
  String startDate = '',
  String endDate = '',
}) async {
 
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");

  // Build the query params
  final queryParams = <String, String>{};
  if (minAmount.isNotEmpty) {
    queryParams['minAmount'] = minAmount;
  }
  if (maxAmount.isNotEmpty) {
    queryParams['maxAmount'] = maxAmount;
  }
  if (startDate.isNotEmpty) {
    queryParams['startDate'] = startDate;
  }
  if (endDate.isNotEmpty) {
    queryParams['endDate'] = endDate;
  }

  

  // Append query params to the URL
  Uri uri = Uri.parse(urlPath).replace(
    queryParameters: {
      ...Uri.parse(urlPath).queryParameters,
      ...queryParams,
    },
  );

 
  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

  
  return response;
}

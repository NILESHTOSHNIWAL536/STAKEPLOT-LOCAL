import 'dart:async';
import 'dart:convert';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/services/secure_storage.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future postDataApiCall(String urlPath, Map body) async {
  var accessToken = await SecureStorageService().read("accessToken");

  final response = await http
      .post(
    Uri.parse(urlPath),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode(body),
  )
      .timeout(
    const Duration(seconds: 30), // ⏳ timeout added here
    onTimeout: () {
      throw TimeoutException("Request timed out");
    },
  );

  return response;
}

Future postDataApiCallwithOutSharedPref(String urlPath, Map body) async {
  final response = await http
      .post(
    Uri.parse(urlPath),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(body),
  )
      .timeout(
    const Duration(seconds: 30), // ⏳ timeout added here
    onTimeout: () {
      throw TimeoutException("Request timed out");
    },
  );
  return response;
}

Future<http.Response> updateDataApiCall(urlPath) async {
  var accessToken = await SecureStorageService().read("accessToken");

  final response = await http
      .patch(Uri.parse(urlPath),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "Authorization": "$accessToken",
          },
          body: jsonEncode({}))
      .timeout(
    const Duration(seconds: 30), // ⏳ timeout added here
    onTimeout: () {
      throw TimeoutException("Request timed out");
    },
  );

  return response;
}

Future<http.Response> updateDataApiCall2(
    String urlPath, Map<String, dynamic> body) async {
  var accessToken = await SecureStorageService().read("accessToken");

  final response = await http
      .patch(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode(body),
  )
      .timeout(
    const Duration(seconds: 30), // ⏳ timeout added here
    onTimeout: () {
      throw TimeoutException("Request timed out");
    },
  );
  return response;
}

Future<http.Response> updateDataApiCallWithoutBody(String urlPath) async {
  var accessToken = await SecureStorageService().read("accessToken");

  final response = await http.patch(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  ).timeout(
    const Duration(seconds: 30), // ⏳ timeout added here
    onTimeout: () {
      throw TimeoutException("Request timed out");
    },
  );
  return response;
}

Future<http.Response> updateDataApiCall3(String urlPath,
    {required Map<String, dynamic> data}) async {
  var accessToken = await SecureStorageService().read("accessToken");

  final response = await http
      .patch(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode(data),
  )
      .timeout(
    const Duration(seconds: 30), // ⏳ timeout added here
    onTimeout: () {
      throw TimeoutException("Request timed out");
    },
  );
  return response;
}

Future<http.Response> getDataApiCall(urlPath) async {
  var accessToken = await SecureStorageService().read("accessToken");
  print("Access Token: $accessToken");
  final response = await http.get(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  ).timeout(
    const Duration(seconds: 30), // ⏳ timeout added here
    onTimeout: () {
      throw TimeoutException("Request timed out");
    },
  );
  // printData(response);
  return response;
}

Future<http.Response> deleteDataApiCall(urlPath) async {
  var accessToken = await SecureStorageService().read("accessToken");

  final response = await http.delete(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  ).timeout(
    const Duration(seconds: 30), // ⏳ timeout added here
    onTimeout: () {
      throw TimeoutException("Request timed out");
    },
  );
  return response;
}

Future<http.Response> deleteDataApiCallBody(urlPath, body) async {
  var accessToken = await SecureStorageService().read("accessToken");

  final response = await http
      .delete(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode(body),
  )
      .timeout(
    const Duration(seconds: 30), // ⏳ timeout added here
    onTimeout: () {
      throw TimeoutException("Request timed out");
    },
  );

  return response;
}

bool getFlagOfResponse(response) {
  if (response.statusCode == 401) {
    Get.toNamed("/");
  } else if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  }
  return false;
}

void printData(response, [context = ""]) {
  appLog("Response Data $context : ${response.body}");
  appLog("Response Status Code  : ${response.statusCode}");
}

Future<http.Response> getTransactionsWithAmount({
  required String urlPath,
  String minAmount = "",
  String maxAmount = "",
  String startDate = '',
  String endDate = '',
}) async {
  var accessToken = await SecureStorageService().read("accessToken");

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
  ).timeout(
    const Duration(seconds: 30), // ⏳ timeout added here
    onTimeout: () {
      throw TimeoutException("Request timed out");
    },
  );

  return response;
}

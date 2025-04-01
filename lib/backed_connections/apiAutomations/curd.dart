import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


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
Future<http.Response> updateDataApiCall2(String urlPath, Map<String, dynamic> body) async {
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

Future<http.Response> getDataApiCall(urlPath) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");
  final response = await http.get(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
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


bool getFlagOfResponse(response) {
  if (response.statusCode == 200 || response.statusCode == 201) return true;
  return false;
}
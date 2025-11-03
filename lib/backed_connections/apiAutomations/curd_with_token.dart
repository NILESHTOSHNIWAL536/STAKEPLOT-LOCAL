
import 'package:http/http.dart' as http;
import 'dart:convert';


Future postDataApiCallToken(String urlPath, Map body,String accessToken) async {
  final response = await http.post(
    Uri.parse(urlPath),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "${accessToken.toString().trim()}",
    },
    body: jsonEncode(body),
  );
  return response;
}

Future<http.Response> getDataApiCallToken(urlPath,String accessToken) async {

  final response = await http.get(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  return response;

}


Future<http.Response> deleteDataApiCall(urlPath,String accessToken) async {
  final response = await http.delete(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  return response;
}


Future<http.Response> updateDataApiCall3(String urlPath,
    {required Map<String, dynamic> data,required String accessToken}) async {

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
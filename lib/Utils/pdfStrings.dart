
import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class PdfStrings {
  // 1. Static instance
  static final PdfStrings _instance = PdfStrings._internal();

  // 2. Private constructor
  PdfStrings._internal();

  // 3. Factory constructor
  factory PdfStrings() => _instance;

   bool isDownloadEnabled=true;
   int  firstPage = 11;
   int  secoundPage = 18;
   int  thirdPage = 16;

    void fetchConstants() async {
    try {
      final response = await getDataApiCall("${url}/constant/pdf");
      printData(response);
      if (response.statusCode == 200)
      {
           var data = jsonDecode(response.body);
           data = data['data'] ?? {};
           isDownloadEnabled= data['isDownloadEnabled'] ?? isDownloadEnabled;
           firstPage= data['firstPage'] ?? firstPage;
           secoundPage= data['secoundPage'] ?? secoundPage;
           thirdPage= data['thirdPage'] ?? thirdPage;

      }

    }catch(e){
       print(e);
    }
  }

}


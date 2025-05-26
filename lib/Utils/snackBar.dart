


import 'dart:ffi';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class SnackbarData {

   static final SnackbarData _instance = SnackbarData._internal();

  // 2. Private constructor
  SnackbarData._internal();

  // 3. Factory constructor
  factory SnackbarData() => _instance;


   void fetchConstants() async
  {
    try {
      final response = await getDataApiCall("${url}/constant/snackbar");
      printData(response);
      if (response.statusCode == 200)
      {

      }

    }
    catch (e) {
      print("Error fetching Snackbar constants: $e");
    }


  }

}
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class InsightsController extends GetxController {
  final RxList<Map<String, dynamic>> totalInSights = <Map<String, dynamic>>[].obs;
  final RxBool getTotalInsightsHistory = false.obs;
  final RxList<Map<String, dynamic>> totalInSightsMoneyMap = <Map<String, dynamic>>[].obs;
  final RxBool getTotalInsightsHistorytotalMoneyMap = false.obs;


  Future<void> getHomePageInsights(BuildContext context) async {
   // print('InsightsController: getHomePageInsights called');
    try {
      // print('InsightsController: Calling API: ${url}/transactionauto/get-headsup-messages');
      var response = await getDataApiCall("${url}/transactionauto/get-headsup-messages");
      // print('InsightsController: API response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // print('InsightsController: API call successful, parsing response...');
        var his = jsonDecode(response.body);
        // print('InsightsController: Parsed response: $his');
        var obj = his['data'] as List;
        // print('InsightsController: Data extracted: $obj');

        totalInSights.clear();
        // print('InsightsController: Cleared totalInSights, adding new data...');
        totalInSights.addAll(obj.map((item) => item as Map<String, dynamic>).toList());
        // print('InsightsController: Updated totalInSights: $totalInSights');

        getTotalInsightsHistory.value = !getTotalInsightsHistory.value;
        // print('InsightsController: Toggled getTotalInsightsHistory: ${getTotalInsightsHistory.value}');
      } else {
        // print('InsightsController: API call failed with status code: ${response.statusCode}');
        // print('InsightsController: Response body: ${response.body}');
      }
    } catch (e) {
      // print('InsightsController: Error in getHomePageInsights: $e');
    }
  }
Future<void> getHomePageMoneyMapInsights(BuildContext context) async {
  
    try {
    
      var response = await getDataApiCall("${url}/transactionauto/get-money-map-messages");
      

      if (response.statusCode == 200) {
      
        var his = jsonDecode(response.body);
      
        var obj = his['data'] as List;
     

        totalInSightsMoneyMap.clear();
     
        totalInSightsMoneyMap.addAll(obj.map((item) => item as Map<String, dynamic>).toList());
      

        getTotalInsightsHistorytotalMoneyMap.value = !getTotalInsightsHistorytotalMoneyMap.value;
      } else {
        
      }
    } catch (e) {
    }
  }

}

                         
                         
                             

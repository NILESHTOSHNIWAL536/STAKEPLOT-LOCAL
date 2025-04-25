import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    print('Insights money map Controller: getHomePageInsights called');
    try {
      print('InsightsController money map Controller: Calling API: ${url}/transactionauto/get-money-map-messages');
      var response = await getDataApiCall("${url}/transactionauto/get-money-map-messages");
      print('InsightsControllermoney map Controller: API response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('InsightsController: API call successful, parsing response...');
        var his = jsonDecode(response.body);
        print('InsightsController: Parsed response: $his');
        var obj = his['data'] as List;
        print('InsightsController: Data extracted: $obj');

        totalInSightsMoneyMap.clear();
        print('InsightsController: Cleared totalInSights, adding new data...');
        totalInSightsMoneyMap.addAll(obj.map((item) => item as Map<String, dynamic>).toList());
        print('InsightsController: Updated totalInSights: $totalInSightsMoneyMap');

        getTotalInsightsHistorytotalMoneyMap.value = !getTotalInsightsHistorytotalMoneyMap.value;
        print('InsightsController: Toggled getTotalInsightsHistory: ${getTotalInsightsHistory.value}');
      } else {
        print('InsightsController: API call failed with status code: ${response.statusCode}');
        print('InsightsController: Response body: ${response.body}');
      }
    } catch (e) {
      print('InsightsController: Error in getHomePageInsights: $e');
    }
  }

}

                         
                         
                             

Future<Map<String, dynamic>> getUserStats() async {
  final pref = await SharedPreferences.getInstance();
  final userId = pref.getString('accessToken') ?? ''; 
  final todayKey = 'login_count_${DateTime.now().toIso8601String().substring(0, 10)}_$userId';

  final tracker = ScreenTimeTracker();
  await tracker.setUser(userId);
  tracker.startSession();

  // Extract only the value after the last colon from each entry
  List<String> extractValues(List<String>? entries) {
    return entries?.map((e) {
      final parts = e.split(':');
      return parts.isNotEmpty ? parts.last : '';
    }).toList() ?? [];
  }

  return 
 {
    'loginCount': pref.getInt(todayKey) ?? 0, // previously 'daily_login_count'
    'loginHistory': extractValues(pref.getStringList('login_history_$userId')), // previously 'login_history'
    'appOpenCount': tracker.getDailyAppOpenCount(), // previously 'daily_app_open_count'
    'appOpenHistory': extractValues(tracker.getAppOpenHistory()), // previously 'app_open_history'
    'appEventLog': tracker.getAppEventLog(), // optional: only if needed
    'tabScreenTime': tracker.getTabScreenTime(), // previously 'tab_screen_time'
    'totalScreenTime': tracker.getTotalScreenTime(), // make sure this is implemented if not
  };

}



Future<void> setUserStats(Map<String, dynamic> data) async {
  final pref = await SharedPreferences.getInstance();
  final userId = pref.getString('accessToken') ?? '';
  final todayDate = DateTime.now().toIso8601String().substring(0, 10);
  final todayLoginKey = 'login_count_${todayDate}_$userId';

  // Save login count
  await pref.setInt(todayLoginKey, data['daily_login_count'] ?? 0);

  // Save login history
  final List<String> loginHistory = (data['login_history'] as List)
      .map((e) => e.toString())
      .toList();
  await pref.setStringList('login_history_$userId', loginHistory);

  // Save app open history
  final List<String> appOpenHistory = (data['app_open_history'] as List)
      .map((e) => e.toString())
      .toList();
  await pref.setStringList('app_open_history_$userId', appOpenHistory);

  // Save app event log
  final List<String> eventLog = (data['app_event_log'] as List)
      .map((e) => e.toString())
      .toList();
  await pref.setStringList('app_event_log_$userId', eventLog);

  // Save tab screen time (as JSON)
  final tabScreenTime = data['tab_screen_time'] as Map<String, dynamic>;
  await pref.setString(
    'tab_screen_time_$userId',
    jsonEncode(tabScreenTime),
  );

  // Save app open count separately if needed
  await pref.setInt(
    'app_open_count_${todayDate}_$userId',
    data['daily_app_open_count'] ?? 0,
  );
}

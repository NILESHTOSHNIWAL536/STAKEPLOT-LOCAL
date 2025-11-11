import 'dart:io';
import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart'; // Import for 'url' global

const List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

int daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}

String getMonthlyRange() {
  final now = DateTime.now();
  final firstDay = 1;
  final lastDay = now.day; // Use current day instead of full month end
  return '01 ${monthNames[now.month - 1]} - ${lastDay.toString().padLeft(2, '0')} ${monthNames[now.month - 1]}';
}

// Top-level callback for WorkManager (runs in background isolate)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Restore full API URL and token from SharedPreferences (stored during app init)
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken'); 
      // Your exact token key from LoginService
      String fullApiUrl = prefs.getString('full_api_url') ?? ''; // Stored full URL with /api/v1
     

      if (fullApiUrl.isEmpty || token == null || token.isEmpty) {
        await _updateWidgetWithFallback(prefs);
        return Future.value(false);
      }
      
      // Fetch remainders data directly (replicating getRemainders logic)
      String urlPath = "${fullApiUrl}/reminders";
     
      var response = await http.get(
        Uri.parse(urlPath),
        headers: {
          // Handle Bearer prefix based on how it's stored
          'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    
      
      String toReceive = 'None: ₹0';
      String toPay = 'None: ₹0';
     
      if (response.statusCode == 200) {
        // Assuming getFlagOfResponse checks for success; here we assume 200 is good
        var his = json.decode(response.body);
      
        var payables = his['data']['payables'] ?? <Map<String, dynamic>>[];
       
        var owed = his['data']['owed'] ?? <Map<String, dynamic>>[];
        
        
        // Build toPay from payables (first item)
        if (payables.isNotEmpty) {
        
          final data = payables.first;
          toPay = '${data['name'] ?? data['userName'] ?? "Unknown"}: ₹${(data['amount'] ?? 0).toStringAsFixed(2)}';
        }
        
        // Build toReceive from owed (first item)
        if (owed.isNotEmpty) {
        
          final data = owed.first;
          toReceive = '${data['name'] ?? data['userName'] ?? "Unknown"}: ₹${(data['amount'] ?? 0).toStringAsFixed(2)}';
        }
      }

      // Save payable data to SharedPreferences (widget reads this)
      await prefs.setString('to_receive', toReceive);
      await prefs.setString('to_pay', toPay);
      
      // Trigger payable widget update (broadcasts to native provider)
      await HomeWidget.saveWidgetData<String>('to_receive', toReceive);
      await HomeWidget.saveWidgetData<String>('to_pay', toPay);
      await HomeWidget.updateWidget(
        name: 'PayableWidgetProvider',
        androidName: 'PayableWidgetProvider',
        iOSName: 'PayableWidget',  // If supporting iOS
      );

      // Fetch spending categories data using the correct endpoint
      String? accountId = prefs.getString('accountId'); // Assuming accountId is stored; adjust key if needed (e.g., 'selectedAccountId')
      final now = DateTime.now();
      final startDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-01'; // YYYY-MM-01 for month start
      final endDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'; // Up to current day
      Uri spendingUri = Uri.parse("${fullApiUrl}/transactionauto/categorize").replace(queryParameters: {
        if (accountId != null && accountId.isNotEmpty) 'accountId': accountId,
        'startDate': startDate,
        'endDate': endDate,
      });
      var spendingResponse = await http.get(
        spendingUri,
        headers: {
          'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      String totalSpending = '₹0';
      String categoriesStr = 'None';
      String timestamp = getMonthlyRange();

      if (spendingResponse.statusCode == 200) {
        var data = json.decode(spendingResponse.body);
        if (data['data'] != null) {
          double total = double.tryParse(data['data']['totalDebitThisMonth']?.toString() ?? '0') ?? 0.0;
          // Prioritize top-level 'categorized' (monthly, as in getCategoryData); fallback to 'week' if empty
          var categorized = data['data']['categorized'] ?? data['data']['week']?['categorized'] ?? <Map<String, dynamic>>[];

          totalSpending = '₹${total.toStringAsFixed(2)}';
          if (categorized.isNotEmpty) {
            categoriesStr = categorized.map((cat) {
              double debit = double.tryParse(cat['total_debit']?.toString() ?? '0') ?? 0.0;
              return '${cat['category'] ?? 'Unknown'}: ₹${debit.toStringAsFixed(2)}';
            }).join('\n');
          }
        }
      }

      // Save spending data to SharedPreferences
      await prefs.setString('total_spending', totalSpending);
      await prefs.setString('categories', categoriesStr);
      await prefs.setString('timestamp', timestamp);

      // Trigger spending widget update
      await HomeWidget.saveWidgetData<String>('total_spending', totalSpending);
      await HomeWidget.saveWidgetData<String>('categories', categoriesStr);
      await HomeWidget.saveWidgetData<String>('timestamp', timestamp);
      await HomeWidget.updateWidget(
        name: 'StakeplotWidgetProvider',
        androidName: 'StakeplotWidgetProvider',
        iOSName: 'StakeplotWidget',
      );
      
     
      return Future.value(true);
    } catch (e) {
     
      final prefs = await SharedPreferences.getInstance();
      await _updateWidgetWithFallback(prefs);
      return Future.value(false);
    }
  });
}

// Helper: Update widget with error/fallback values
Future<void> _updateWidgetWithFallback(SharedPreferences prefs) async {
  // Fallback for payable widget
  String payableErrorMsg = 'Error: Check app';
  await prefs.setString('to_receive', payableErrorMsg);
  await prefs.setString('to_pay', payableErrorMsg);
  await HomeWidget.saveWidgetData<String>('to_receive', payableErrorMsg);
  await HomeWidget.saveWidgetData<String>('to_pay', payableErrorMsg);
  await HomeWidget.updateWidget(
    name: 'PayableWidgetProvider',
    androidName: 'PayableWidgetProvider',
    iOSName: 'PayableWidget',
  );

  // Fallback for spending widget
  String totalSpendingFallback = '₹0';
  String categoriesFallback = 'None';
  String timestampFallback = getMonthlyRange();
  await prefs.setString('total_spending', totalSpendingFallback);
  await prefs.setString('categories', categoriesFallback);
  await prefs.setString('timestamp', timestampFallback);
  await HomeWidget.saveWidgetData<String>('total_spending', totalSpendingFallback);
  await HomeWidget.saveWidgetData<String>('categories', categoriesFallback);
  await HomeWidget.saveWidgetData<String>('timestamp', timestampFallback);
  await HomeWidget.updateWidget(
    name: 'StakeplotWidgetProvider',
    androidName: 'StakeplotWidgetProvider',
    iOSName: 'StakeplotWidget',
  );
}

// Initialize widget service (WorkManager setup only)
void initializeWidgetService() {
  // Initialize WorkManager
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,  // More logs in debug
  );

  // Register periodic task (runs ~every 15 mins, even when app is closed)
  Workmanager().registerPeriodicTask(
    "widget-refresh-unique-id",  // Unique name
    "periodic-widget-update",    // Task label
    frequency: const Duration(minutes: 15),  // Minimum interval
    constraints: Constraints(
      networkType: NetworkType.connected,    // Requires internet
      requiresBatteryNotLow: true,           // Skip if battery low
      requiresCharging: false,               // Can run unplugged
      requiresDeviceIdle: false,             // Run even if active
      requiresStorageNotLow: false,
    ),
    backoffPolicy: BackoffPolicy.exponential,  // Retry on failure
    backoffPolicyDelay: const Duration(seconds: 10),
  );

  // Optional: Immediate one-off sync on app start (unique ID with timestamp)
  Workmanager().registerOneOffTask(
    "initial-widget-sync-${DateTime.now().millisecondsSinceEpoch}",
    "one-off-widget-update",
    constraints: Constraints(networkType: NetworkType.connected),
  );
}
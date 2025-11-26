import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/widget_services/widget_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateWidgetSpendingCategories() async {
  try {
    final total = '₹${totalValue.value?.toStringAsFixed(2) ?? '0.00'}';
    final timestamp = getMonthlyRange();
    String categories = 'None';
    if (spendingsOnCategories.isNotEmpty) {
      categories = spendingsOnCategories
          .map((data) => '${data.category}: ₹${data.value.toStringAsFixed(2)}')
          .join('\n');
    }

    await HomeWidget.saveWidgetData<String>('total_spending', total);
    await HomeWidget.saveWidgetData<String>('categories', categories);
    await HomeWidget.saveWidgetData<String>('timestamp', timestamp);

    await HomeWidget.updateWidget(
      name: 'StakeplotWidgetProvider',
      androidName: 'StakeplotWidgetProvider',
      iOSName: 'StakeplotWidget',
    );
  } catch (e) {}
}

Future<void> updateWidget() async {
  final prefs = await SharedPreferences.getInstance();
  try {
    String toReceive = 'None: ₹0';
    String toPay = 'None: ₹0';

    if (lendAmountRemainders.isNotEmpty && lendAmountRemainders.first != null) {
      final data = lendAmountRemainders.first;
      toReceive =
          '${data["name"] ?? "Unknown"}: ₹${(data["amount"] ?? 0).toStringAsFixed(2)}';
    }
    if (dueAmountRemainders.isNotEmpty && dueAmountRemainders.first != null) {
      final data = dueAmountRemainders.first;
      toPay =
          '${data["name"] ?? "Unknown"}: ₹${(data["amount"] ?? 0).toStringAsFixed(2)}';
    }
    await prefs.setString('to_receive', toReceive);
    await prefs.setString('to_pay', toPay);
    // Save to HomeWidget (updates UserDefaults for iOS)
    await HomeWidget.saveWidgetData<String>('to_receive', toReceive);
    await HomeWidget.saveWidgetData<String>('to_pay', toPay);
    await HomeWidget.updateWidget(
      name: 'PayableWidgetProvider',
      androidName: 'PayableWidgetProvider',
      iOSName: 'PayableWidget',
    );
  } catch (e) {
    await prefs.setString('to_receive', 'Error');
    await prefs.setString('to_pay', 'Error');
    await HomeWidget.saveWidgetData<String>('to_receive', 'Error');
    await HomeWidget.saveWidgetData<String>('to_pay', 'Error');
    await HomeWidget.updateWidget(
      name: 'PayableWidgetProvider',
      androidName: 'PayableWidgetProvider',
      iOSName: 'PayableWidget',
    );
  }
}

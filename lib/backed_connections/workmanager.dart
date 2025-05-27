import 'package:flutter_application_code_stakeplot/Home_Screen/donut_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

const String taskName = "updateWidgetTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Fetch data (replace with your getCategoryData logic)
       getCategoryData();
      // Update widget
      await HomeWidget.saveWidgetData<String>('total_spending', '₹${totalValue.value.toStringAsFixed(2)}');
      await HomeWidget.saveWidgetData<String>('categories', chartData.map((data) => '${data.category}: ₹${data.value.toStringAsFixed(2)}').join('\n'));
      await HomeWidget.saveWidgetData<String>('timestamp', getMonthlyRange());
      await HomeWidget.updateWidget(
        name: 'StakeplotWidgetProvider',
        androidName: 'StakeplotWidgetProvider',
      );
    } catch (e) {
    }
    return Future.value(true);
  });
}

void scheduleWidgetUpdate() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "1",
    taskName,
    frequency: Duration(minutes: 15), // Android minimum is 15 minutes
  );
}
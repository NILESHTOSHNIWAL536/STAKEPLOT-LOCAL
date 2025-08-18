import '../../backed_connections/apiAutomations/bankinfo.dart';
import '../../model/fips_metric_model.dart';
import '../fip_metric_bata/fips_metric.dart';
import '../hive_storage.dart';
import 'init_hive.dart';

class FipsMetricLocalStorage {
  /// Save RxList to Hive
  static Future<void> saveFipsMetricsToHive() async {
try{
    HiveHelper.openBoxIfNot<FipsMetrics>(HiveStorage.fipsMetricBoxName);
    final box =await HiveStorage.fipsMetricBox;
    await box.clear();
 fipsMetricList.forEach((element){
    box.add(
      FipsMetrics(
        timestamp: element.timestamp,
          fipId: element.fipId,
          eventName: element.eventName,
          bankName: element.BankName,
          latencyAvgMs: element.latencyAvgMs,
          successPercent: element.successPercent,
          timeoutPercent: element.timeoutPercent,
          accNotFoundPercent: element.accNotFoundPercent,
          serverErrorPercent: element.serverErrorPercent,
          clientErrorPercent: element.clientErrorPercent,
          latencyP99Ms: element.latencyP99Ms,
          latencyP95Ms: element.latencyP95Ms,
          latencyP50Ms: element.latencyP50Ms)
      );
    });
}catch(e){
    
}
    // Explicitly cast to avoid type issues
  }

  /// Load from Hive into RxList
static Future<void> loadFipsMetricsFromHive() async {
  try{
  HiveHelper.openBoxIfNot<FipsMetrics>(HiveStorage.fipsMetricBoxName);
   final box =await HiveStorage.fipsMetricBox;
    fipsMetricList.clear();

    box.values.forEach((element) {
      fipsMetricList.add(FipsMetric(
          timestamp: element.timestamp,
          fipId: element.fipId,
          eventName: element.eventName,
          BankName: element.bankName,
          latencyAvgMs: element.latencyAvgMs,
          successPercent: element.successPercent,
          timeoutPercent: element.timeoutPercent,
          accNotFoundPercent: element.accNotFoundPercent,
          serverErrorPercent: element.serverErrorPercent,
          clientErrorPercent: element.clientErrorPercent,
          latencyP99Ms: element.latencyP99Ms,
          latencyP95Ms: element.latencyP95Ms,
          latencyP50Ms: element.latencyP50Ms));
    });
  }catch(e){
    
}
}
}
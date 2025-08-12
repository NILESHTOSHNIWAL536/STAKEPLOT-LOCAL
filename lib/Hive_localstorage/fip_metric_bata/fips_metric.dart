import 'package:hive/hive.dart';

part 'fips_metric.g.dart'; // will be generated

@HiveType(typeId: 4) // Make sure this ID is unique across all adapters
class FipsMetrics extends HiveObject {
  @HiveField(0)
  DateTime timestamp;

  @HiveField(1)
  String fipId;

  @HiveField(2)
  String bankName;

  @HiveField(3)
  String eventName;

  @HiveField(4)
  num latencyAvgMs;

  @HiveField(5)
  num successPercent;

  @HiveField(6)
  num timeoutPercent;

  @HiveField(7)
  num accNotFoundPercent;

  @HiveField(8)
  num serverErrorPercent;

  @HiveField(9)
  num clientErrorPercent;

  @HiveField(10)
  num latencyP99Ms;

  @HiveField(11)
  num latencyP95Ms;

  @HiveField(12)
  num latencyP50Ms;

  FipsMetrics({
    required this.timestamp,
    required this.fipId,
    required this.eventName,
    required this.bankName,
    required this.latencyAvgMs,
    required this.successPercent,
    required this.timeoutPercent,
    required this.accNotFoundPercent,
    required this.serverErrorPercent,
    required this.clientErrorPercent,
    required this.latencyP99Ms,
    required this.latencyP95Ms,
    required this.latencyP50Ms,
  });

  factory FipsMetrics.fromJson(Map<String, dynamic> json, String bankName) {
    return FipsMetrics(
      timestamp: DateTime.parse(json['timestamp']),
      fipId: json['fip_id'] ?? '',
      bankName: bankName,
      eventName: json['event_name'] ?? '',
      latencyAvgMs: json['latency_avg_ms'] ?? 0,
      successPercent: json['success_percent'] ?? 0,
      timeoutPercent: json['timeout_percent'] ?? 0,
      accNotFoundPercent: json['acc_not_found_percent'] ?? 0,
      serverErrorPercent: json['server_error_percent'] ?? 0,
      clientErrorPercent: json['client_error_percent'] ?? 0,
      latencyP99Ms: json['latencyP99_ms'] ?? 0,
      latencyP95Ms: json['latencyP95_ms'] ?? 0,
      latencyP50Ms: json['latencyP50_ms'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'fip_id': fipId,
      'BankName': bankName,
      'event_name': eventName,
      'latency_avg_ms': latencyAvgMs,
      'success_percent': successPercent,
      'timeout_percent': timeoutPercent,
      'acc_not_found_percent': accNotFoundPercent,
      'server_error_percent': serverErrorPercent,
      'client_error_percent': clientErrorPercent,
      'latencyP99_ms': latencyP99Ms,
      'latencyP95_ms': latencyP95Ms,
      'latencyP50_ms': latencyP50Ms,
    };
  }
}

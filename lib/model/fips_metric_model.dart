class FipsMetric {
  final DateTime timestamp;
  final String fipId;
  final String BankName;
  final String eventName;
  final num latencyAvgMs;
  final num successPercent;
  final num timeoutPercent;
  final num accNotFoundPercent;
  final num serverErrorPercent;
  final num clientErrorPercent;
  final num latencyP99Ms;
  final num latencyP95Ms;
  final num latencyP50Ms;

  FipsMetric({
    required this.timestamp,
    required this.fipId,
    required this.eventName,
    required this.BankName,
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

  factory FipsMetric.fromJson(Map<String, dynamic> json,String BankName) {
    return FipsMetric(
      timestamp: DateTime.parse(json['timestamp']),
      fipId: json['fip_id'] ?? '',
      BankName: BankName ,
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
      'BankName': BankName,
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

import 'package:get/get.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class FipMetricEntry {
  final String fipId;
  final String eventName;
  final double latencyAvgMs;
  final double successPercent;
  final double timeoutPercent;
  final double accNotFoundPercent;
  final double serverErrorPercent;
  final double clientErrorPercent;
  final double latencyP99Ms;
  final double latencyP95Ms;
  final double latencyP50Ms;
  final String timestamp;

  FipMetricEntry({
    required this.fipId,
    required this.eventName,
    required this.latencyAvgMs,
    required this.successPercent,
    required this.timeoutPercent,
    required this.accNotFoundPercent,
    required this.serverErrorPercent,
    required this.clientErrorPercent,
    required this.latencyP99Ms,
    required this.latencyP95Ms,
    required this.latencyP50Ms,
    required this.timestamp,
  });

  factory FipMetricEntry.fromJson(Map<String, dynamic> json) {
    return FipMetricEntry(
      fipId: json['fip_id'] ?? '',
      eventName: json['event_name'] ?? '',
      latencyAvgMs: (json['latency_avg_ms'] ?? 0).toDouble(),
      successPercent: (json['success_percent'] ?? 0).toDouble(),
      timeoutPercent: (json['timeout_percent'] ?? 0).toDouble(),
      accNotFoundPercent: (json['acc_not_found_percent'] ?? 0).toDouble(),
      serverErrorPercent: (json['server_error_percent'] ?? 0).toDouble(),
      clientErrorPercent: (json['client_error_percent'] ?? 0).toDouble(),
      latencyP99Ms: (json['latencyP99_ms'] ?? 0).toDouble(),
      latencyP95Ms: (json['latencyP95_ms'] ?? 0).toDouble(),
      latencyP50Ms: (json['latencyP50_ms'] ?? 0).toDouble(),
      timestamp: json['timestamp'] ?? '',
    );
  }

  /// True if this event had 100% success and no timeouts
  bool get isHealthy =>
      successPercent >= 95 &&
      timeoutPercent == 0 &&
      serverErrorPercent == 0;

  FipHealthStatus get healthStatus {
    if (successPercent == 100 && timeoutPercent == 0) return FipHealthStatus.healthy;
    if (successPercent >= 80) return FipHealthStatus.degraded;
    return FipHealthStatus.down;
  }
}

enum FipHealthStatus { healthy, degraded, down, unknown }

// ─── Controller ───────────────────────────────────────────────────────────────

class FipMetricsController extends GetxController {
  static FipMetricsController get to => Get.find<FipMetricsController>();

  /// The consent handle returned from the login/session API
  final RxString consentHandleId = ''.obs;

  /// All metrics grouped by fipId  →  List<FipMetricEntry>
  final RxMap<String, List<FipMetricEntry>> fipMetrics =
      <String, List<FipMetricEntry>>{}.obs;

  // ── Populate from API response ─────────────────────────────────────────────

  void loadFromResponse(Map<String, dynamic> data) {
    consentHandleId.value = data['consentHandleId'] ?? '';

    final List<dynamic> raw = data['metric'] ?? [];
    final Map<String, List<FipMetricEntry>> grouped = {};

    for (final item in raw) {
      final entry = FipMetricEntry.fromJson(item as Map<String, dynamic>);
      grouped.putIfAbsent(entry.fipId, () => []).add(entry);
    }

    fipMetrics.assignAll(grouped);
  }

  // ── Easy access helpers ────────────────────────────────────────────────────

  /// All metric events for a given FIP
  List<FipMetricEntry> getMetricsFor(String fipId) =>
      fipMetrics[fipId] ?? [];

  /// Worst health status across all events for the FIP
  FipHealthStatus healthFor(String fipId) {
    final metrics = getMetricsFor(fipId);
    if (metrics.isEmpty) return FipHealthStatus.unknown;
    if (metrics.every((m) => m.healthStatus == FipHealthStatus.healthy)) {
      return FipHealthStatus.healthy;
    }
    if (metrics.any((m) => m.healthStatus == FipHealthStatus.down)) {
      return FipHealthStatus.down;
    }
    return FipHealthStatus.degraded;
  }

  /// Average latency across all events for a FIP (ms)
  double avgLatencyFor(String fipId) {
    final metrics = getMetricsFor(fipId);
    if (metrics.isEmpty) return 0;
    return metrics.map((m) => m.latencyAvgMs).reduce((a, b) => a + b) /
        metrics.length;
  }

  double avgLatencyForEvent(String fipId) {
    final entry = getEventMetric(fipId, 'FIP:AA:UserDiscoveryResponse');
    return entry?.latencyAvgMs ?? 0;
  }

  /// Success % for a specific event type under a FIP
  /// e.g. getEventMetric('fip@finbank', 'FIP:AA:FIFetchResponse')
  FipMetricEntry? getEventMetric(String fipId, String eventName) {
    return getMetricsFor(fipId)
        .cast<FipMetricEntry?>()
        .firstWhere((m) => m?.eventName == eventName, orElse: () => null);
  }

  /// Quick boolean — is this FIP fully operational?
  bool isFipHealthy(String fipId) => healthFor(fipId) == FipHealthStatus.healthy;

  /// True if ALL known FIPs are healthy
  bool get allFipsHealthy =>
      fipMetrics.keys.every((id) => isFipHealthy(id));

  // ── Reset ──────────────────────────────────────────────────────────────────

  void clear() {
    consentHandleId.value = '';
    fipMetrics.clear();
  }
}
import 'package:get/get.dart';

// ─── Event name constants ──────────────────────────────────────────────────

class FipEvents {
  static const userDiscovery      = 'FIP:AA:UserDiscoveryResponse';
  static const userLinking        = 'FIP:AA:UserLinkingResponse';
  static const userConfirmLinking = 'FIP:AA:UserConfirmLinkingResponse';
  static const consentPost        = 'FIP:AA:ConsentPostResponse';
  static const fiRequest          = 'FIP:AA:FIRequestResponse';
  static const fiFetch            = 'FIP:AA:FIFetchResponse';
  static const fiNotification     = 'AA:FIP:FINotificationResponse';
}

// ─── Health status ─────────────────────────────────────────────────────────

enum FipHealthStatus { healthy, degraded, down, unknown }

// ─── User-facing message model ─────────────────────────────────────────────

class FipUserMessage {
  final FipMessageSeverity severity;
  final String title;
  final String detail;

  const FipUserMessage({
    required this.severity,
    required this.title,
    required this.detail,
  });
}

enum FipMessageSeverity { info, warning, error }

// ─── Metric entry model ────────────────────────────────────────────────────

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
    // timestamp can be either a plain string or {"$date": "..."}
    String ts = '';
    final rawTs = json['timestamp'];
    if (rawTs is String) {
      ts = rawTs;
    } else if (rawTs is Map) {
      ts = rawTs['\$date']?.toString() ?? '';
    }

    return FipMetricEntry(
      fipId:               json['fip_id']                ?? '',
      eventName:           json['event_name']            ?? '',
      latencyAvgMs:       (json['latency_avg_ms']        ?? 0).toDouble(),
      successPercent:     (json['success_percent']       ?? 0).toDouble(),
      timeoutPercent:     (json['timeout_percent']       ?? 0).toDouble(),
      accNotFoundPercent: (json['acc_not_found_percent'] ?? 0).toDouble(),
      serverErrorPercent: (json['server_error_percent']  ?? 0).toDouble(),
      clientErrorPercent: (json['client_error_percent']  ?? 0).toDouble(),
      latencyP99Ms:       (json['latencyP99_ms']         ?? 0).toDouble(),
      latencyP95Ms:       (json['latencyP95_ms']         ?? 0).toDouble(),
      latencyP50Ms:       (json['latencyP50_ms']         ?? 0).toDouble(),
      timestamp: ts,
    );
  }

  FipHealthStatus get healthStatus {
    if (successPercent == 100 && timeoutPercent == 0 && serverErrorPercent == 0) {
      return FipHealthStatus.healthy;
    }
    if (successPercent >= 80) return FipHealthStatus.degraded;
    return FipHealthStatus.down;
  }
}

// ─── Controller ────────────────────────────────────────────────────────────

class FipMetricsController extends GetxController {
  static FipMetricsController get to => Get.find<FipMetricsController>();

  final RxString consentHandleId = ''.obs;

  /// fipId → list of all event entries (up to 7 event types)
  final RxMap<String, List<FipMetricEntry>> fipMetrics =
      <String, List<FipMetricEntry>>{}.obs;

  // ── Load ─────────────────────────────────────────────────────────────────

  /// Accepts both API shapes:
  ///   { "consentHandleId": "...", "metric": [...] }   ← login response
  ///   [...]                                            ← direct metrics array
  void loadFromResponse(dynamic data) {
    List<dynamic> raw = [];

    if (data is Map<String, dynamic>) {
      consentHandleId.value = data['consentHandleId'] ?? '';
      raw = data['metric'] ?? [];
    } else if (data is List) {
      raw = data;
    }

    final Map<String, List<FipMetricEntry>> grouped = {};
    for (final item in raw) {
      final entry = FipMetricEntry.fromJson(item as Map<String, dynamic>);
      grouped.putIfAbsent(entry.fipId, () => []).add(entry);
    }
    fipMetrics.assignAll(grouped);
  }

  // ── Basic accessors ───────────────────────────────────────────────────────

  List<FipMetricEntry> getMetricsFor(String fipId) =>
      fipMetrics[fipId] ?? [];

  FipMetricEntry? getEventMetric(String fipId, String eventName) =>
      getMetricsFor(fipId)
          .cast<FipMetricEntry?>()
          .firstWhere((m) => m?.eventName == eventName, orElse: () => null);

  // ── Discovery latency (single event, not average of all) ─────────────────

  double avgLatencyFor(String fipId) {
    final entry = getEventMetric(fipId, FipEvents.userDiscovery);
    return entry?.latencyAvgMs ?? 0;
  }

  // ── Discovery health badge ────────────────────────────────────────────────

  FipHealthStatus healthFor(String fipId) {
    final entry = getEventMetric(fipId, FipEvents.userDiscovery);
    if (entry == null) return FipHealthStatus.unknown;
    return entry.healthStatus;
  }

  bool isFipHealthy(String fipId) => healthFor(fipId) == FipHealthStatus.healthy;

  // ═══════════════════════════════════════════════════════════════════════════
  // USER-FACING MESSAGES
  // ═══════════════════════════════════════════════════════════════════════════

  // ── 1. DISCOVERY ─────────────────────────────────────────────────────────
  // Shown on DiscoverAccount screen under each bank row.

  List<FipUserMessage> discoveryMessages(String fipId) {
    final e = getEventMetric(fipId, FipEvents.userDiscovery);
    if (e == null) return [];

    final msgs = <FipUserMessage>[];

    // Full outage — show first, skip rest
    if (e.successPercent == 0) {
      return [
        const FipUserMessage(
          severity: FipMessageSeverity.error,
          title: 'Discovery unavailable',
          detail: 'This bank is not responding right now. Please try again later.',
        )
      ];
    }

    // Server errors
    if (e.serverErrorPercent > 0) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.error,
        title: 'Bank server issues',
        detail:
            'Server errors (${e.serverErrorPercent.toStringAsFixed(0)}%) are affecting '
            'account discovery. It may fail — try again shortly.',
      ));
    }

    // Accounts not found
    if (e.accNotFoundPercent > 0) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.warning,
        title: 'Some accounts may not appear',
        detail:
            '${e.accNotFoundPercent.toStringAsFixed(0)}% of searches returned no accounts. '
            'If you don\'t see your account, check your registered mobile number.',
      ));
    }

    // Client errors (mobile mismatch, bad input)
    if (e.clientErrorPercent >= 20) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.warning,
        title: 'Frequent search errors',
        detail:
            '${e.clientErrorPercent.toStringAsFixed(0)}% of searches are failing. '
            'Make sure you use your bank-registered mobile number.',
      ));
    }

    // Partial success
    if (e.successPercent < 100 && e.successPercent > 0) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.warning,
        title: 'Partial availability',
        detail:
            'Only ${e.successPercent.toStringAsFixed(0)}% of discovery requests '
            'are succeeding right now.',
      ));
    }

    // Slow responses
    if (e.latencyAvgMs > 1000) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.info,
        title: 'Slow response expected',
        detail:
            'Average response is ${(e.latencyAvgMs / 1000).toStringAsFixed(1)}s — '
            'this may take a moment.',
      ));
    }

    // All good
    if (msgs.isEmpty) {
      msgs.add(const FipUserMessage(
        severity: FipMessageSeverity.info,
        title: 'Account search is working normally',
        detail: 'Discovery is running smoothly for this bank.',
      ));
    }

    return msgs;
  }

  // ── 2. ACCOUNT LINKING ───────────────────────────────────────────────────
  // Shown on LinkingAccount screen.

  List<FipUserMessage> linkingMessages(String fipId) {
    final e = getEventMetric(fipId, FipEvents.userLinking);
    if (e == null) return [];

    final msgs = <FipUserMessage>[];

    if (e.successPercent == 0) {
      return [
        const FipUserMessage(
          severity: FipMessageSeverity.error,
          title: 'Account linking unavailable',
          detail: 'This bank is not accepting linking requests right now.',
        )
      ];
    }

    if (e.serverErrorPercent > 0) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.error,
        title: 'Linking issues on bank side',
        detail:
            'Server errors (${e.serverErrorPercent.toStringAsFixed(0)}%) reported. '
            'Your link request may fail.',
      ));
    }

    if (e.clientErrorPercent >= 10) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.warning,
        title: 'Linking errors reported',
        detail:
            '${e.clientErrorPercent.toStringAsFixed(0)}% of link attempts are failing. '
            'Ensure your details match your bank records.',
      ));
    }

    if (msgs.isEmpty && e.successPercent >= 95) {
      msgs.add(const FipUserMessage(
        severity: FipMessageSeverity.info,
        title: 'Account linking ready',
        detail: 'Linking is working fine for this bank.',
      ));
    }

    return msgs;
  }

  // ── 3. OTP CONFIRM LINKING ───────────────────────────────────────────────
  // Shown on OTP confirmation screen.

  List<FipUserMessage> confirmLinkingMessages(String fipId) {
    final e = getEventMetric(fipId, FipEvents.userConfirmLinking);
    if (e == null) return [];

    final msgs = <FipUserMessage>[];

    if (e.latencyP99Ms > 10000) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.warning,
        title: 'OTP confirmation may be slow',
        detail:
            'Some requests are taking up to '
            '${(e.latencyP99Ms / 1000).toStringAsFixed(0)}s. Please wait.',
      ));
    }

    if (e.serverErrorPercent >= 5) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.error,
        title: 'OTP confirmation issues',
        detail:
            '${e.serverErrorPercent.toStringAsFixed(0)}% of OTP confirmations are '
            'failing on the bank side. Retry if it doesn\'t go through.',
      ));
    }

    if (e.clientErrorPercent >= 15) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.warning,
        title: 'Check your OTP',
        detail:
            '${e.clientErrorPercent.toStringAsFixed(0)}% of confirmations failed — '
            'make sure you enter the latest OTP.',
      ));
    }

    return msgs;
  }

  // ── 4. CONSENT ───────────────────────────────────────────────────────────

  List<FipUserMessage> consentMessages(String fipId) {
    final e = getEventMetric(fipId, FipEvents.consentPost);
    if (e == null) return [];

    final msgs = <FipUserMessage>[];

    if (e.successPercent == 0) {
      return [
        const FipUserMessage(
          severity: FipMessageSeverity.error,
          title: 'Consent sharing unavailable',
          detail: 'This bank cannot accept consent right now. Try again later.',
        )
      ];
    }

    if (e.clientErrorPercent >= 50) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.error,
        title: 'Consent is failing',
        detail:
            '${e.clientErrorPercent.toStringAsFixed(0)}% of consent requests are failing. '
            'Contact support if this persists.',
      ));
    }

    return msgs;
  }

  // ── 5. FI REQUEST ────────────────────────────────────────────────────────
  // Shown on consent screen — tells user if the bank can even accept a
  // data request before they tap "Give Permission".

  List<FipUserMessage> fiRequestMessages(String fipId) {
    final e = getEventMetric(fipId, FipEvents.fiRequest);
    if (e == null) return [];

    final msgs = <FipUserMessage>[];

    // Full failure — hard block, show alone
    if (e.successPercent == 0) {
      return [
        const FipUserMessage(
          severity: FipMessageSeverity.error,
          title: 'Data requests not working',
          detail:
              'This bank is not accepting data requests right now. '
              'Your consent may go through but data cannot be fetched until this is resolved.',
        )
      ];
    }

    // Server-side failures
    if (e.serverErrorPercent > 0) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.error,
        title: 'Bank server errors on data requests',
        detail:
            '${e.serverErrorPercent.toStringAsFixed(0)}% of data requests are failing '
            'on the bank\'s server. Fetching may not succeed.',
      ));
    }

    // High client error rate — likely a schema/token issue
    if (e.clientErrorPercent >= 30) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.warning,
        title: 'Data request errors reported',
        detail:
            '${e.clientErrorPercent.toStringAsFixed(0)}% of data requests are failing. '
            'Some of your financial data may not load correctly.',
      ));
    }

    // Partial success
    if (e.successPercent < 100 && e.successPercent > 0 && msgs.isEmpty) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.warning,
        title: 'Partial data request success',
        detail:
            'Only ${e.successPercent.toStringAsFixed(0)}% of data requests are '
            'succeeding. Some data may be unavailable.',
      ));
    }

    // Slow P99
    if (e.latencyP99Ms > 5000) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.info,
        title: 'Data request may be slow',
        detail:
            'Some requests are taking up to ${(e.latencyP99Ms / 1000).toStringAsFixed(0)}s. '
            'Please wait after giving permission.',
      ));
    }

    // All clear
    if (msgs.isEmpty) {
      msgs.add(const FipUserMessage(
        severity: FipMessageSeverity.info,
        title: 'Data requests working normally',
        detail: 'This bank is accepting data requests without issues.',
      ));
    }

    return msgs;
  }

  // ── 6. DATA FETCH ────────────────────────────────────────────────────────
  // Shown on consent screen alongside FI request — tells user about the
  // actual data delivery success rate.

  List<FipUserMessage> fetchMessages(String fipId) {
    final e = getEventMetric(fipId, FipEvents.fiFetch);
    if (e == null) return [];

    final msgs = <FipUserMessage>[];

    // Full failure
    if (e.successPercent == 0) {
      return [
        const FipUserMessage(
          severity: FipMessageSeverity.error,
          title: 'Data fetch unavailable',
          detail:
              'This bank is not returning financial data right now. '
              'You can still give consent but data will not be fetched.',
        )
      ];
    }

    // Partial success
    if (e.successPercent < 100) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.warning,
        title: 'Some data may be missing',
        detail:
            'Only ${e.successPercent.toStringAsFixed(0)}% of fetch requests succeed. '
            'Your statements may be incomplete.',
      ));
    }

    // Server errors
    if (e.serverErrorPercent > 0) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.error,
        title: 'Fetch errors on bank side',
        detail:
            '${e.serverErrorPercent.toStringAsFixed(0)}% of fetch requests are failing '
            'on the bank\'s server.',
      ));
    }

    // Slow fetch
    if (e.latencyAvgMs > 500) {
      msgs.add(FipUserMessage(
        severity: FipMessageSeverity.info,
        title: 'Fetching may take a moment',
        detail:
            'Average fetch time is ${e.latencyAvgMs.toStringAsFixed(0)} ms. '
            'Your data will load shortly after consent.',
      ));
    }

    // All clear
    if (msgs.isEmpty) {
      msgs.add(const FipUserMessage(
        severity: FipMessageSeverity.info,
        title: 'Data fetch working normally',
        detail: 'Your financial data should load quickly after consent.',
      ));
    }

    return msgs;
  }

  // ── Combined: FIRequest + FIFetch → used directly on consent screen ───────
  // Returns a merged, de-duplicated, severity-sorted list for both events.
  // Pass this to the consent screen widget — one call does everything.

  List<FipUserMessage> dataReadinessMessages(String fipId) {
    final reqMsgs   = fiRequestMessages(fipId);
    final fetchMsgs = fetchMessages(fipId);

    // Merge both, errors first, then warnings, then info
    final all = [...reqMsgs, ...fetchMsgs];
    all.sort((a, b) => a.severity.index.compareTo(b.severity.index));

    // Suppress the "working normally" info messages if there are real issues
    final hasIssues = all.any(
      (m) => m.severity == FipMessageSeverity.error ||
             m.severity == FipMessageSeverity.warning,
    );
    if (hasIssues) {
      return all
          .where((m) => m.severity != FipMessageSeverity.info)
          .toList();
    }

    return all;
  }

  // ── Misc ──────────────────────────────────────────────────────────────────

  bool get allFipsHealthy =>
      fipMetrics.keys.every((id) => isFipHealthy(id));

  void clear() {
    consentHandleId.value = '';
    fipMetrics.clear();
  }
}
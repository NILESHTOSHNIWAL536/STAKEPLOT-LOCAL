import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/routes/route_insights.dart';
import 'package:get/get.dart';

class UserInsightController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, dynamic> data = <String, dynamic>{}.obs;
  final RxMap<String, String> endpointErrors = <String, String>{}.obs;

  final List<InsightApiEndpoint> endpoints = [
    InsightApiEndpoint("summary", InsightRoutes.summary),
    InsightApiEndpoint("categories", InsightRoutes.categories),
    InsightApiEndpoint("categoryHealth", InsightRoutes.categoryHealth),
    InsightApiEndpoint("merchants", InsightRoutes.merchants),
    InsightApiEndpoint("incomeSources", InsightRoutes.incomeSources),
    InsightApiEndpoint("dailyTrend", InsightRoutes.dailyTrend),
    InsightApiEndpoint("paymentModes", InsightRoutes.paymentModes),
    InsightApiEndpoint("cashVsBank", InsightRoutes.cashVsBank),
    InsightApiEndpoint("timePatterns", InsightRoutes.timePatterns),
    InsightApiEndpoint("recurring", InsightRoutes.recurring),
    InsightApiEndpoint("anomalies", InsightRoutes.anomalies),
    InsightApiEndpoint(
        "largestTransactions", InsightRoutes.largestTransactions),
    InsightApiEndpoint("balanceTrend", InsightRoutes.balanceTrend),
    InsightApiEndpoint("spendVelocity", InsightRoutes.spendVelocity),
    InsightApiEndpoint(
        "upcomingExpensePrediction", InsightRoutes.upcomingExpensePrediction),
    InsightApiEndpoint("actionItems", InsightRoutes.actionItems,
        useQuery: false),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchInsights();
  }

  Future<void> fetchInsights({int days = 60, int limit = 10}) async {
    isLoading.value = true;
    error.value = '';
    endpointErrors.clear();

    final nextData = <String, dynamic>{};

    try {
      final responses = await Future.wait(
        endpoints.map(
            (endpoint) => _fetchEndpoint(endpoint, days: days, limit: limit)),
      );
      nextData.addEntries(responses);
      data.assignAll(nextData);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<MapEntry<String, dynamic>> _fetchEndpoint(
    InsightApiEndpoint endpoint, {
    required int days,
    required int limit,
  }) async {
    final url = endpoint.useQuery
        ? InsightRoutes.withQuery(endpoint.url, days: days, limit: limit)
        : endpoint.url;

    try {
      final response = await getDataApiCall(url);
      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        endpointErrors[endpoint.key] = 'Invalid JSON response';
        return MapEntry(endpoint.key, null);
      }

      if (!getFlagOfResponse(response)) {
        endpointErrors[endpoint.key] =
            '${response.statusCode}: ${_shortBody(response.body)}';
        return MapEntry(endpoint.key, null);
      }

      if (decoded is Map && decoded.containsKey('data')) {
        return MapEntry(endpoint.key, decoded['data']);
      }

      return MapEntry(endpoint.key, decoded);
    } catch (e) {
      endpointErrors[endpoint.key] = e.toString();
      return MapEntry(endpoint.key, null);
    }
  }

  double numValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String money(dynamic value) {
    final amount = numValue(value);
    if (amount >= 100000) return 'INR ${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return 'INR ${(amount / 1000).toStringAsFixed(1)}K';
    return 'INR ${amount.toStringAsFixed(0)}';
  }

  List<dynamic> list(String key) => data[key] is List ? data[key] as List : [];

  Map<String, dynamic> map(String key) {
    return data[key] is Map
        ? Map<String, dynamic>.from(data[key])
        : <String, dynamic>{};
  }

  String _shortBody(String body) {
    if (body.length <= 160) return body;
    return '${body.substring(0, 160)}...';
  }
}

class InsightApiEndpoint {
  const InsightApiEndpoint(this.key, this.url, {this.useQuery = true});

  final String key;
  final String url;
  final bool useQuery;
}

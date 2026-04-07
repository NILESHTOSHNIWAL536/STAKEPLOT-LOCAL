import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';

import '../finance_screen/finanace_dashboard/reserve.dart';
import '../routes/route_transactions.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

final class ApiFailure<T> extends ApiResult<T> {
  final String message;
  const ApiFailure(this.message);
}

class ReserveApiService {
  // Replace with your real base URL or inject via constructor / DI.
  




  static Future<ApiResult<Map<String, dynamic>>> createReserve(
    ReserveState state,
  ) async {
    final payload = state.toJson();

    _logPayload(payload); // dev-only debug output

    try {
      final response = await postDataApiCall(
       
        BankTransactionRoutes.createReserve,
       
        payload,
      );  

      if (getFlagOfResponse(response)) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiSuccess(body);
      }

      return ApiFailure(
        'Server error ${response.statusCode}:\n${response.body}',
      );
    } catch (e) {
      return ApiFailure('Network error:\n$e');
    }
  }
static Future<ApiResult<Map<String, dynamic>>> postDaysForSuggestedAmount(
  String url,
  Map<String, dynamic> payload,
) async {
  _logPayload(payload);

  try {
    final response = await postDataApiCall(
      url,
      payload,
    );

    if (getFlagOfResponse(response)) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiSuccess(body);
    }

    return ApiFailure(
      'Server error ${response.statusCode}:\n${response.body}',
    );
  } catch (e) {
    return ApiFailure('Network error:\n$e');
  }
}

static Future<ApiResult<Map<String, dynamic>>> getSuggestedAmount(
  String url,
) async {
  try {
    final response = await getDataApiCall(url);
    if (getFlagOfResponse(response)) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiSuccess(body);
    }
    return ApiFailure(
      'Server error ${response.statusCode}:\n${response.body}',
    );
  } catch (e) {
    return ApiFailure('Network error:\n$e');
  }
}
  /// Prints the full payload to the debug console (no-op in release mode).
  static void _logPayload(Map<String, dynamic> p) {
    debugPrint('========== RESERVE PAYLOAD ==========');
    p.forEach((k, v) => debugPrint('  $k: $v'));
    debugPrint('=====================================');
  }
}

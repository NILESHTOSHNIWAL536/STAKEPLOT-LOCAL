import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import '../finance_screen/finanace_dashboard/reserve.dart';
import '../routes/index_route.dart';

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
  static Future<ApiResult<Map<String, dynamic>>> createReserve(
    ReserveState state,
  ) async {
    final payload = state.toJson();
    _logPayload(payload);
    try {
      final response = await postDataApiCall(
        API.BankApiUrl + "/reserve",
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

  static Future<ApiResult<Map<String, dynamic>>> getReserve(
    ReserveState state,
  ) async {
    try {
      final response = await getDataApiCall(
        API.BankApiUrl + "/reserve",
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

  static Future<ApiResult<Map<String, dynamic>>> getSuggestedReserve(
    ReserveState state,
    int durationDays,
  ) async {
    final payload = {
      'durationDays': durationDays, // ✅ only this
    };

    _logPayload(payload);

    try {
      final response = await postDataApiCall(
        API.BankApiUrl + "/reserve/suggest",
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

  /// Prints the full payload to the debug console (no-op in release mode).
  static void _logPayload(Map<String, dynamic> p) {
    p.forEach((k, v) => debugPrint('  $k: $v'));
  }
}

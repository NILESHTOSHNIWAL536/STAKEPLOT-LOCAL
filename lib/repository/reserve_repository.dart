import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';

import '../finance_screen/finanace_dashboard/reserve.dart';

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
  static const String _baseUrl = '';

  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// POST /api/reserves
  /// Returns [ApiSuccess] with the decoded response body on 200/201,
  /// or [ApiFailure] with a human-readable error message otherwise.
  static Future<ApiResult<Map<String, dynamic>>> createReserve(
    ReserveState state,
  ) async {
    final payload = state.toJson();

    _logPayload(payload); // dev-only debug output

    try {
      final response = await postDataApiCall(
       
        '$_baseUrl/api/reserves',
       
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

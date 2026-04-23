import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:flutter_application_code_stakeplot/services/secure_storage.dart';

class ReferralRepository {
  static const String _incomingReferralCodeKey = 'incoming_referral_code';
  static const String _validatedReferralCodeKey = 'validated_referral_code';
  static const String _myShareReferralCodeKey = 'my_share_referral_code';

  static String normalizeCode(String code) => code.trim().toUpperCase();

  static Future<void> saveIncomingReferralCode(String code) async {
    final normalizedCode = normalizeCode(code);
    if (normalizedCode.isEmpty) return;

    await SecureStorageService().setString(_incomingReferralCodeKey, normalizedCode);
  }

  static Future<String?> getIncomingReferralCode() async {
    final code = await SecureStorageService().read(_incomingReferralCodeKey);
    if (code == null || code.trim().isEmpty) return null;
    return normalizeCode(code);
  }

  static Future<void> saveValidatedReferralCode(String code) async {
    final normalizedCode = normalizeCode(code);
    if (normalizedCode.isEmpty) return;

    await SecureStorageService().setString(_validatedReferralCodeKey, normalizedCode);
  }

  static Future<String?> getValidatedReferralCode() async {
    final code = await SecureStorageService().read(_validatedReferralCodeKey);
    if (code == null || code.trim().isEmpty) return null;
    return normalizeCode(code);
  }

  static Future<void> saveMyShareReferralCode(String code) async {
    final normalizedCode = normalizeCode(code);
    if (normalizedCode.isEmpty) return;

    await SecureStorageService().setString(_myShareReferralCodeKey, normalizedCode);
  }

  static Future<String?> getMyShareReferralCode() async {
    final code = await SecureStorageService().read(_myShareReferralCodeKey);
    if (code == null || code.trim().isEmpty) return null;
    return normalizeCode(code);
  }

  static Future<void> clearIncomingReferralCode() async {
    await SecureStorageService().delete(_incomingReferralCodeKey);
  }

  static Future<void> clearValidatedReferralCode() async {
    await SecureStorageService().delete(_validatedReferralCodeKey);
  }

  static Future<void> clearMyShareReferralCode() async {
    await SecureStorageService().delete(_myShareReferralCodeKey);
  }

  static Future<void> clearAllReferralCodes() async {
    await SecureStorageService().delete(_incomingReferralCodeKey);
    await SecureStorageService().delete(_validatedReferralCodeKey);
  }

  static Future<Map<String, dynamic>> getShareReferralCode() async {
    final response = await getDataApiCall(ReferralRoutes.shareCode);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(_extractMessage(body, 'Unable to fetch referral share code'));
    }

    final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final code = data['code']?.toString();

    if (code != null && code.trim().isNotEmpty) {
      await saveMyShareReferralCode(code);
    }

    return data;
  }

  static Future<Map<String, dynamic>> validateReferralCode(String code) async {
    final response = await postDataApiCall(ReferralRoutes.validate, {
      'code': normalizeCode(code),
    });

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(_extractMessage(body, 'Unable to validate referral code'));
    }

    return (body['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> applyReferralCode(String code) async {
    final response = await postDataApiCall(ReferralRoutes.apply, {
      'code': normalizeCode(code),
    });

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(_extractMessage(body, 'Unable to apply referral code'));
    }

    return (body['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
  }

  static Future<bool> applySavedReferralCodeIfAvailable() async {
    final code = await getValidatedReferralCode();
    if (code == null || code.isEmpty) return false;

    try {
      await applyReferralCode(code);
      await clearAllReferralCodes();
      return true;
    } catch (error) {
      appLog('Referral apply failed: $error');
      await clearAllReferralCodes();
      return false;
    }
  }

  static Future<bool> isMyOwnReferralCode(String code) async {
    final myCode = await getMyShareReferralCode();
    if (myCode == null || myCode.isEmpty) return false;
    return normalizeCode(code) == myCode;
  }

  static String _extractMessage(Map<String, dynamic> body, String fallback) {
    final error = body['error'];

    if (error is Map && error['explanation'] is String) {
      return error['explanation'] as String;
    }

    if (error is String && error.trim().isNotEmpty) {
      return error;
    }

    if (body['message'] is String && (body['message'] as String).trim().isNotEmpty) {
      return body['message'] as String;
    }

    return fallback;
  }
}

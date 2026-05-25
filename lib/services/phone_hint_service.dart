import 'dart:io';

import 'package:flutter/services.dart';

/// Wraps two platform channels:
///   1. PHONE_HINT_CHANNEL  — triggers Google's phone-number picker (Android only)
///   2. SMS_OTP_CHANNEL     — streams OTP codes extracted from SMS (Android only)
///
/// Both use no sensitive permissions and are Play Store safe.
class PhoneHintService {
  static const _phoneChannel = MethodChannel('com.stakeplot.pfa/phone_hint');
  static const _smsChannel = EventChannel('com.stakeplot.pfa/sms_otp');

  static bool get _android => Platform.isAndroid;

  /// Shows Google Identity's phone-number picker bottom sheet.
  /// Returns the 10-digit number the user tapped, or null if dismissed / unavailable.
  static Future<String?> requestPhoneHint() async {
    if (!_android) return null;
    try {
      return await _phoneChannel.invokeMethod<String>('requestPhoneHint');
    } on PlatformException {
      return null;
    }
  }

  /// Stream that emits the first 6-digit OTP found in each incoming SMS.
  /// The 5-minute SMS Retriever window starts when this stream is listened to.
  /// Cancel the subscription to stop the receiver.
  static Stream<String> get smsOtpStream {
    if (!_android) return const Stream.empty();
    return _smsChannel
        .receiveBroadcastStream()
        .map((event) => event.toString())
        .where((otp) => otp.isNotEmpty);
  }
}

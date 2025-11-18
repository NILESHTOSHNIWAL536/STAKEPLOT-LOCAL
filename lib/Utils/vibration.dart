import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:vibration/vibration.dart';



 


  Future<void> vibrateScreen() async {
    // iOS + Android basic haptic
    HapticFeedback.mediumImpact();

    // Android: strong vibration pattern
    if (Platform.isAndroid) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(
          pattern: [0, 60, 40, 60, 40, 40],  // strong multi-pulse
          intensities: [128, 255, 180, 255], // max strength
        );
      }
    } else {
      // iOS fallback: strongest haptic
      HapticFeedback.heavyImpact();
    }
  }

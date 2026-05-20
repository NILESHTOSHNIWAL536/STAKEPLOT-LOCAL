import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_offsetAnimation.value, 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}

Future<void> vibrateForSnack() async {
  try {
    HapticFeedback.mediumImpact();
    if (kIsWeb) {
      return;
    }

    if (Platform.isAndroid && (await Vibration.hasVibrator() ?? false)) {
      try {
        await Vibration.vibrate(
          pattern: [0, 60, 40, 60, 40, 40],
          intensities: [180, 255, 200, 230],
        );
      } catch (_) {
        await Vibration.vibrate(pattern: [0, 60, 40, 60, 40, 40]);
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  } catch (_) {}
}

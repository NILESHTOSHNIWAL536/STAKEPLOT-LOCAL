 import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/userSignInAndSignUp/signin.dart';
import 'dart:math' as math;


// Widget buildBottomWave(context) {
//     return CustomPaint(
//       size: Size(MediaQuery.of(context).size.width, 100),
//       painter: WavePainter(),
//     );
// }

 Widget buildBottomWaves(context) {
    return SizedBox(
      height: 250,
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.width, 250),
        painter: DetailedWavePainter(),
      ),
    );
  }


class DetailedWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Create multiple detailed wave lines
    for (int i = 0; i < 12; i++) {
      final path = Path();
      final yOffset = i * 12.0;
      final amplitude = 15.0 + (i * 2.0); // Increasing amplitude
      final frequency = 0.8 + (i * 0.1); // Varying frequency
      
      path.moveTo(0, size.height - 100 + yOffset);
      
      for (double x = 0; x <= size.width; x += 2) {
        final y = size.height - 100 + yOffset + 
                 (amplitude * math.sin((x / size.width) * frequency * 2 * math.pi));
        path.lineTo(x, y);
      }
      
      // Adjust opacity for depth effect
      final wavePaint = Paint()
        ..color = Colors.white.withOpacity(0.08 + (i * 0.01))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + (i * 0.1);
      
      canvas.drawPath(path, wavePaint);
    }

    // Add some additional curved lines for more detail
    for (int j = 0; j < 8; j++) {
      final path = Path();
      final yBase = size.height - 60 + (j * 8.0);
      final amplitude = 20.0 + (j * 3.0);
      
      path.moveTo(0, yBase);
      
      // Create more complex wave pattern
      for (double x = 0; x <= size.width; x += 3) {
        final wave1 = amplitude * math.sin((x / size.width) * 3 * math.pi);
        final wave2 = (amplitude * 0.5) * math.sin((x / size.width) * 5 * math.pi);
        final y = yBase + wave1 + wave2;
        path.lineTo(x, y);
      }
      
      final detailPaint = Paint()
        ..color = Colors.white.withOpacity(0.06 + (j * 0.008))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      
      canvas.drawPath(path, detailPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
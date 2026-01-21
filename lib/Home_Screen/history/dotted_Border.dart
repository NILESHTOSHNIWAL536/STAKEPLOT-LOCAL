import 'package:flutter/material.dart';

import '../../Constants/core/app_padding_sizes.dart';

class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final double dashWidth;
  final double dashHeight;
  final double space;
  final Color color;
  final EdgeInsets padding;
  final double cornerRadius;

  const DottedBorderBox({
    super.key,
    required this.child,
    this.dashWidth = 4,
    this.dashHeight = 2,
    this.space = 3,
    this.color = Colors.black,
    this.padding = const EdgeInsets.all(AppSizes.p12),
    this.cornerRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(
        dashWidth: 7,
        dashHeight: 1,
        space: 5,
        color: color,
        cornerRadius: cornerRadius,
      ),
      child: Container(
        padding: padding,
        child: child,
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final double dashWidth;
  final double dashHeight;
  final double space;
  final Color color;
  final double cornerRadius;

  DottedBorderPainter({
    required this.dashWidth,
    required this.dashHeight,
    required this.space,
    required this.color,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = dashHeight
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = _createRoundedRectPath(size);
    _drawDottedPath(canvas, paint, path);
  }

  Path _createRoundedRectPath(Size size) {
    final rect = Rect.fromLTWH(
      dashHeight / 2,
      dashHeight / 2,
      size.width - dashHeight,
      size.height - dashHeight,
    );
    
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)));
  }

  void _drawDottedPath(Canvas canvas, Paint paint, Path path) {
    final pathMetrics = path.computeMetrics();
    
    for (final pathMetric in pathMetrics) {
      double distance = 0;
      
      while (distance < pathMetric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = pathMetric.extractPath(
          distance,
          nextDistance > pathMetric.length ? pathMetric.length : nextDistance,
        );
        
        canvas.drawPath(extractPath, paint);
        distance = nextDistance + space;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DottedBorderPainter &&
        other.dashWidth == dashWidth &&
        other.dashHeight == dashHeight &&
        other.space == space &&
        other.color == color &&
        other.cornerRadius == cornerRadius;
  }

  @override
  int get hashCode {
    return Object.hash(dashWidth, dashHeight, space, color, cornerRadius);
  }
}



class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final double radius;

  DashedBorderPainter({
    this.color = const Color(0xFF434273),
    this.strokeWidth = 1,
    this.dashLength = 18,
    this.dashGap = 3,
    this.radius = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        dashPath.addPath(
          metric.extractPath(distance, next.clamp(0.0, metric.length)),
          Offset.zero,
        );
        distance = next + dashGap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DottedDivider extends StatelessWidget {
  final double height;
  final double dashWidth;
  final double dashSpacing;
  final Color color;

  const DottedDivider({
    Key? key,
    this.height = 1,
    this.dashWidth = 5,
    this.dashSpacing = 3,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _DottedLinePainter(
          dashWidth: dashWidth,
          dashSpacing: dashSpacing,
          color: color,
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashSpacing;
  final Color color;

  _DottedLinePainter({
    required this.dashWidth,
    required this.dashSpacing,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

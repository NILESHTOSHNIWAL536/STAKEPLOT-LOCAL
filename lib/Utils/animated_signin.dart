import 'package:flutter/material.dart';
import 'dart:ui';


class CurveItemsDemo extends StatefulWidget {
  @override
  _CurveItemsDemoState createState() => _CurveItemsDemoState();
}

class _CurveItemsDemoState extends State<CurveItemsDemo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<Path> _paths;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: false);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Define three paths for the three items
    _paths = [
      makeBezierPath(Offset(80, 0), Offset(130, 200), Offset(70, 350)),
      makeBezierPath(Offset(150, 0), Offset(180, 220), Offset(140, 350)),
      makeBezierPath(Offset(220, 0), Offset(240, 180), Offset(210, 350)),
    ];
  }

  Path makeBezierPath(Offset start, Offset control, Offset end) {
    Path path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    return path;
  }

  Offset pointOnPath(Path path, double t) {
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * t);
    return tangent?.position ?? Offset.zero;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildAnimatedItem(IconData icon, Path path) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        final pos = pointOnPath(path, _animation.value);
        return Positioned(
          left: pos.dx - 16,
          top: pos.dy - 16,
          child: Icon(icon, size: 32, color: Colors.indigo),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Box at the bottom
          Positioned(
            left: 60,
            top: 330,
            child: Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.indigo[200],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Animated items and paths
          ...List.generate(3, (i) {
            IconData icon;
            if (i == 0) icon = Icons.restaurant_menu;
            else if (i == 1) icon = Icons.block;
            else icon = Icons.accessibility;

            return buildAnimatedItem(icon, _paths[i]);
          }),
          // Curved lines
          ..._paths.map((path) => CustomPaint(
            painter: CurvePainter(path),
            size: Size(300, 400),
          )),
        ],
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final Path path;
  CurvePainter(this.path);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.indigo.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

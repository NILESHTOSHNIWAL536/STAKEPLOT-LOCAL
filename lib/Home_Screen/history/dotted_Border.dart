// // import 'package:flutter/material.dart';

// // class DottedBorderBox extends StatelessWidget {
// //   final Widget child;
// //   final double dashWidth;
// //   final double dashHeight;
// //   final double space;
// //   final Color color;

// //   const DottedBorderBox({
// //     super.key,
// //     required this.child,
// //     this.dashWidth = 3,
// //     this.dashHeight = 1,
// //     this.space = 1,
// //     this.color = Colors.black,
// //   });

// //   List<Widget> _buildHorizontalDashes(double width) {
// //     int count = (width / (dashWidth + space)).floor();
// //     return List.generate(count, (index) {
// //       return Container(
// //         width: dashWidth,
// //         height: dashHeight,
// //         color: color,
// //         margin: EdgeInsets.only(right: index == count - 1 ? 0 : space),
// //       );
// //     });
// //   }

// //   List<Widget> _buildVerticalDashes(double height) {
// //     int count = (height / (dashWidth + space)).floor();
// //     return List.generate(count, (index) {
// //       return Container(
// //         width: dashHeight,
// //         height: dashWidth,
// //         color: color,
// //         margin: EdgeInsets.only(bottom: index == count - 1 ? 0 : space),
// //       );
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       // Adds tight padding so border is close to text
// //       padding: const EdgeInsets.all(2),
// //       child: Stack(
// //         children: [
// //           child,
// //           Positioned.fill(
// //             child: LayoutBuilder(
// //               builder: (context, constraints) {
// //                 double width = constraints.maxWidth;
// //                 double height = constraints.maxHeight;

// //                 return Stack(
// //                   children: [
// //                     // Top
// //                     Positioned(
// //                       top: 0,
// //                       left: 0,
// //                       right: 0,
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.start,
// //                         children: _buildHorizontalDashes(width),
// //                       ),
// //                     ),

// //                     // Bottom
// //                     Positioned(
// //                       bottom: 0,
// //                       left: 0,
// //                       right: 0,
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.start,
// //                         children: _buildHorizontalDashes(width),
// //                       ),
// //                     ),

// //                     // Left
// //                     Positioned(
// //                       top: 0,
// //                       bottom: 0,
// //                       left: 0,
// //                       child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.start,
// //                         children: _buildVerticalDashes(height),
// //                       ),
// //                     ),

// //                     // Right
// //                     Positioned(
// //                       top: 0,
// //                       bottom: 0,
// //                       right: 0,
// //                       child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.start,
// //                         children: _buildVerticalDashes(height),
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';

// class DottedBorderBox extends StatelessWidget {
//   final Widget child;
//   final double dashWidth;
//   final double dashHeight;
//   final double space;
//   final Color color;
//   final EdgeInsets padding;

//   const DottedBorderBox({
//     super.key,
//     required this.child,
//     this.dashWidth = 4,
//     this.dashHeight = 2,
//     this.space = 3,
//     this.color = Colors.black,
//     this.padding = const EdgeInsets.all(8),
//   });

//   List<Widget> _buildHorizontalDashes(double width) {
//     if (width <= 0) return [];
    
//     int count = (width / (dashWidth + space)).floor();
//     List<Widget> dashes = [];
    
//     for (int i = 0; i < count; i++) {
//       dashes.add(
//         Container(
//           width: dashWidth,
//           height: dashHeight,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(dashHeight / 2),
//           ),
//         ),
//       );
      
//       if (i < count - 1) {
//         dashes.add(SizedBox(width: space));
//       }
//     }
    
//     return dashes;
//   }

//   List<Widget> _buildVerticalDashes(double height) {
//     if (height <= 0) return [];
    
//     int count = (height / (dashWidth + space)).floor();
//     List<Widget> dashes = [];
    
//     for (int i = 0; i < count; i++) {
//       dashes.add(
//         Container(
//           width: dashHeight,
//           height: dashWidth,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(dashHeight / 2),
//           ),
//         ),
//       );
      
//       if (i < count - 1) {
//         dashes.add(SizedBox(height: space));
//       }
//     }
    
//     return dashes;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: DottedBorderPainter(
//         dashWidth: dashWidth,
//         dashHeight: dashHeight,
//         space: space,
//         color: color,
//       ),
//       child: Container(
//         padding: padding,
//         child: child,
//       ),
//     );
//   }
// }

// class DottedBorderPainter extends CustomPainter {
//   final double dashWidth;
//   final double dashHeight;
//   final double space;
//   final Color color;

//   DottedBorderPainter({
//     required this.dashWidth,
//     required this.dashHeight,
//     required this.space,
//     required this.color,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = dashHeight
//       ..strokeCap = StrokeCap.round;

//     // Draw top border
//     _drawHorizontalDashes(canvas, paint, 0, 0, size.width);
    
//     // Draw bottom border
//     _drawHorizontalDashes(canvas, paint, 0, size.height - dashHeight, size.width);
    
//     // Draw left border
//     _drawVerticalDashes(canvas, paint, 0, 0, size.height);
    
//     // Draw right border
//     _drawVerticalDashes(canvas, paint, size.width - dashHeight, 0, size.height);
//   }

//   void _drawHorizontalDashes(Canvas canvas, Paint paint, double startX, double y, double width) {
//     double currentX = startX;
    
//     while (currentX < startX + width) {
//       double endX = currentX + dashWidth;
//       if (endX > startX + width) {
//         endX = startX + width;
//       }
      
//       canvas.drawLine(
//         Offset(currentX, y + dashHeight / 2),
//         Offset(endX, y + dashHeight / 2),
//         paint,
//       );
      
//       currentX += dashWidth + space;
//     }
//   }

//   void _drawVerticalDashes(Canvas canvas, Paint paint, double x, double startY, double height) {
//     double currentY = startY;
    
//     while (currentY < startY + height) {
//       double endY = currentY + dashWidth;
//       if (endY > startY + height) {
//         endY = startY + height;
//       }
      
//       canvas.drawLine(
//         Offset(x + dashHeight / 2, currentY),
//         Offset(x + dashHeight / 2, endY),
//         paint,
//       );
      
//       currentY += dashWidth + space;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return oldDelegate != this;
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is DottedBorderPainter &&
//         other.dashWidth == dashWidth &&
//         other.dashHeight == dashHeight &&
//         other.space == space &&
//         other.color == color;
//   }

//   @override
//   int get hashCode {
//     return Object.hash(dashWidth, dashHeight, space, color);
//   }
// }



import 'package:flutter/material.dart';


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
    this.padding = const EdgeInsets.all(12),
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
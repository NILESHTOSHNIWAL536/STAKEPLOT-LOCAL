import 'package:flutter/material.dart';

class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final double dashWidth;
  final double dashHeight;
  final double space;
  final Color color;

  const DottedBorderBox({
    super.key,
    required this.child,
    this.dashWidth = 3,
    this.dashHeight = 1,
    this.space = 1,
    this.color = Colors.black,
  });

  List<Widget> _buildHorizontalDashes(double width) {
    int count = (width / (dashWidth + space)).floor();
    return List.generate(count, (index) {
      return Container(
        width: dashWidth,
        height: dashHeight,
        color: color,
        margin: EdgeInsets.only(right: index == count - 1 ? 0 : space),
      );
    });
  }

  List<Widget> _buildVerticalDashes(double height) {
    int count = (height / (dashWidth + space)).floor();
    return List.generate(count, (index) {
      return Container(
        width: dashHeight,
        height: dashWidth,
        color: color,
        margin: EdgeInsets.only(bottom: index == count - 1 ? 0 : space),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Adds tight padding so border is close to text
      padding: const EdgeInsets.all(2),
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;
                double height = constraints.maxHeight;

                return Stack(
                  children: [
                    // Top
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _buildHorizontalDashes(width),
                      ),
                    ),

                    // Bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _buildHorizontalDashes(width),
                      ),
                    ),

                    // Left
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _buildVerticalDashes(height),
                      ),
                    ),

                    // Right
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _buildVerticalDashes(height),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

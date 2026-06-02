import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResponsiveSvg extends StatelessWidget {
  final String asset;

  /// Percentage of screen width
  final double widthFactor;

  /// Percentage of screen height
  final double? heightFactor;

  final BoxFit fit;

  const ResponsiveSvg({
    super.key,
    required this.asset,
    this.widthFactor = 0.4,
    this.heightFactor,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SvgPicture.asset(
      asset,
      width: size.width / widthFactor,
      height: heightFactor != null
          ? size.height / heightFactor!
          : null,
      fit: fit,
    );
  }
}

class AppAssets extends StatelessWidget {
  final String asset;
  final double? size;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppAssets({
    super.key,
    required this.asset,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: width ?? size,
      height: height ?? size,
      fit: fit,
    );
  }
}

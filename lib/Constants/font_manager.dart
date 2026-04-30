import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class FontManager {
  TextStyle getTextStyle(
    BuildContext context, {
    Color? color,
    FontWeight lWeight = FontWeight.normal,
    lineHeight = 1.0,
    maxLines = 2,
    textDirection = TextDirection.ltr,
    textAlign = TextAlign.start,
    FontStyle lFontStyle = FontStyle.normal,
    softWrap = false,
    Color? decorationColor,
    double fontSize = 18.0,
    decoration = TextDecoration.none,
    letterSpacing = 0.24,
    TextOverflow overflow = TextOverflow.visible,
    decorationThickness = 0.0,
    decorationStyle = TextDecorationStyle.solid,
    String? fontFamily,
  }) {
    // Inherit text color from the ambient theme when no explicit color is given
    final resolvedColor = color ?? Theme.of(context).textTheme.bodyMedium?.color;
    final style = GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: lWeight,
      height: lineHeight,
      fontStyle: lFontStyle,
      color: resolvedColor,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
      decorationStyle: decorationStyle,
    );

    return fontFamily == null ? style : style.copyWith(fontFamily: fontFamily);
  }
}
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class FontManager {
//   static const double _baseWidth = 375; // Figma design width

//   double _scale(BuildContext context, double size) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     double scaled = size * (screenWidth / _baseWidth);

//     // Clamp → prevents text from becoming too big/small
//     return scaled.clamp(size * 0.9, size * 1.3);

//   }

//   TextStyle getTextStyle(
//     BuildContext context, {
//     Color color = Colors.black,
//     FontWeight lWeight = FontWeight.normal,
//     double lineHeight = 1.0,
//     FontStyle lFontStyle = FontStyle.normal,
//     double fontSize = 18.0,
//     double letterSpacing = 0.24,
//     TextDecoration decoration = TextDecoration.none,
//     Color decorationColor = Colors.black,
//     double decorationThickness = 0.0,
//     TextDecorationStyle decorationStyle = TextDecorationStyle.solid,
//     TextOverflow overflow = TextOverflow.visible,
//     int? maxLines,
//     TextAlign textAlign = TextAlign.start,
//     TextDirection textDirection = TextDirection.ltr,
//     bool softWrap = false,
//   }) {
//     return GoogleFonts.roboto(
//       fontSize: _scale(context, fontSize), // ✅ automatic scaling
//       fontWeight: lWeight,
//       height: lineHeight,
//       fontStyle: lFontStyle,
//       color: color,
//       letterSpacing: letterSpacing,
//       decoration: decoration,
//       decorationColor: decorationColor,
//       decorationThickness: decorationThickness,
//       decorationStyle: decorationStyle,

//     );
//   }
// }
class FontManager2 {
  TextStyle getTextStyle(
    BuildContext context, {
    Color? color,
    FontWeight lWeight = FontWeight.normal,
    lineHeight = 1.0,
    maxLines = 2,
    textDirection = TextDirection.ltr,
    textAlign = TextAlign.start,
    FontStyle lFontStyle = FontStyle.normal,
    softWrap = false,
    Color? decorationColor,
    double fontSize = 18.0,
    decoration = TextDecoration.none,
    letterSpacing = 0.0,
    TextOverflow overflow = TextOverflow.visible,
    decorationThickness = 0.0,
    decorationStyle = TextDecorationStyle.solid,
    String? fontFamily,
  }) {
    final resolvedColor = color ?? Theme.of(context).textTheme.bodyMedium?.color;
    final style = GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: lWeight,
      height: lineHeight,
      fontStyle: lFontStyle,
      color: resolvedColor,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
      decorationStyle: decorationStyle,
    );

    return fontFamily == null ? style : style.copyWith(fontFamily: fontFamily);
  }
}

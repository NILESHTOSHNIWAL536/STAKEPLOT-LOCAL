import 'package:flutter/material.dart';
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
      fontSize: fontSize.toDouble(),
      fontWeight: lWeight,
      height: lineHeight.toDouble(),
      fontStyle: lFontStyle,
      color: resolvedColor,
      letterSpacing: letterSpacing.toDouble(),
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
      decorationStyle: decorationStyle,
    );

    return fontFamily == null ? style : style.copyWith(fontFamily: fontFamily);
  }
}

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

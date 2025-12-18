import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class FontManager {
  TextStyle getTextStyle(
    BuildContext context, {
    Color color = Colors.black,
    FontWeight lWeight = FontWeight.normal,
    lineHeight = 1.0,
    maxLines = 2,
    textDirection = TextDirection.ltr,
    textAlign = TextAlign.start,
    FontStyle lFontStyle = FontStyle.normal,
    softWrap = false,
    decorationColor = Colors.black,
    double fontSize = 18.0,
    decoration = TextDecoration.none,
    letterSpacing = 0.24,
    TextOverflow overflow = TextOverflow.visible,
    decorationThickness = 0.0,
    decorationStyle = TextDecorationStyle.solid,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: lWeight,
      height: lineHeight,
      fontStyle: lFontStyle,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
      decorationStyle: decorationStyle,
    );
  }
}

class FontManager2 {
  TextStyle getTextStyle(
    BuildContext context, {
    Color color = Colors.black,
    FontWeight lWeight = FontWeight.normal,
    lineHeight = 1.0,
    maxLines = 2,
    textDirection = TextDirection.ltr,
    textAlign = TextAlign.start,
    FontStyle lFontStyle = FontStyle.normal,
    softWrap = false,
    decorationColor = Colors.black,
    double fontSize = 18.0,
    decoration = TextDecoration.none,
    letterSpacing = 0.0,
    TextOverflow overflow = TextOverflow.visible,
    decorationThickness = 0.0,
    decorationStyle = TextDecorationStyle.solid,
    
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      
      fontWeight: lWeight,
      height: lineHeight,
      fontStyle: lFontStyle,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
      decorationStyle: decorationStyle,
    );
  }
}

import 'package:flutter/material.dart';

Map<String, dynamic> getJsonBodyObj(
    String name,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    TextEditingController controller,
    [bool flag = true, String symbol = "₹"]) {
  return {
    'name': name,
    'value': value,
    'min': min,
    'max': max,
    'onChanged': onChanged,
    'controller': controller,
    'symbol': symbol,
    'flag': flag,
  };
}
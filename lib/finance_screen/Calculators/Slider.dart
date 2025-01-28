


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

Widget buildSlider(String label, double value, double min, double max,Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ₹${value.toStringAsFixed(0)}'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 100,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
          inactiveColor: AppColors.uncoloredPie,
        ),
      ],
    );
}
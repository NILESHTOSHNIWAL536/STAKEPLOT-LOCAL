import 'package:flutter/material.dart';

class AppComponentSizes {
  static late double screenWidth;
  static late double screenHeight;

  // Heights → screenHeight / X
  static late double h1_14;
  static late double h1_1;
  static late double h1_23;
  static late double h2;
  static late double h2_1;
  static late double h2_2;
  static late double h2_3;
  static late double h2_4;
  static late double h2_5;

  static late double h3;
  static late double h3_2;
  static late double h3_3;
  static late double h3_4;
  static late double h3_5;
  static late double h3_6;

  static late double h4;
  static late double h4_5;

  static late double h5;
  static late double h6;
  static late double h7;
  static late double h8;
  static late double h10;
  static late double h12;
  static late double h14;
  static late double h16;
  static late double h20;
  static late double h25;
  static late double h30;
  static late double h36;
  static late double h40;

  // Widths → screenWidth / X
  static late double w1_1;
  static late double w1_4;
  static late double w2;
  static late double w2_5;
  static late double w3;
  static late double w3_5;
  static late double w4;
  static late double w5;
  static late double w6;
  static late double w8;
  static late double w10;

  // Radius (fixed)
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r24 = 24;

  // Icons (fixed)
  static const double i16 = 16;
  static const double i20 = 20;
  static const double i24 = 24;
  static const double i28 = 28;
  static const double i32 = 32;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;

    screenWidth = size.width;
    screenHeight = size.height;

    // Heights (integer divisors)
    h1_14 = screenHeight / 1.14;
    h1_1 = screenHeight / 1.1;
    h1_23 = screenHeight / 1.23;
    h2 = screenHeight / 2;
    h3 = screenHeight / 3;
    h4 = screenHeight / 4;
    h5 = screenHeight / 5;
    h6 = screenHeight / 6;
    h7 = screenHeight / 7;
    h8 = screenHeight / 8;
    h10 = screenHeight / 10;
    h12 = screenHeight / 12;
    h14 = screenHeight / 14;
    h16 = screenHeight / 16;
    h20 = screenHeight / 20;
    h25 = screenHeight / 25;
    h30 = screenHeight / 30;
    h36 = screenHeight / 36;
    h40 = screenHeight / 40;

    // Heights (decimal divisors)
    h2_1 = screenHeight / 2.1;
    h2_2 = screenHeight / 2.2;
    h2_3 = screenHeight / 2.3;
    h2_4 = screenHeight / 2.4;
    h2_5 = screenHeight / 2.5;
    h3_2 = screenHeight / 3.2;
    h3_3 = screenHeight / 3.3;
    h3_4 = screenHeight / 3.4;
    h3_5 = screenHeight / 3.2;
    h3_6 = screenHeight / 3.6;
    h4_5 = screenHeight / 4.5;

    // Widths
    w1_1 = screenWidth / 1.1;
    w1_4 = screenWidth / 1.4;
    w2 = screenWidth / 2;
    w2_5 = screenWidth / 2.5;
    w3 = screenWidth / 3;
    w3_5 = screenWidth / 3.5;
    w4 = screenWidth / 4;
    w5 = screenWidth / 5;
    w6 = screenWidth / 6;
    w8 = screenWidth / 8;
    w10 = screenWidth / 10;
  }
}

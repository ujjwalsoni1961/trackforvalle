import 'dart:math';
import 'package:flutter/material.dart';

class AppColors {
  // Generic Colors
  static Color white = Colors.white;
  static Color bgMain = white;
  static Color bgMainDark = const Color(0xff151515);
  static Color black = const Color(0xff151515);
  static Color grey = const Color(0xff808080);
  static Color greyDark = const Color(0xff262626);
  static Color transparent = Colors.transparent;
  static Color offWhite = const Color(0xfff5f5f5);
  static Color red = Colors.redAccent;

  // Primary & Accent
  static Color primary = const Color(0xff1A1A2E);
  static Color accent = const Color(0xff4B7BF5);
  static Color bgLight = const Color(0xffF5F5F5);

  // Random Light Colors
  static Color getRandomLightColor() {
    Random random = Random();
    int red = 100 + random.nextInt(76);
    int green = 100 + random.nextInt(76);
    int blue = 120 + random.nextInt(86);
    return Color.fromARGB(255, red, green, blue);
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

class AppColors {
  // Generic Colors
  static Color white = Colors.white;
  static Color bgMain = white;
  static Color bgMainDark = black;
  static Color black = const Color(0xff151515);
  static Color grey = const Color(0xff808080);
  static Color greyDark = const Color(0xff262626);
  static Color transparent = Colors.transparent;
  static Color offWhite = const Color(0xfff5f5f5);
  static Color red = Colors.redAccent;
  // Dark Colors

  static Color accent = const Color(0xff027dff);

  // Random Light Colors
  static Color getRandomLightColor() {
    Random random = Random();
    int red = 100 + random.nextInt(76); // Range: 100-175
    int green = 100 + random.nextInt(76); // Range: 100-175
    int blue = 120 + random.nextInt(86); // Range: 120-205
    return Color.fromARGB(255, red, green, blue);
  }
}

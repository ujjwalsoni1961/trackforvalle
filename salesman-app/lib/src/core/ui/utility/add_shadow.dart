import 'package:flutter/material.dart';

extension Tweaks on Widget {
  Widget addShadow({
    double? shadowIntensity, // Intensity of the shadow spread
    Color color = Colors.white,
    BorderRadiusGeometry borderRadius =
        const BorderRadius.all(Radius.circular(16)),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color with opacity
            spreadRadius: shadowIntensity ?? 2.0, // Shadow spread intensity
            blurRadius: (shadowIntensity ?? 4.0) *
                2, // Blur radius proportional to spread
            offset: const Offset(0, 4), // Shadow position offset
          ),
        ],
      ),
      child: this,
    );
  }
}

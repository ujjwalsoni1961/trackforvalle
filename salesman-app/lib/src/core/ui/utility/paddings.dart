import 'package:flutter/material.dart';

extension PaddingExtension on Widget {
  Widget pAll(double padding) => Padding(
        padding: EdgeInsets.all(padding),
        child: this,
      );

  Widget pSymmetric({double? vertical, double? horizontal}) => Padding(
        padding: EdgeInsets.symmetric(
          vertical: vertical ?? 0,
          horizontal: horizontal ?? 0,
        ),
        child: this,
      );

  Widget defaultPadding() => pSymmetric(horizontal: 16, vertical: 8);

  Widget pOnly({
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          left: left ?? 0,
          right: right ?? 0,
          top: top ?? 0,
          bottom: bottom ?? 0,
        ),
        child: this,
      );

  Widget pRight(double padding) => Padding(
        padding: EdgeInsets.only(right: padding),
        child: this,
      );

  Widget pLeft(double padding) => Padding(
        padding: EdgeInsets.only(left: padding),
        child: this,
      );

  Widget pTop(double padding) => Padding(
        padding: EdgeInsets.only(top: padding),
        child: this,
      );

  Widget pBottom(double padding) => Padding(
        padding: EdgeInsets.only(bottom: padding),
        child: this,
      );
}

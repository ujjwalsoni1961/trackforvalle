import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double? gap;
  const Gap(this.gap, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: gap ?? 0,
      height: gap ?? 0,
    );
  }
}

class GapH extends StatelessWidget {
  final double? gap;
  const GapH(this.gap, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: gap ?? 0,
    );
  }
}

class GapV extends StatelessWidget {
  final double? gap;
  const GapV(this.gap, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: gap ?? 0,
    );
  }
}

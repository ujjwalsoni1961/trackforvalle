import 'package:flutter/material.dart';
import 'package:track/src/core/ui/widgets/gap.dart';

class CenterLoadingTextWidget extends StatelessWidget {
  final String text;
  const CenterLoadingTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const CircularProgressIndicator(),
          const GapV(16),
          Text(text),
        ],
      ),
    );
  }
}

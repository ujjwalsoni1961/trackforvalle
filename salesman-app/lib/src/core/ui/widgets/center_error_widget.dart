import 'package:flutter/material.dart';
import 'package:track/src/core/ui/widgets/gap.dart';

class CenterErrorWidget extends StatelessWidget {
  final String error;
  const CenterErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [const Icon(Icons.error), const GapV(8), Text(error)],
      ),
    );
  }
}

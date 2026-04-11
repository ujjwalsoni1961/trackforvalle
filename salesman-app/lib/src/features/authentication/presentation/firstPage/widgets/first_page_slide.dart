import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/visible_if.dart';
import 'package:track/src/core/ui/widgets/gap.dart';

class FirstPageSlideWidget extends StatelessWidget {
  final String text;
  final String imagePath;

  const FirstPageSlideWidget({
    super.key,
    required this.text,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 200,
            fit: BoxFit.cover,
          ).defaultPadding().visibleIf(true),
          const GapV(12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.aBeeZee(fontSize: 16),
          ).defaultPadding(),
        ],
      ),
    );
  }
}

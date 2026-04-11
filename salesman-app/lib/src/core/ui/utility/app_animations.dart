import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension AppAnimationsExtension on Widget {
  Widget animateButton(AnimationController controller) => animate(
        controller: controller,
        autoPlay: false,
      ).scale(
        begin: const Offset(1, 1),
        end: const Offset(0.96, 0.96),
        duration: const Duration(milliseconds: 100),
        delay: const Duration(milliseconds: 0),
      );

  Widget shakeWidget() {
    return animate().shake(delay: const Duration(milliseconds: 500));
  }
}

class TypeWriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;

  const TypeWriterText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 100),
    this.delay = const Duration(seconds: 1),
  });

  @override
  TypeWriterTextState createState() => TypeWriterTextState();
}

class TypeWriterTextState extends State<TypeWriterText>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Timer? _timer;
  String _displayedText = '';
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _startDisplayTimer();
  }

  void _startDisplayTimer() {
    _timer = Timer.periodic(widget.duration, (timer) {
      if (_index < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_index];
          _index++;
        });
        _controller!.forward(from: 0.0);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}

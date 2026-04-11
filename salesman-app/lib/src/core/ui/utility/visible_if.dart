import 'package:flutter/widgets.dart';

extension VisibleIf on Widget {
  Widget visibleIf(bool isVisible) {
    return isVisible ? this : const SizedBox.shrink();
  }
}

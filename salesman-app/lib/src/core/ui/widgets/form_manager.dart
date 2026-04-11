import 'package:flutter/material.dart';

extension FormExtension on Widget {
  Widget makeItForm(
      GlobalKey<FormState> formKey, FocusScopeNode focusScopeNode) {
    return FocusScope(
        node: focusScopeNode,
        child: Form(
          key: formKey,
          child: this,
        ));
  }
}

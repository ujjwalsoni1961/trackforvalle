// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

extension ToastExtension on BuildContext {
  void successBar(String message, [bool padding = false]) {
    MyToast.show(MessageTypes.SUCCESS, this, message, padding);
  }

  void errorBar(String message, [bool padding = false]) {
    MyToast.show(MessageTypes.ERROR, this, message, padding);
  }
}

class MyToast {
  static void show(
    String messageType,
    BuildContext context,
    String message,
    bool padding,
  ) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: messageType == MessageTypes.ERROR
          ? AppColors.red
          : AppColors.greyDark,
      textColor: AppColors.white,
      fontSize: 16.0,
    );
  }
}

class MessageTypes {
  static const String ERROR = "error";
  static const String SUCCESS = "success";
}

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

  void infoBar(String message, [bool padding = false]) {
    MyToast.show(MessageTypes.INFO, this, message, padding);
  }
}

class MyToast {
  static void show(
    String messageType,
    BuildContext context,
    String message,
    bool padding,
  ) {
    Color bgColor;
    switch (messageType) {
      case MessageTypes.ERROR:
        bgColor = AppColors.red;
        break;
      case MessageTypes.INFO:
        bgColor = const Color(0xFF1d43f0);
        break;
      default:
        bgColor = AppColors.greyDark;
    }
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: AppColors.white,
      fontSize: 16.0,
    );
  }
}

class MessageTypes {
  static const String ERROR = "error";
  static const String SUCCESS = "success";
  static const String INFO = "info";
}

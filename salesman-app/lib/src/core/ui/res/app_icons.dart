import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  // Base path for icons
  static const String _basePath = "assets/icons/";

  // Icon names
  static const String appLock = "${_basePath}applock.svg";
  static const String arrowRight = "${_basePath}arrow_right.svg";
  static const String arrowRightIos = "${_basePath}arrow_right_ios.svg";
  static const String back = "${_basePath}back.svg";
  static const String book = "${_basePath}book.svg";
  static const String continueIcon =
      "${_basePath}continue.svg"; // 'continue' is a reserved keyword
  static const String delete = "${_basePath}delete.svg";
  static const String edit = "${_basePath}edit.svg";
  static const String email = "${_basePath}email.svg";
  static const String faqs = "${_basePath}faqs.svg";
  static const String headphone = "${_basePath}headphone.svg";
  static const String help = "${_basePath}help.svg";
  static const String history = "${_basePath}history.svg";
  static const String link = "${_basePath}link.svg";
  static const String logout = "${_basePath}logout.svg";
  static const String menu = "${_basePath}menu.svg";
  static const String password = "${_basePath}password.svg";
  static const String play = "${_basePath}play.svg";
  static const String privacyPolicy = "${_basePath}privacy_policy.svg";
  static const String security = "${_basePath}security.svg";
  static const String send = "${_basePath}send.svg";
  static const String settings = "${_basePath}settings.svg";
  static const String stop = "${_basePath}stop.svg";
  static const String subject = "${_basePath}subject.svg";
  static const String terms = "${_basePath}terms.svg";
  static const String user = "${_basePath}user.svg";
  static const String calender = "${_basePath}calender.svg";
  static const String clear = "${_basePath}clear.svg";
  static const String visiblity = "${_basePath}visiblity.svg";
  static const String visiblityOff = "${_basePath}visiblity_off.svg";
  static const String wait = "${_basePath}wait.svg";
  static const String done = "${_basePath}done.svg";
  static const String search = "${_basePath}search.svg";
  static const String close = "${_basePath}close.svg";
  static const String coins = "${_basePath}coins.svg";
  static const String buy = "${_basePath}buy.svg";
  static const String google = "${_basePath}google.svg";
  static const String handsfree = "${_basePath}handsfree.svg";
  static const String emergency = "${_basePath}emergency.svg";
  static const String feedback = "${_basePath}feedback.svg";
  static const String transaction = "${_basePath}transaction.svg";
  static const String instagram = "${_basePath}instagram.svg";
  static const String website = "${_basePath}website.svg";
  static const String playstore = "${_basePath}playstore.svg";
  static const String profile = "${_basePath}profile.svg";
  static const String darkMode = "${_basePath}darkmode.svg";
  static const String lightMode = "${_basePath}lightmode.svg";
  static const String notary = "${_basePath}notary.svg";
  static const String browser = "${_basePath}browser.svg";
  static const String linkedin = "${_basePath}linkedin.svg";
  static const String home = "${_basePath}home.svg";
  static const String chats = "${_basePath}chats.svg";

  // Default icon size and color
  static const double size = 22.0;
  static const Color color = Colors.white;

  // Method to get an icon
  static Widget getIcon(
    String iconName, {
    double? size,
    Color? color,
    ThemeData? theme,
  }) {
    return SvgPicture.asset(
      iconName,
      theme: SvgTheme(
        currentColor: (theme != null
            ? theme.iconTheme.color!
            : (color ?? AppIcons.color)),
      ),
      width: size ?? AppIcons.size,
      height: size ?? AppIcons.size,
    );
  }
}

extension AppIconExtension on BuildContext {
  Widget icon(String iconName, {double? size, Color? color}) =>
      AppIcons.getIcon(
        iconName,
        theme: color == null ? Theme.of(this) : null,
        color: color,
        size: size,
      );
}

import 'package:hive_flutter/hive_flutter.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/features/authentication/domain/entities/verify_otp_entity.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';

class HiveConfig {
  static const String registerBoxName = 'registerBox';
  static const String userBoxName = 'userBox';
  static const String appLockBox = 'appLockBox';
  static const String themeModeBoxName = 'themeModeBox';
  static const String themeModeKey = 'themeMode';

  static const int hiveFailureCode = 5001;
  static const int hiveNotFoundCode = 4041;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters with correct typeIds - VerifyOtpEntity is 0, UserEntity is 1
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(sl<VerifyOtpEntityAdapter>()); // typeId: 0
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(sl<UserEntityAdapter>()); // typeId: 1
    }

    // Open boxes with explicit checks to prevent double-opening
    if (!Hive.isBoxOpen(appLockBox)) {
      await Hive.openBox(appLockBox);
      print('✓ Opened $appLockBox');
    }
    if (!Hive.isBoxOpen(userBoxName)) {
      await Hive.openBox(userBoxName);
      final userBox = Hive.box(userBoxName);
      print('✓ Opened $userBoxName');
      print('  Keys in box: ${userBox.keys.toList()}');
      print('  Values in box: ${userBox.values.toList()}');
      print('  Length: ${userBox.length}');
      print('  Is empty: ${userBox.isEmpty}');
    }
    if (!Hive.isBoxOpen(registerBoxName)) {
      await Hive.openBox(registerBoxName);
      print('✓ Opened $registerBoxName');
    }
    if (!Hive.isBoxOpen(themeModeBoxName)) {
      await Hive.openBox(themeModeBoxName);
      print('✓ Opened $themeModeBoxName');
    }
  }
}

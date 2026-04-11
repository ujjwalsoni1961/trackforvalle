import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/local/hive_config.dart';
import 'package:track/src/core/utils/typedef.dart';

class ThemeModeDataSource {
  final box = Hive.box(HiveConfig.themeModeBoxName);

  ResultFutureVoid setThemeMode(ThemeMode themeMode) async {
    try {
      await box.put(HiveConfig.themeModeKey, themeMode.index);
      log("********** Theme mode saved to local storage **********");
      return const Right(null);
    } on Exception catch (e) {
      log("Save Theme Mode Error : ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.runtimeType.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    } catch (e) {
      log("Save Theme Mode Error : ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.runtimeType.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    }
  }

  ResultFuture<ThemeMode> getThemeMode() async {
    try {
      final index = await box.get(HiveConfig.themeModeKey);
      if (index == null) {
        log("********** Theme mode not found in local storage **********");
        return const Left(
          HiveFailure(
            message: 'No theme mode found',
            statusCode: HiveConfig.hiveNotFoundCode,
          ),
        );
      }
      log("********** Theme mode fetched from local storage **********");
      return Right(ThemeMode.values[index]);
    } on Exception catch (e) {
      log("Fetch Theme Mode Error : ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.runtimeType.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    } catch (e) {
      log("Fetch Theme Mode Error : ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.runtimeType.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    }
  }

  ResultFutureVoid deleteThemeMode() async {
    try {
      await box.delete(HiveConfig.themeModeKey);
      log("********** Theme mode deleted from local storage **********");
      return const Right(null);
    } on Exception catch (e) {
      log("Delete Theme Mode Error : ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.runtimeType.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    } catch (e) {
      log("Delete Theme Mode Error : ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.runtimeType.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    }
  }
}

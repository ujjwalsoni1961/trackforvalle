import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/local/hive_config.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';

class UserLocalDataSource {
  Box get box {
    if (Hive.isBoxOpen(HiveConfig.userBoxName)) {
      return Hive.box(HiveConfig.userBoxName);
    }
    throw Exception('User box is not open. Please initialize Hive first.');
  }

  ResultFutureVoid setUserData(UserEntity data) async {
    try {
      log("********** Attempting to save user data to local storage **********");
      await box.put(HiveConfig.userBoxName, data);

      // Flush to ensure data is persisted immediately (critical for web/IndexedDB)
      await box.flush();

      log("********** User data saved to local storage **********");
      log("Box keys after save: ${box.keys.toList()}");

      // Verify data was saved
      final savedData = box.get(HiveConfig.userBoxName);
      if (savedData != null) {
        log("********** Data verification successful **********");
      } else {
        log("********** WARNING: Data verification failed! **********");
      }

      return const Right(null);
    } on Exception catch (e) {
      log("Save User Data Error (Exception): ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    } catch (e) {
      log("Save User Data Error (Generic): ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    }
  }

  ResultFuture<UserEntity> getUserData() async {
    try {
      log("********** Attempting to fetch user data from local storage **********");
      log("Box is open: ${Hive.isBoxOpen(HiveConfig.userBoxName)}");

      final data = await box.get(HiveConfig.userBoxName);

      if (data == null) {
        log("********** User data not found in local storage **********");
        log("Box keys: ${box.keys.toList()}");
        return const Left(
          HiveFailure(
            message: 'No data found',
            statusCode: HiveConfig.hiveNotFoundCode,
          ),
        );
      }

      log("********** User data fetched from local storage successfully **********");
      log("User data type: ${data.runtimeType}");
      return Right(data as UserEntity);
    } on Exception catch (e) {
      log("Fetch User Data Error (Exception): ${e.toString()}");
      log("Stack trace: ${StackTrace.current}");
      return Left(
        HiveFailure(
          message: e.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    } catch (e) {
      log("Fetch User Data Error (Generic): ${e.toString()}");
      log("Stack trace: ${StackTrace.current}");
      return Left(
        HiveFailure(
          message: e.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    }
  }

  ResultFutureVoid removeUserData() async {
    try {
      await box.delete(HiveConfig.userBoxName);
      log("********** User data removed from local storage **********");
      return const Right(null);
    } on Exception catch (e) {
      log("Remove User Data Error : ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.runtimeType.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    } catch (e) {
      log("Remove User Data Error : ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.runtimeType.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    }
  }

  ResultFutureVoid updateUserData({
    String? email,
    String? accessToken,
    String? refreshToken,
    bool? isEmailVerified,
    int? userID,
    String? fullName,
    String? firstName,
    String? lastName,
    String? organizationName,
    String? logoUrl,
    String? phoneNum,
    int? orgId,
    int? addressID,
    int? roleID,
  }) async {
    try {
      final data = await box.get(HiveConfig.userBoxName);
      if (data == null) {
        log("********** User data not found in local storage **********");
        return const Left(
          HiveFailure(
            message: 'No data found',
            statusCode: HiveConfig.hiveNotFoundCode,
          ),
        );
      }
      final oldUserData = data as UserEntity;
      final updatedUserData = oldUserData.copyWith(
        email: email ?? oldUserData.email,
        accessToken: accessToken ?? oldUserData.accessToken,
        refreshToken: refreshToken ?? oldUserData.refreshToken,
        isEmailVerified: isEmailVerified ?? oldUserData.isEmailVerified,
        userID: userID ?? oldUserData.userID,
        fullName: fullName ?? oldUserData.fullName,
        firstName: firstName ?? oldUserData.firstName,
        lastName: lastName ?? oldUserData.lastName,
        organizationName: organizationName ?? oldUserData.organizationName,
        logoUrl: logoUrl ?? oldUserData.logoUrl,
        phoneNum: phoneNum ?? oldUserData.phoneNum,
        orgId: orgId ?? oldUserData.orgId,
        addressID: addressID ?? oldUserData.addressID,
        roleID: roleID ?? oldUserData.roleID,
      );
      await box.put(HiveConfig.userBoxName, updatedUserData);

      // Flush to ensure data is persisted immediately (critical for web/IndexedDB)
      await box.flush();

      log("********** User data updated to local storage **********");
      return const Right(null);
    } on Exception catch (e) {
      log("Save User Data Error : ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.runtimeType.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    } catch (e) {
      log("Save User Data Error : ${e.toString()}");
      return Left(
        HiveFailure(
          message: e.runtimeType.toString(),
          statusCode: HiveConfig.hiveFailureCode,
        ),
      );
    }
  }
}

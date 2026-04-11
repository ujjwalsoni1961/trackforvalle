// import 'dart:developer';

// import 'package:dartz/dartz.dart';
// import 'package:hive/hive.dart';
// import 'package:track/src/core/errors/failure.dart';
// import 'package:track/src/core/local/hive_config.dart';
// import 'package:track/src/core/utils/typedef.dart';
// import 'package:track/src/features/authentication/domain/entities/verify_otp_entity.dart';

// class VerifyOtpDtaSource {
//   final box = Hive.box(HiveConfig.registerBoxName);

//   ResultFutureVoid setVerifyOtpData(VerifyOtpEntity data) async {
//     try {
//       await box.put(HiveConfig.registerBoxName, data);
//       log("********** Register data saved to local storage **********");
//       return const Right(null);
//     } on Exception catch (e) {
//       log("Save Register Data Error : ${e.toString()}");
//       return Left(HiveFailure(
//         message: e.runtimeType.toString(),
//         statusCode: HiveConfig.hiveFailureCode,
//       ));
//     } catch (e) {
//       log("Save Register Data Error : ${e.toString()}");
//       return Left(HiveFailure(
//         message: e.runtimeType.toString(),
//         statusCode: HiveConfig.hiveFailureCode,
//       ));
//     }
//   }

//   ResultFuture<VerifyOtpEntity> getVerifyOtpData() async {
//     try {
//       final data = await box.get(HiveConfig.registerBoxName);
//       if (data == null) {
//         log("********** Register data not found in local storage **********");
//         return const Left(HiveFailure(
//           message: 'No data found',
//           statusCode: HiveConfig.hiveNotFoundCode,
//         ));
//       }
//       log("********** Register data fetched from local storage **********");
//       return Right(data as VerifyOtpEntity);
//     } on Exception catch (e) {
//       log("Fetch Register Data Error : ${e.toString()}");
//       return Left(
//         HiveFailure(
//           message: e.runtimeType.toString(),
//           statusCode: HiveConfig.hiveFailureCode,
//         ),
//       );
//     } catch (e) {
//       log("Fetch Register Data Error : ${e.toString()}");
//       return Left(HiveFailure(
//         message: e.runtimeType.toString(),
//         statusCode: HiveConfig.hiveFailureCode,
//       ));
//     }
//   }

//   ResultFutureVoid deleteVerifyOtpData() async {
//     try {
//       await box.delete(HiveConfig.registerBoxName);
//       log("********** Register data deleted from local storage **********");
//       return const Right(null);
//     } on Exception catch (e) {
//       log("Delete Register Data Error : ${e.toString()}");
//       return Left(HiveFailure(
//         message: e.runtimeType.toString(),
//         statusCode: HiveConfig.hiveFailureCode,
//       ));
//     } catch (e) {
//       log("Delete Register Data Error : ${e.toString()}");
//       return Left(HiveFailure(
//         message: e.runtimeType.toString(),
//         statusCode: HiveConfig.hiveFailureCode,
//       ));
//     }
//   }
// }

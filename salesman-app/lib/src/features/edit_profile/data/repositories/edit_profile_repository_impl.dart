import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';
import 'package:track/src/features/edit_profile/data/data_sources/edit_profile_data_source.dart';
import 'package:track/src/features/edit_profile/domain/entities/user_address_entity.dart';
import 'package:track/src/features/edit_profile/domain/repositories/edit_profile_repository.dart';

class EditProfileRepositoryImpl extends EditProfileRepository {
  final EditProfileDataSource _remoteDataSource;

  EditProfileRepositoryImpl(EditProfileDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;
  @override
  ResultFuture<UserEntity> updateProfile(
    String firstName,
    String lastName,
    UserAddressEntity address,
  ) async {
    try {
      final userData = await _remoteDataSource.updateProfile(
        firstName,
        lastName,
        address,
      );
      return Right(userData);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}

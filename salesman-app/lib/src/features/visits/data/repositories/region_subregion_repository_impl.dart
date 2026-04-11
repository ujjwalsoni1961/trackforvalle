import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/data/data_sources/region_subregion_remote_data_source.dart';
import 'package:track/src/features/visits/domain/entities/regions_subregions_entity.dart';
import 'package:track/src/features/visits/domain/repositories/region_subregion_repository.dart';

class RegionSubregionRepositoryImpl extends RegionSubregionRepository {
  final RegionSubregionRemoteDataSource _remoteDataSource;

  RegionSubregionRepositoryImpl(
    RegionSubregionRemoteDataSource remoteDataSource,
  ) : _remoteDataSource = remoteDataSource;

  @override
  ResultFuture<List<RegionsSubRegionEntity>> getRegions() async {
    try {
      final regions = await _remoteDataSource.getRegions();
      return Right(regions);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
  ResultFuture<List<RegionsSubRegionEntity>> getSubRegions({
    required int regionID,
  }) async {
    try {
      final subRegions = await _remoteDataSource.getSubRegions(
        regionID: regionID,
      );
      return Right(subRegions);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}

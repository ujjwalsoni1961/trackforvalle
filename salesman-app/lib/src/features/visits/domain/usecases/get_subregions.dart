import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/entities/regions_subregions_entity.dart';
import 'package:track/src/features/visits/domain/repositories/region_subregion_repository.dart';

class GetSubregions
    extends
        UseCaseWithParams<List<RegionsSubRegionEntity>, GetSubregionsParams> {
  final RegionSubregionRepository _repository;

  const GetSubregions(RegionSubregionRepository repository)
    : _repository = repository;
  @override
  ResultFuture<List<RegionsSubRegionEntity>> call(
    GetSubregionsParams params,
  ) async => _repository.getSubRegions(regionID: params.regionID);
}

class GetSubregionsParams extends Equatable {
  final int regionID;
  const GetSubregionsParams({required this.regionID});

  @override
  List<Object?> get props => [regionID];
}

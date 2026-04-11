import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/entities/regions_subregions_entity.dart';
import 'package:track/src/features/visits/domain/repositories/region_subregion_repository.dart';

class GetRegions extends UseCaseWithoutParams<List<RegionsSubRegionEntity>> {
  final RegionSubregionRepository _repository;

  const GetRegions(RegionSubregionRepository repository)
    : _repository = repository;
  @override
  ResultFuture<List<RegionsSubRegionEntity>> call() async =>
      _repository.getRegions();
}

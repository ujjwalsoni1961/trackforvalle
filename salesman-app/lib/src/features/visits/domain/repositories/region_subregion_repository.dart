import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/domain/entities/regions_subregions_entity.dart';

abstract class RegionSubregionRepository {
  ResultFuture<List<RegionsSubRegionEntity>> getRegions();
  ResultFuture<List<RegionsSubRegionEntity>> getSubRegions({
    required int regionID,
  });
}

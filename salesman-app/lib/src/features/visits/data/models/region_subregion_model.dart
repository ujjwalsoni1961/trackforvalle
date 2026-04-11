import 'package:track/src/features/visits/domain/entities/regions_subregions_entity.dart';

class RegionSubregionModel extends RegionsSubRegionEntity {
  const RegionSubregionModel({required super.id, required super.name});

  factory RegionSubregionModel.fromMap(Map<String, dynamic> map) {
    return RegionSubregionModel(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}

import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/features/visits/data/models/region_subregion_model.dart';
import 'package:track/src/features/visits/domain/entities/regions_subregions_entity.dart';

abstract class RegionSubregionRemoteDataSource {
  Future<List<RegionsSubRegionEntity>> getRegions();
  Future<List<RegionsSubRegionEntity>> getSubRegions({required int regionID});
}

class RegionSubregionRemoteDataSourceImpl
    extends RegionSubregionRemoteDataSource {
  final API _api;

  RegionSubregionRemoteDataSourceImpl(API api) : _api = api;

  @override
  Future<List<RegionsSubRegionEntity>> getRegions() async {
    try {
      final response = await _api.dio.get('/regions');
      if (response.statusCode == 200) {
        return (response.data as List<dynamic>)
            .map((e) => RegionSubregionModel.fromMap(e))
            .toList();
      } else {
        throw APIException(
          message: response.data['error']['message'],
          statusCode: response.statusCode ?? 500,
        );
      }
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(
        message: e is APIException ? e.message : e.runtimeType.toString(),
        statusCode: 505,
      );
    }
  }

  @override
  Future<List<RegionsSubRegionEntity>> getSubRegions({
    required int regionID,
  }) async {
    try {
      final response = await _api.dio.get('/regions/$regionID');
      if (response.statusCode == 200) {
        return (response.data['subregions'] as List<dynamic>)
            .map((e) => RegionSubregionModel.fromMap(e))
            .toList();
      } else {
        throw APIException(
          message: response.data['error']['message'],
          statusCode: response.statusCode ?? 500,
        );
      }
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(
        message: e is APIException ? e.message : e.runtimeType.toString(),
        statusCode: 505,
      );
    }
  }
}

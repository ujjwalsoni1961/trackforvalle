import 'package:track/src/features/visits/data/models/refresh_routes_model.dart';
import 'package:track/src/features/visits/domain/entities/refresh_routes_list_entity.dart';

class RefreshRoutesListModel extends RefreshRouteListEntity {
  const RefreshRoutesListModel({required super.updatedRoutes});

  factory RefreshRoutesListModel.fromMap(List<dynamic> list) {
    return RefreshRoutesListModel(
      updatedRoutes: list
          .map((item) => RefreshRoutesModel.fromMap(item))
          .toList(),
    );
  }
}

import 'package:track/src/features/visits/data/models/daily_routes_model.dart';
import 'package:track/src/features/visits/domain/entities/daily_routes_list_entity.dart';

class DailyRoutesListModel extends DailyRoutesListEntity {
  const DailyRoutesListModel({required super.routes});

  factory DailyRoutesListModel.fromMap(List<dynamic> list) {
    return DailyRoutesListModel(
      routes: list.map((item) => DailyRoutesModel.fromMap(item)).toList(),
    );
  }
}

import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/entities/daily_routes_list_entity.dart';
import 'package:track/src/features/visits/domain/repositories/visits_repository.dart';

class GetRoutes extends UseCaseWithoutParams<DailyRoutesListEntity> {
  final VisitsRepository _repository;

  GetRoutes(VisitsRepository repository) : _repository = repository;

  @override
  ResultFuture<DailyRoutesListEntity> call() async {
    return await _repository.getRoutes();
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/entities/regions_subregions_entity.dart';
import 'package:track/src/features/visits/domain/usecases/get_subregions.dart';

part 'sub_regions_state.dart';

class SubRegionsCubit extends Cubit<SubRegionsState> {
  final GetSubregions getSubregions;
  SubRegionsCubit(this.getSubregions) : super(SubRegionsInitial());

  Future<void> getTheSubregion(int regionId) async {
    emit(SubRegionsLoading());
    final result = await getSubregions(GetSubregionsParams(regionID: regionId));
    result.fold(
      (failure) => emit(SubRegionsFailed(failure.message)),
      (subregions) => emit(SubRegionsLoaded(subregions)),
    );
  }
}

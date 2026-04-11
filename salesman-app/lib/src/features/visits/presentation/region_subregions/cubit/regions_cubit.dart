import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/entities/regions_subregions_entity.dart';
import 'package:track/src/features/visits/domain/usecases/get_regions.dart';

part 'regions_state.dart';

class RegionsCubit extends Cubit<RegionsState> {
  final GetRegions getRegions;
  RegionsCubit(this.getRegions) : super(RegionsInitial());

  Future<void> getTheRegion() async {
    emit(RegionsLoading());
    final result = await getRegions();
    result.fold(
      (failure) => emit(RegionsFailed(failure.message)),
      (regions) => emit(RegionsLoaded(regions)),
    );
  }
}

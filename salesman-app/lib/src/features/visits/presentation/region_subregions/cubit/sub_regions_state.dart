part of 'sub_regions_cubit.dart';

sealed class SubRegionsState extends Equatable {
  const SubRegionsState();

  @override
  List<Object> get props => [];
}

final class SubRegionsInitial extends SubRegionsState {}

final class SubRegionsLoading extends SubRegionsState {}

final class SubRegionsLoaded extends SubRegionsState {
  final List<RegionsSubRegionEntity> regions;

  const SubRegionsLoaded(this.regions);

  @override
  List<Object> get props => [regions];
}

final class SubRegionsFailed extends SubRegionsState {
  final String errorMessage;

  const SubRegionsFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

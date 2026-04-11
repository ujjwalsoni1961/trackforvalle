part of 'regions_cubit.dart';

sealed class RegionsState extends Equatable {
  const RegionsState();

  @override
  List<Object> get props => [];
}

final class RegionsInitial extends RegionsState {}

final class RegionsLoading extends RegionsState {}

final class RegionsLoaded extends RegionsState {
  final List<RegionsSubRegionEntity> regions;

  const RegionsLoaded(this.regions);

  @override
  List<Object> get props => [regions];
}

final class RegionsFailed extends RegionsState {
  final String errorMessage;

  const RegionsFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

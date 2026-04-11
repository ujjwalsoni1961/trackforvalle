part of 'tab_change_cubit.dart';

sealed class TabChangeState extends Equatable {
  const TabChangeState();

  @override
  List<Object> get props => [];
}

final class TabChangeInitial extends TabChangeState {}

final class TabChange extends TabChangeState {
  final int tabIndex;

  const TabChange(this.tabIndex);

  @override
  List<Object> get props => [tabIndex];
}

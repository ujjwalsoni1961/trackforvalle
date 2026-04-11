part of 'profile_details_cubit.dart';

sealed class ProfileDetailsState extends Equatable {
  const ProfileDetailsState();

  @override
  List<Object> get props => [];
}

final class ProfileDetailsInitial extends ProfileDetailsState {}

final class ProfileDetailsLoading extends ProfileDetailsState {}

final class ProfileDetailsLoaded extends ProfileDetailsState {
  final UserEntity userData;

  const ProfileDetailsLoaded(this.userData);

  @override
  List<Object> get props => [userData];
}

final class ProfileDetailsFailed extends ProfileDetailsState {
  final String errorMessage;

  const ProfileDetailsFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

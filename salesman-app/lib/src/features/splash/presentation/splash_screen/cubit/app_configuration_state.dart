part of 'app_configuration_cubit.dart';

sealed class AppConfigurationState extends Equatable {
  const AppConfigurationState();

  @override
  List<Object> get props => [];
}

final class AppConfigurationInitial extends AppConfigurationState {}

final class UserLoading extends AppConfigurationState {}

final class UserLoggedIn extends AppConfigurationState {}

final class UserNotLoggedIn extends AppConfigurationState {}

final class ConfigurationsLoading extends AppConfigurationState {}

final class GetConfigurationsSuccess extends AppConfigurationState {}

final class GetConfigurationsFailed extends AppConfigurationState {
  final String errorMessage;

  const GetConfigurationsFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

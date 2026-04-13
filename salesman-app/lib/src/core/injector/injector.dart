import 'package:get_it/get_it.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/core/services/auth_service.dart';
import 'package:track/src/features/authentication/data/data_sources/change_password_remote_data_source.dart';
import 'package:track/src/features/authentication/data/data_sources/forgot_password_remote_data_source.dart';
import 'package:track/src/features/authentication/data/data_sources/login_remote_data_source.dart';
import 'package:track/src/features/authentication/data/data_sources/register_remote_data_source.dart';
import 'package:track/src/features/authentication/data/data_sources/resend_otp_remote_data_source.dart';
import 'package:track/src/features/authentication/data/data_sources/verify_remote_data_source.dart';
import 'package:track/src/features/authentication/data/repositories/change_passsword_repository_impl.dart';
import 'package:track/src/features/authentication/data/repositories/forgot_password_repository_impl.dart';
import 'package:track/src/features/authentication/data/repositories/login_repository_impl.dart';
import 'package:track/src/features/authentication/data/repositories/register_repository_impl.dart';
import 'package:track/src/features/authentication/data/repositories/resend_otp_repository_impl.dart';
import 'package:track/src/features/authentication/data/repositories/verify_otp_repository_impl.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';
import 'package:track/src/features/authentication/domain/entities/verify_otp_entity.dart';
import 'package:track/src/features/authentication/domain/repositories/change_password_repository.dart';
import 'package:track/src/features/authentication/domain/repositories/forgot_password_repository.dart';
import 'package:track/src/features/authentication/domain/repositories/login_repository.dart';
import 'package:track/src/features/authentication/domain/repositories/register_repository.dart';
import 'package:track/src/features/authentication/domain/repositories/resend_otp_repository.dart';
import 'package:track/src/features/authentication/domain/repositories/verify_otp_repository.dart';
import 'package:track/src/features/authentication/domain/usecases/change_password.dart';
import 'package:track/src/features/authentication/domain/usecases/forgot_password.dart';
import 'package:track/src/features/authentication/domain/usecases/login_with_credentials.dart';
import 'package:track/src/features/authentication/domain/usecases/login_with_google.dart';
import 'package:track/src/features/authentication/domain/usecases/register_with_credentials.dart';
import 'package:track/src/features/authentication/domain/usecases/resend_otp.dart';
import 'package:track/src/features/authentication/domain/usecases/verify_otp.dart';
import 'package:track/src/features/authentication/presentation/change_password/cubit/change_password_cubit.dart';
import 'package:track/src/features/authentication/presentation/firstPage/cubit/first_page_cubit.dart';
import 'package:track/src/features/authentication/presentation/forgotPwd/cubit/forgot_password_cubit.dart';
import 'package:track/src/features/authentication/presentation/forgotPwd/cubit/forgot_password_timer_cubit.dart';
import 'package:track/src/features/authentication/presentation/login/cubit/login_cubit.dart';
import 'package:track/src/features/authentication/presentation/register/cubit/register_cubit.dart';
import 'package:track/src/features/authentication/presentation/register/cubit/send_otp_cubit.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_cubit.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_otp_timer_cubit.dart';
import 'package:track/src/features/dashboard/data/data_sources/dashboard_remote_data_source.dart';
import 'package:track/src/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:track/src/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:track/src/features/dashboard/domain/usecases/get_dashboard_data.dart';
import 'package:track/src/features/dashboard/presentation/home/cubit/dashboard_cubit.dart';
import 'package:track/src/features/dashboard/presentation/profile/cubit/profile_details_cubit.dart';
import 'package:track/src/features/dashboard/presentation/tabs/cubit/tab_change_cubit.dart';
import 'package:track/src/features/edit_profile/data/data_sources/edit_profile_data_source.dart';
import 'package:track/src/features/edit_profile/data/repositories/edit_profile_repository_impl.dart';
import 'package:track/src/features/edit_profile/domain/repositories/edit_profile_repository.dart';
import 'package:track/src/features/edit_profile/domain/usecases/update_profile.dart';
import 'package:track/src/features/edit_profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:track/src/features/splash/presentation/splash_screen/cubit/app_configuration_cubit.dart';
import 'package:track/src/features/visits/data/data_sources/contracts_remote_data_source.dart';
import 'package:track/src/features/visits/data/data_sources/leads_remote_data_source.dart';
import 'package:track/src/features/visits/data/data_sources/region_subregion_remote_data_source.dart';
import 'package:track/src/features/visits/data/data_sources/visits_remote_data_source.dart';
import 'package:track/src/features/visits/data/repositories/contracts_repository_impl.dart';
import 'package:track/src/features/visits/data/repositories/leads_repository_impl.dart';
import 'package:track/src/features/visits/data/repositories/region_subregion_repository_impl.dart';
import 'package:track/src/features/visits/data/repositories/visits_repository_impl.dart';
import 'package:track/src/features/visits/domain/repositories/contracts_repository.dart';
import 'package:track/src/features/visits/domain/repositories/leads_repository.dart';
import 'package:track/src/features/visits/domain/repositories/region_subregion_repository.dart';
import 'package:track/src/features/visits/domain/repositories/visits_repository.dart';
import 'package:track/src/features/visits/domain/usecases/add_lead.dart';
import 'package:track/src/features/visits/domain/usecases/get_all_leads.dart';
import 'package:track/src/features/visits/domain/usecases/get_contracts_templates.dart';
import 'package:track/src/features/visits/domain/usecases/get_lead_status_list.dart';
import 'package:track/src/features/visits/domain/usecases/get_past_visits.dart';
import 'package:track/src/features/visits/domain/usecases/get_regions.dart';
import 'package:track/src/features/visits/domain/usecases/get_routes.dart';
import 'package:track/src/features/visits/domain/usecases/get_subregions.dart';
import 'package:track/src/features/visits/domain/usecases/get_updated_routes.dart';
import 'package:track/src/features/visits/domain/usecases/plan_visits.dart';
import 'package:track/src/features/visits/domain/usecases/submit_contract.dart';
import 'package:track/src/features/visits/domain/usecases/submit_contract_pdf.dart';
import 'package:track/src/features/visits/domain/usecases/submit_visit_log.dart';
import 'package:track/src/features/visits/domain/usecases/update_lead_details.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/daily_routes_cubit.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/get_current_location_cubit.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/plan_visits_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/add_lead_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/edit_a_lead_details_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/leads_details_cubit.dart';
import 'package:track/src/features/visits/presentation/past_visits/cubit/lead_id_past_visits_cubit.dart';
import 'package:track/src/features/visits/presentation/past_visits/cubit/past_visits_cubit.dart';
import 'package:track/src/features/visits/presentation/region_subregions/cubit/regions_cubit.dart';
import 'package:track/src/features/visits/presentation/region_subregions/cubit/sub_regions_cubit.dart';
import 'package:track/src/features/visits/presentation/sign_contract/cubit/get_contract_templates_cubit.dart';
import 'package:track/src/features/visits/presentation/sign_contract/cubit/submit_contract_cubit.dart';
import 'package:track/src/features/visits/presentation/visit_log/cubit/visit_log_cubit.dart';

final sl = GetIt.instance;

Future<void> injectDependencies() async {
  sl
    ..registerLazySingleton(() => VerifyOtpEntityAdapter())
    ..registerLazySingleton(() => UserEntityAdapter())
    ..registerLazySingleton(() => UserLocalDataSource())
    // Core Services
    ..registerLazySingleton(() => AuthService(sl()))
    ..registerLazySingleton(() => ProfileDetailsCubit())
    ..registerFactory(() => AppConfigurationCubit())
    ..registerFactory(() => RegisterCubit(sl()))
    ..registerFactory(() => SendOtpCubit(sl()))
    ..registerLazySingleton(() => RegisterWithCredentials(sl()))
    ..registerLazySingleton<RegisterRepository>(
      () => RegistorRepositoryImpl(sl()),
    )
    ..registerLazySingleton<RegisterRemoteDataSource>(
      () => RegisterRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton(() => ResendOTP(sl()))
    ..registerLazySingleton<ResendOtpRepository>(
      () => ResendOtpRepositoryImpl(sl()),
    )
    ..registerLazySingleton<ResendOtpRemoteDataSource>(
      () => ResendOtpRemoteDataSourceImpl(sl()),
    )
    ..registerFactory(() => VerifyEmailOtpTimerCubit())
    ..registerFactory(() => VerifyEmailCubit(sl()))
    ..registerLazySingleton(() => VerifyOTP(sl()))
    ..registerLazySingleton<VerifyOTPRepository>(
      () => VerifyOTPRepositoryImpl(sl()),
    )
    ..registerLazySingleton<VerifyOTPRemoteDataSource>(
      () => VerifyOTPRemoteDataSourceImpl(sl()),
    )
    ..registerFactory(() => LoginCubit(sl(), sl()))
    ..registerFactory(() => FirstPageCubit(sl()))
    ..registerLazySingleton(() => LoginWithCredentials(sl()))
    ..registerLazySingleton<LoginRepository>(() => LoginRepositoryImpl(sl()))
    ..registerLazySingleton<LoginRemoteDataSource>(
      () => LoginRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton(() => LoginWithGoogle(sl()))
    ..registerFactory(() => ForgotPasswordTimerCubit())
    ..registerFactory(() => ForgotPasswordCubit(sl()))
    ..registerLazySingleton(() => ForgotPassword(sl()))
    ..registerLazySingleton<ForgetPasswordRepository>(
      () => ForgotPasswordRepositoryImpl(sl()),
    )
    ..registerLazySingleton<ForgotPasswordRemoteDataSource>(
      () => ForgotPasswordRemoteDataSourceImpl(sl()),
    )
    ..registerFactory(() => TabChangeCubit())
    ..registerFactory(() => ChangePasswordCubit(sl()))
    ..registerLazySingleton(() => ChangePassword(sl()))
    ..registerLazySingleton<ChangePasswordRepository>(
      () => ChangePasswordRepositoryImpl(sl()),
    )
    ..registerLazySingleton<ChangePasswordRemoteDataSource>(
      () => ChangePasswordRemoteDataSourceImpl(sl()),
    )
    ..registerFactory(() => EditProfileCubit(sl()))
    ..registerLazySingleton(() => UpdateProfile(sl()))
    ..registerLazySingleton<EditProfileRepository>(
      () => EditProfileRepositoryImpl(sl()),
    )
    ..registerLazySingleton<EditProfileDataSource>(
      () => EditProfileDataSourceImpl(sl()),
    )
    ..registerFactory(() => LeadsDetailsCubit(sl()))
    ..registerFactory(() => LeadStatusCubit(sl()))
    ..registerLazySingleton(() => GetAllLeads(sl()))
    ..registerLazySingleton(() => GetLeadStatusList(sl()))
    ..registerLazySingleton<LeadsRepository>(() => LeadsRepositoryImpl(sl()))
    ..registerLazySingleton<LeadsRemoteDataSource>(
      () => LeadsRemoteDataSourceImpl(sl()),
    )
    ..registerFactory(() => EditALeadDetailsCubit(sl()))
    ..registerLazySingleton(() => UpdateLeadDetails(sl()))
    ..registerFactory(() => DailyRoutesCubit(sl(), sl()))
    ..registerLazySingleton(() => GetRoutes(sl()))
    ..registerLazySingleton(() => GetUpdatedRoutes(sl()))
    ..registerFactory(() => AddLeadCubit(sl(), sl()))
    ..registerLazySingleton(() => AddLead(sl()))
    ..registerLazySingleton<VisitsRepository>(() => VisitsRepositoryImpl(sl()))
    ..registerLazySingleton<VisitsRemoteDataSource>(
      () => VisitsRemoteDataSourceImpl(sl()),
    )
    ..registerFactory(() => GetCurrentLocationCubit())
    ..registerFactory(() => GetContractTemplatesCubit(sl()))
    ..registerLazySingleton(() => GetContractsTemplates(sl()))
    ..registerLazySingleton<ContractsRepository>(
      () => ContractsRepositoryImpl(sl()),
    )
    ..registerLazySingleton<ContractsRemoteDataSource>(
      () => ContractsRemoteDataSourceImpl(sl()),
    )
    ..registerFactory(() => VisitLogCubit(sl()))
    ..registerFactory(() => PlanVisitsCubit(sl()))
    ..registerFactory(() => SubmitContract(sl()))
    ..registerFactory(() => SubmitContractPdf(sl()))
    ..registerLazySingleton(() => SubmitVisitLog(sl()))
    ..registerLazySingleton(() => SubmitContractCubit(
      submitContract: sl(),
      submitContractPdf: sl(),
      repository: sl(),
    ))
    ..registerFactory(() => PastVisitsCubit(sl()))
    ..registerFactory(() => LeadIdPastVisitsCubit(sl()))
    ..registerLazySingleton(() => GetPastVisits(sl()))
    ..registerLazySingleton(() => PlanVisits(sl()))
    ..registerFactory(() => DashboardCubit(sl()))
    ..registerLazySingleton(() => GetDashboardData(sl()))
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(sl()),
    )
    ..registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(sl()),
    )
    ..registerFactory(() => RegionsCubit(sl()))
    ..registerFactory(() => SubRegionsCubit(sl()))
    ..registerLazySingleton(() => GetRegions(sl()))
    ..registerLazySingleton(() => GetSubregions(sl()))
    ..registerLazySingleton<RegionSubregionRepository>(
      () => RegionSubregionRepositoryImpl(sl()),
    )
    ..registerLazySingleton<RegionSubregionRemoteDataSource>(
      () => RegionSubregionRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton(() => API());
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/center_loading_text_widget.dart';
import 'package:track/src/core/ui/utility/confirmation_popup.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/dashboard/presentation/profile/cubit/profile_details_cubit.dart';
import 'package:track/src/features/dashboard/presentation/profile/widgets/list_buttons.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: SingleChildScrollView(
        child: BlocConsumer<ProfileDetailsCubit, ProfileDetailsState>(
          listener: (context, state) {
            if (state is ProfileDetailsFailed) {
              context.errorBar(state.errorMessage);
            }
          },
          builder: (context, state) {
            if (state is ProfileDetailsLoading) {
              return const CenterLoadingTextWidget(text: "Loading Profile");
            }
            if (state is ProfileDetailsFailed) {
              return const Center(child: Text("Error loading profile"));
            }
            if (state is ProfileDetailsLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Details Card
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.accent.withOpacity(
                                  0.1,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.accent,
                                ),
                              ),
                              const GapH(16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${state.userData.firstName} ${state.userData.lastName}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          ),
                                    ),
                                    const GapV(4),
                                    Text(
                                      state.userData.email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: AppColors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const GapV(24),
                          // Profile Details
                          _buildProfileDetailRow(
                            context,
                            icon: Icons.person_outline,
                            title: "User Name",
                            value:
                                "${state.userData.firstName} ${state.userData.lastName}",
                          ),
                          const GapV(16),
                          _buildProfileDetailRow(
                            context,
                            icon: Icons.mail_outline,
                            title: "Email",
                            value: state.userData.email,
                          ),
                          const GapV(16),
                          _buildProfileDetailRow(
                            context,
                            icon: Icons.location_city_outlined,
                            title: "Assigned Address/Regions",
                            value: state.userData.address,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const GapV(16),
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ClickableListButton(
                          title: "Edit Profile",
                          onTap: () {
                            context.push(Routes.editProfile);
                          },
                          icon: const Icon(Icons.edit),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                        const GapV(8),
                        ClickableListButton(
                          title: "Change Password",
                          onTap: () {
                            context.push(Routes.changePassword);
                          },
                          icon: const Icon(Icons.password_outlined),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                        const GapV(8),
                        ClickableListButton(
                          title: "Logout",
                          onTap: () async {
                            ConfirmationPopup.show(
                              context: context,
                              title: "Logout",
                              content: "Are you sure?",
                              onDone: () async {
                                final resLocal = await sl<UserLocalDataSource>()
                                    .removeUserData();
                                resLocal.fold(
                                  (failure) =>
                                      debugPrint('Error: ${failure.message}'),
                                  (userData) {
                                    context.go(Routes.firstPage);
                                  },
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.logout),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 24),
        const GapH(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const GapV(4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

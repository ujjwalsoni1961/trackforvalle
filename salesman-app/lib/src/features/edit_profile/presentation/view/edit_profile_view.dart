import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/res/app_icons.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/utility/validator.dart';
import 'package:track/src/core/ui/widgets/form_manager.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/core/ui/widgets/type_ahead_feild.dart';
import 'package:track/src/features/dashboard/presentation/profile/cubit/profile_details_cubit.dart';
import 'package:track/src/features/edit_profile/domain/entities/user_address_entity.dart';
import 'package:track/src/features/edit_profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:track/src/features/visits/presentation/region_subregions/cubit/regions_cubit.dart';
import 'package:track/src/features/visits/presentation/region_subregions/cubit/sub_regions_cubit.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late EditProfileCubit editProfileCubit = context.read<EditProfileCubit>();
  late ThemeData theme = Theme.of(context);

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController streetAddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusScopeNode focusScopeNode = FocusScopeNode();

  Map<String, dynamic> parseStringAddress(String address) {
    final parts = address.split(', ').map((e) => e.trim()).toList();
    return {
      'street_address': parts.isNotEmpty ? parts[0] : '',
      'city': parts.length > 2 ? parts[2] : '',
      'state': parts.length > 3 ? parts[3] : '',
    };
  }

  @override
  void initState() {
    context.read<ProfileDetailsCubit>().fetchProfileDetailsLocal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: "Edit Profile",
      hideKeyboardOnTap: true,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileDetailsCubit, ProfileDetailsState>(
            listener: (context, profileState) {
              if (profileState is ProfileDetailsLoaded) {
                firstNameController.text = profileState.userData.firstName;
                lastNameController.text = profileState.userData.lastName;
                Map<String, dynamic> parsedAddress = parseStringAddress(
                  profileState.userData.address,
                );
                streetAddressController.text = parsedAddress['street_address'];
                cityController.text = parsedAddress['city'];
                stateController.text = parsedAddress['state'];
              }
            },
          ),
        ],
        child: BlocConsumer<EditProfileCubit, EditProfileState>(
          listener: (context, state) {
            // Logic for the Registering state
            if (state is EditProfileLoading) {
              LoadingAnimation.show(context);
            }
            if (state is EditProfileSuccess) {
              context.read<ProfileDetailsCubit>().fetchProfileDetailsLocal();
              context.pop();
              context.pop();
            }
            if (state is EditProfileFailed) {
              context.pop();
              context.errorBar(state.errorMessage);
            }
          },
          builder: (context, state) {
            return Scrollbar(
              thumbVisibility: true,
              thickness: 4,
              interactive: true,
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GapV(16),
                    Text(
                      "Update your profile details below. Please make sure all the information you provide is accurate and up to date. This will help us serve you better and keep your account secure.",
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ).defaultPadding(),
                    const GapV(16),
                    Column(
                      children: [
                        TextFormField(
                          controller: firstNameController,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a first name';
                            } else if (!Validator.validateName(value)) {
                              return 'Please enter a valid first name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            prefixIcon: Transform.scale(
                              scale: 0.4,
                              child: context.icon(
                                AppIcons.user,
                                color: theme.iconTheme.color,
                              ),
                            ),
                          ),
                        ).defaultPadding(),
                        TextFormField(
                          controller: lastNameController,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a last name';
                            } else if (!Validator.validateName(value)) {
                              return 'Please enter a valid last name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            prefixIcon: Transform.scale(
                              scale: 0.4,
                              child: context.icon(
                                AppIcons.user,
                                color: theme.iconTheme.color,
                              ),
                            ),
                          ),
                        ).defaultPadding(),
                        BlocBuilder<RegionsCubit, RegionsState>(
                          builder: (context, state) {
                            return TypeAheadFieldSleek(
                              controller: stateController,
                              icon: Icons.flag,
                              title: "State",
                              onChanged: (value) {
                                if (state is RegionsLoaded) {
                                  for (final r in state.regions) {
                                    if (r.name == value) {
                                      context
                                          .read<SubRegionsCubit>()
                                          .getTheSubregion(r.id);
                                      break;
                                    }
                                  }
                                }
                              },
                              options: state is RegionsLoading
                                  ? ["Loading..."]
                                  : state is RegionsLoaded
                                  ? state.regions.map((e) => e.name).toList()
                                  : [],
                            ).defaultPadding();
                          },
                        ),
                        BlocBuilder<SubRegionsCubit, SubRegionsState>(
                          builder: (context, state) {
                            return state is SubRegionsLoading
                                ? TextFormField(
                                    controller: cityController,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      labelText: 'Loading cities...',
                                      prefixIcon: Icon(Icons.location_city),
                                    ),
                                  ).defaultPadding()
                                : TypeAheadFieldSleek(
                                    controller: cityController,
                                    icon: Icons.location_city,
                                    title: "City",
                                    options: state is SubRegionsLoaded
                                        ? state.regions
                                              .map((e) => e.name)
                                              .toList()
                                        : [],
                                  ).defaultPadding();
                          },
                        ),
                        TextFormField(
                          controller: streetAddressController,
                          keyboardType: TextInputType.streetAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a Street Address';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Street Address',
                            prefixIcon: Transform.scale(
                              scale: 0.4,
                              child: context.icon(
                                AppIcons.edit,
                                color: theme.iconTheme.color,
                              ),
                            ),
                          ),
                        ).defaultPadding(),
                      ],
                    ),
                    const Gap(16),
                    ButtonPrimary(
                      text: 'Update Profile',
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        focusScopeNode.unfocus();
                        editProfileCubit.updateTheProfile(
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          address: UserAddressEntity(
                            streetAddress: stateController.text.trim(),
                            city: cityController.text.trim(),
                            state: stateController.text.trim(),
                          ),
                        );
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    const Gap(16),
                  ],
                ).makeItForm(formKey, focusScopeNode),
              ),
            );
          },
        ),
      ),
    );
  }
}

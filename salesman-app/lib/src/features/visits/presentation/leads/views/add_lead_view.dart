// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/utility/validator.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/core/ui/widgets/type_ahead_feild.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/add_lead_cubit.dart';
import 'package:track/src/features/visits/presentation/region_subregions/cubit/regions_cubit.dart';
import 'package:track/src/features/visits/presentation/region_subregions/cubit/sub_regions_cubit.dart';

class AddLeadView extends StatefulWidget {
  const AddLeadView({super.key});

  @override
  State<AddLeadView> createState() => _AddLeadViewState();
}

class _AddLeadViewState extends State<AddLeadView> {
  late ThemeData theme;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _areaNameController = TextEditingController();
  final _subregionController = TextEditingController();
  final _regionController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _areaNameController.dispose();
    _subregionController.dispose();
    _regionController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AddLeadCubit>().addTheLead(
        name: _nameController.text.trim(),
        contactName: _contactNameController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        streetAddress: _streetAddressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        areaName: _areaNameController.text.trim(),
        subregion: _subregionController.text.trim(),
        region: _regionController.text.trim(),
        country: _countryController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddLeadCubit, AddLeadState>(
      listener: (context, state) {
        if (state is AddLeadLoading) {
          LoadingAnimation.show(context);
        }
        if (state is AddLeadFailed) {
          context.pop();
          context.errorBar(state.errorMessage);
        }
        if (state is AddLeadSuccess) {
          context.pop();
          context.pop();
          context.successBar("Added lead successfully!");
        }
      },
      child: MyScaffold(
        title: 'Add New Lead',
        hideKeyboardOnTap: true,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _submitForm,
          foregroundColor: AppColors.white,
          label: Text(
            "Save",
            style: TextStyle(fontSize: 18),
          ).pLeft(16).pRight(4),
          icon: const Icon(Icons.save_outlined),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _nameController,
                  icon: Icons.business,
                  title: 'Name',
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _contactNameController,
                  icon: Icons.person,
                  title: 'Contact Name',
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Contact name is required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _contactEmailController,
                  icon: Icons.email,
                  title: 'Contact Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Contact email is required';
                    }
                    if (!Validator.validateEmail(value ?? "")) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _contactPhoneController,
                  icon: Icons.phone,
                  title: 'Contact Phone',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Contact phone is required';
                    }
                    if (!Validator.validatePhone(value.trim())) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _streetAddressController,
                  icon: Icons.location_on,
                  title: 'Street Address',
                  maxLines: 2,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Street address is required';
                    }
                    return null;
                  },
                ),
                BlocBuilder<RegionsCubit, RegionsState>(
                  builder: (context, state) {
                    return TypeAheadField(
                      controller: _stateController,
                      icon: Icons.flag,
                      title: "State",
                      onChanged: (value) {
                        if (state is RegionsLoaded) {
                          for (final r in state.regions) {
                            if (r.name == value) {
                              context.read<SubRegionsCubit>().getTheSubregion(
                                r.id,
                              );
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
                    );
                  },
                ),
                BlocBuilder<SubRegionsCubit, SubRegionsState>(
                  builder: (context, state) {
                    return state is SubRegionsLoading
                        ? _buildTextField(
                            controller: _cityController,
                            icon: Icons.location_city,
                            enabled: false,
                            title: "Loading cities...",
                          )
                        : TypeAheadField(
                            controller: _cityController,
                            icon: Icons.location_city,
                            title: "City",
                            options: state is SubRegionsLoaded
                                ? state.regions.map((e) => e.name).toList()
                                : [],
                          );
                  },
                ),
                _buildTextField(
                  controller: _postalCodeController,
                  icon: Icons.markunread_mailbox,
                  title: 'Postal Code',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Postal code is required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _areaNameController,
                  icon: Icons.area_chart_sharp,
                  title: 'Area Name',
                  maxLines: 2,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Area name is required';
                    }
                    return null;
                  },
                ),
                BlocBuilder<RegionsCubit, RegionsState>(
                  builder: (context, state) {
                    return TypeAheadField(
                      controller: _regionController,
                      icon: Icons.public,
                      title: "Region",
                      onChanged: (value) {
                        if (state is RegionsLoaded) {
                          for (final r in state.regions) {
                            if (r.name == value) {
                              context.read<SubRegionsCubit>().getTheSubregion(
                                r.id,
                              );
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
                    );
                  },
                ),
                BlocBuilder<SubRegionsCubit, SubRegionsState>(
                  builder: (context, state) {
                    return state is SubRegionsLoading
                        ? _buildTextField(
                            controller: _subregionController,
                            icon: Icons.map,
                            enabled: false,
                            title: "Loading subregions...",
                          )
                        : TypeAheadField(
                            controller: _subregionController,
                            icon: Icons.map,
                            title: "Subregion",
                            options: state is SubRegionsLoaded
                                ? state.regions.map((e) => e.name).toList()
                                : [],
                          );
                  },
                ),
                _buildTextField(
                  controller: _countryController,
                  icon: Icons.public,
                  title: 'Country',
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Country is required';
                    }
                    return null;
                  },
                ),
              ],
            ).pBottom(100),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String title,
    bool? enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Card(
      margin: const EdgeInsets.only(top: 8, right: 16, left: 16, bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const GapH(16),
              Expanded(child: Text(title, style: theme.textTheme.labelLarge)),
            ],
          ),
          const GapV(12),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled ?? true,
            validator: validator,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.black.withOpacity(0.9),
            ),
            decoration: InputDecoration(
              hintText: 'Enter $title',
              hintStyle: TextStyle(
                color: theme.colorScheme.tertiary.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ).pSymmetric(vertical: 8);
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/visits/domain/entities/lead_status_entity.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/edit_a_lead_details_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/leads_details_cubit.dart';
import 'package:track/src/features/visits/presentation/visit_log/widgets/lead_status_dropdown.dart';

class EditLeadsDetailsPage extends StatefulWidget {
  final LeadsDetailsEntity lead;

  const EditLeadsDetailsPage({required this.lead, super.key});

  @override
  State<EditLeadsDetailsPage> createState() => _EditLeadsDetailsPageState();
}

class _EditLeadsDetailsPageState extends State<EditLeadsDetailsPage> {
  late ThemeData theme;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _contactNameController;
  late TextEditingController _contactEmailController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _streetAddressController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  late TextEditingController _leadNameController;
  late TextEditingController _buildingUnitController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _landmarkController;
  late TextEditingController _coordinatesController;
  late TextEditingController _areaNameController;

  LeadStatusEntity? selectedStatus;

  late final EditALeadDetailsCubit editALeadDetailsCubit = context
      .read<EditALeadDetailsCubit>();

  @override
  void initState() {
    super.initState();
    for (final status in context.read<LeadStatusCubit>().leadStatusList) {
      if (status.status == widget.lead.status) {
        selectedStatus = status;
        setState(() {});
      }
    }
    _initializeControllers();
  }

  void _initializeControllers() {
    final address = widget.lead.leadAddress;

    _contactNameController = TextEditingController(
      text: widget.lead.contactName,
    );
    _contactEmailController = TextEditingController(
      text: widget.lead.contactEmail,
    );
    _contactPhoneController = TextEditingController(
      text: widget.lead.contactPhone,
    );
    _areaNameController = TextEditingController(text: address.areaName);
    _streetAddressController = TextEditingController(
      text: address.streetAddress,
    );
    _postalCodeController = TextEditingController(text: address.postalCode);

    _countryController = TextEditingController(text: address.country);

    _leadNameController = TextEditingController(text: widget.lead.leadName);
    _buildingUnitController = TextEditingController(text: address.buildingUnit);
    _cityController = TextEditingController(text: address.city);
    _stateController = TextEditingController(text: address.state);
    _landmarkController = TextEditingController(text: address.landmark);
    _coordinatesController = TextEditingController(
      text: '(${address.latitude}, ${address.longitude})',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _streetAddressController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _leadNameController.dispose();
    _buildingUnitController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _landmarkController.dispose();
    _coordinatesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditALeadDetailsCubit, EditALeadDetailsState>(
      listener: (context, state) {
        if (state is EditALeadDetailsLoading) {
          LoadingAnimation.show(context);
        }
        if (state is EditALeadDetailsFailed) {
          context.pop();
          context.errorBar(state.errorMessage);
        }
        if (state is EditALeadDetailsSuccess) {
          context.pop();
          context.read<LeadsDetailsCubit>().getAllTheLeads(pageNumber: 1);
          context.pop();
          context.pop();
          context.successBar("Successfully updated the lead details.");
        }
      },
      child: MyScaffold(
        title: 'Edit ${widget.lead.leadName}',
        hideKeyboardOnTap: true,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final contactName = _contactNameController.text.trim();
            final contactEmail = _contactEmailController.text.trim();
            final contactPhone = _contactPhoneController.text.trim();
            final streetAddress = _streetAddressController.text.trim();
            final postalCode = _postalCodeController.text.trim();
            final areaName = _areaNameController.text.trim();
            final country = _countryController.text.trim();

            editALeadDetailsCubit.updateTheLeadDetails(
              leadID: widget.lead.leadID,

              // Declare all values once to avoid repeated .text.trim()
              contactName:
                  contactName.isEmpty || contactName == widget.lead.contactName
                  ? null
                  : contactName,
              contactEmail:
                  contactEmail.isEmpty ||
                      contactEmail == widget.lead.contactEmail
                  ? null
                  : contactEmail,
              contactPhone:
                  contactPhone.isEmpty ||
                      contactPhone == widget.lead.contactPhone
                  ? null
                  : contactPhone,
              streetAddress:
                  streetAddress.isEmpty ||
                      streetAddress == widget.lead.leadAddress.streetAddress
                  ? null
                  : streetAddress,
              postalCode:
                  postalCode.isEmpty ||
                      postalCode == widget.lead.leadAddress.postalCode
                  ? null
                  : postalCode,
              areaName:
                  areaName.isEmpty ||
                      areaName == widget.lead.leadAddress.areaName
                  ? null
                  : areaName,
              subregion: null,
              region: null,
              country:
                  country.isEmpty || country == widget.lead.leadAddress.country
                  ? null
                  : country,
              status:
                  selectedStatus == null ||
                      selectedStatus!.status.isEmpty ||
                      selectedStatus!.status == widget.lead.status
                  ? null
                  : selectedStatus!.status,
            );
          },
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
                  controller: _leadNameController,
                  icon: Icons.business,
                  title: 'Lead Name',
                  enabled: false,
                ),

                _buildTextField(
                  controller: _contactNameController,
                  icon: Icons.person,
                  title: 'Contact Name',
                  enabled: true,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Contact name is required';
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  controller: _contactPhoneController,
                  icon: Icons.phone,
                  title: 'Contact Phone',
                  enabled: true,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Contact phone is required';
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  controller: _contactEmailController,
                  icon: Icons.email,
                  title: 'Contact Email',
                  enabled: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                LeadStatusDropdown(
                  selectedStatus: selectedStatus,
                  onStatusChanged: (status) {
                    selectedStatus = status;
                    setState(() {});
                  },
                  isContractSigned: false,
                ).pOnly(top: 8, right: 16, left: 16, bottom: 8),
                _buildTextField(
                  controller: _areaNameController,
                  icon: Icons.area_chart_sharp,
                  title: 'Area Name',
                  enabled: true,
                  maxLines: 2,
                ),

                _buildTextField(
                  controller: _streetAddressController,
                  icon: Icons.location_on,
                  title: 'Street Address',
                  enabled: true,
                  maxLines: 2,
                ),
                _buildTextField(
                  controller: _postalCodeController,
                  icon: Icons.markunread_mailbox,
                  title: 'Postal Code',
                  enabled: true,
                  keyboardType: TextInputType.number,
                ),

                _buildTextField(
                  controller: _countryController,
                  icon: Icons.public,
                  title: 'Country',
                  enabled: true,
                ),

                _buildTextField(
                  controller: _buildingUnitController,
                  icon: Icons.apartment,
                  title: 'Building Unit',
                  enabled: false,
                ),

                _buildTextField(
                  controller: _cityController,
                  icon: Icons.location_city,
                  title: 'City',
                  enabled: false,
                ),

                _buildTextField(
                  controller: _stateController,
                  icon: Icons.flag,
                  title: 'State',
                  enabled: false,
                ),

                _buildTextField(
                  controller: _landmarkController,
                  icon: Icons.landscape,
                  title: 'Landmark',
                  enabled: false,
                ),

                _buildTextField(
                  controller: _coordinatesController,
                  icon: Icons.gps_fixed,
                  title: 'Coordinates',
                  enabled: false,
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
    required bool enabled,
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
                  color: enabled
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.tertiary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: enabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.tertiary,
                  size: 20,
                ),
              ),
              const GapH(16),
              Expanded(child: Text(title, style: theme.textTheme.labelLarge)),
              if (!enabled)
                Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: theme.colorScheme.tertiary.withOpacity(0.5),
                ),
            ],
          ),
          const GapV(12),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: enabled
                  ? AppColors.black.withOpacity(0.9)
                  : AppColors.black.withOpacity(0.3),
            ),
            decoration: InputDecoration(
              hintText: enabled ? 'Enter $title' : 'Not editable',
              filled: !enabled,
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

// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/utility/visible_if.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/dashboard/presentation/home/cubit/dashboard_cubit.dart';
import 'package:track/src/features/visits/domain/entities/lead_status_entity.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/get_current_location_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/leads_details_cubit.dart';
import 'package:track/src/features/visits/presentation/past_visits/cubit/past_visits_cubit.dart';
import 'package:track/src/features/visits/presentation/sign_contract/views/choose_contract_view.dart';
import 'package:track/src/features/visits/presentation/visit_log/cubit/visit_log_cubit.dart';
import 'package:track/src/features/visits/presentation/visit_log/widgets/lead_status_dropdown.dart';

class VisitLogView extends StatefulWidget {
  final LeadIDVisitIDPageParams params;
  const VisitLogView({super.key, required this.params});

  @override
  State<VisitLogView> createState() => _VisitLogViewState();
}

class _VisitLogViewState extends State<VisitLogView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _followupNotesController =
      TextEditingController();
  LeadStatusEntity? selectedStatus;
  List<File> _selectedPhotos = [];
  List<String> followUpStatuses = ["Get Back", "Meeting", "Not Available"];
  bool showFollowUp = false;
  DateTime? _selectedDate;

  int? contractSignedID;
  int? visitID;

  bool get _isFollowUpSectionFilled =>
      _subjectController.text.trim().isNotEmpty ||
      _followupNotesController.text.trim().isNotEmpty ||
      _selectedDate != null;

  Future<bool> _requestImagePermission() async {
    try {
      if (await Permission.photos.request().isGranted) return true;
      if (await Permission.storage.request().isGranted) return true;

      if (await Permission.photos.isPermanentlyDenied ||
          await Permission.storage.isPermanentlyDenied) {
        await openAppSettings();
      }
    } catch (e, stack) {
      debugPrint("Permission error: $e\n$stack");
    }
    return false;
  }

  Future<void> _pickPhotos() async {
    if (!await _requestImagePermission()) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedPhotos = result.paths
            .whereType<String>()
            .map((p) => File(p))
            .toList();
      });
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black87,
              onPrimary: Colors.white,
              surface: Colors.grey.shade50,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  String formatDateManually(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
  }

  void _submitForm() {
    // Validate Rest
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_isFollowUpSectionFilled && _selectedDate == null) {
      context.errorBar("Select a follow-up date");
      return;
    }
    final notes = _notesController.text.trim();

    // Followup
    String? followUpData;
    if (_isFollowUpSectionFilled && _selectedDate != null) {
      final subject = _subjectController.text.trim();
      final followupNotes = _followupNotesController.text.trim();
      followUpData =
          '[{"subject": "$subject", "notes": "$followupNotes", "scheduled_date": "${formatDateManually(_selectedDate!)}"}]';
    }

    // Latitude and longitude - non-blocking, allow submission without location
    final locationCubit = context.read<GetCurrentLocationCubit>();
    double? latitude = locationCubit.latitude;
    double? longitude = locationCubit.longitude;

    if (latitude == null || longitude == null) {
      context.infoBar(
        "Location unavailable - visit will be saved without coordinates",
      );
    }

    context.read<VisitLogCubit>().submitTheVisitLog(
      photos: _selectedPhotos,
      notes: notes,
      latitude: latitude,
      longitude: longitude,
      visitID: visitID,
      leadID: widget.params.leadId,
      followUp: followUpData,
      contractID: contractSignedID,
      leadStatus: selectedStatus == null ? "Get Back" : selectedStatus!.status,
    );
  }

  @override
  void didUpdateWidget(covariant VisitLogView oldWidget) {
    contractSignedID = context
        .read<VisitLogCubit>()
        .savedContractIDsByLeadID[widget.params.leadId];
    visitID = context
        .read<VisitLogCubit>()
        .savedVisitIdsbyLeadID[widget.params.leadId];
    if (contractSignedID != null) {
      for (final s in context.read<LeadStatusCubit>().leadStatusList) {
        if (s.status == "Signed") {
          selectedStatus = s;
          break;
        }
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    context.read<GetCurrentLocationCubit>().getCurrentLatLong();
    context.read<VisitLogCubit>().savedContractIDsByLeadID = {};
    context.read<VisitLogCubit>().savedVisitIdsbyLeadID = {};
    _requestImagePermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<VisitLogCubit, VisitLogState>(
          listener: (context, state) {
            if (state is VisitLogLoading) {
              LoadingAnimation.show(context);
            }
            if (state is VisitLogFailed) {
              context.pop();
              context.errorBar(state.errorMessage);
            }
            if (state is VisitLogSuccess) {
              context.read<GetCurrentLocationCubit>().getCurrentLatLong(
                refreshRoutes: true,
              );
              context.read<PastVisitsCubit>().getGeneralPastVisits(
                pageNumber: 1,
              );
              context.read<LeadsDetailsCubit>().getAllTheLeads(pageNumber: 1);
              context.read<DashboardCubit>().getTheDashBoardData();
              context.pop();
              context.pop();
              context.successBar("Added Log Successfully!");
            }
          },
        ),
      ],
      child: MyScaffold(
        title: "Log Visit",
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                contractSignedID != null
                    ? SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: null,
                          icon: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Colors.green.shade700,
                          ),
                          label: Text(
                            "Contract Signed",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.green.shade700,
                            ),
                          ),
                          style:
                              OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.green.shade700,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.green.shade50
                                    .withOpacity(0.05),
                              ).copyWith(
                                overlayColor: WidgetStateProperty.all(
                                  Colors.green.withOpacity(0.08),
                                ),
                              ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push(
                              Routes.chooseContractTemplate,
                              extra: widget.params,
                            );
                          },
                          icon: Icon(
                            Icons.edit_document,
                            size: 18,
                            color: Colors.blue.shade700,
                          ),
                          label: Text(
                            "Sign Contract?",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          style:
                              OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.blue.shade700,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.blue.shade50
                                    .withOpacity(0.05),
                              ).copyWith(
                                overlayColor: WidgetStateProperty.all(
                                  Colors.blue.withOpacity(0.08),
                                ),
                              ),
                        ),
                      ).visibleIf(widget.params.visitId != -1),
                const GapV(12),
                LeadStatusDropdown(
                  selectedStatus: selectedStatus,
                  onStatusChanged: (status) {
                    selectedStatus = status;
                    setState(() {});
                  },
                  isContractSigned: contractSignedID != null,
                  currentLeadStatus: widget.params.currentLeadStatus,
                ),
                const GapV(12),
                Text(
                  "Photos",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const GapV(12),
                GestureDetector(
                  onTap: _pickPhotos,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedPhotos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.grey.shade400,
                                  size: 32,
                                ),
                                const GapH(8),
                                Text(
                                  "Tap to select photos",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8),
                            itemCount: _selectedPhotos.length,
                            separatorBuilder: (_, __) => const GapH(8),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedPhotos[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _removePhoto(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
                const GapV(24),
                Text(
                  "Notes",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const GapV(12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 5,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Notes are required"
                      : null,
                  decoration: _buildInputDecoration("Enter visit notes..."),
                ),
                const GapV(24),
                (followUpStatuses.contains(
                          selectedStatus == null ? "" : selectedStatus!.status,
                        ) ||
                        showFollowUp)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Followups",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                          ),
                          const GapV(12),
                          TextFormField(
                            controller: _subjectController,
                            validator: (value) {
                              if (_isFollowUpSectionFilled &&
                                  value!.trim().isEmpty) {
                                return "Subject is required for follow-up";
                              }
                              return null;
                            },
                            decoration: _buildInputDecoration(
                              "Enter subject...",
                            ),
                          ),
                          const GapV(16),
                          TextFormField(
                            controller: _followupNotesController,
                            maxLines: 4,
                            validator: (value) {
                              if (_isFollowUpSectionFilled &&
                                  value!.trim().isEmpty) {
                                return "Follow-up notes are required";
                              }
                              return null;
                            },
                            decoration: _buildInputDecoration(
                              "Enter followup notes...",
                            ),
                          ),
                          const GapV(16),
                          GestureDetector(
                            onTap: () => _pickDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedDate == null
                                        ? 'Select followup date...'
                                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                    style: TextStyle(
                                      color: _selectedDate == null
                                          ? Colors.grey.shade400
                                          : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              showFollowUp = true;
                            });
                          },
                          label: Text("Add Followup"),
                          icon: Icon(Icons.add),
                        ),
                      ),
                const GapV(32),
                ButtonPrimary(text: "Submit", onPressed: _submitForm),
                const GapV(32),
              ],
            ).pSymmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
      ),
    );
  }
}

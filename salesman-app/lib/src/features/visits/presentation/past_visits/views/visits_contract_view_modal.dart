import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/network/api_interceptor.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/features/visits/presentation/sign_contract/widgets/contract_preview.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:permission_handler/permission_handler.dart';

// Conditional imports for web platform
import 'visits_contract_view_modal_stub.dart'
    if (dart.library.html) 'visits_contract_view_modal_web.dart';

class ContractViewModal extends StatelessWidget {
  final String templateString;
  final String leadName;
  final int contractID;

  const ContractViewModal({
    super.key,
    required this.templateString,
    required this.leadName,
    required this.contractID,
  });

  Future<void> downloadPdf(BuildContext context) async {
    // Handle web platform differently
    if (kIsWeb) {
      await _downloadPdfWeb(context);
      return;
    }

    // Mobile platform download logic
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Request storage permission based on platform
      bool hasPermission = false;

      if (Platform.isAndroid) {
        // Android permission handling with user guidance
        var status = await Permission.storage.status;
        if (status.isGranted) {
          hasPermission = true;
        } else if (status.isDenied) {
          // Show explanation before requesting permission
          // ignore: use_build_context_synchronously
          Navigator.pop(context); // Close loading dialog temporarily
          
          // ignore: use_build_context_synchronously
          final shouldRequest = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Permission Needed"),
              content: const Text(
                "To download PDF files, this app needs access to your device storage. "
                "This allows us to save contract PDFs to your Downloads folder."
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Grant Permission"),
                ),
              ],
            ),
          ) ?? false;
          
          if (!shouldRequest) {
            return; // User cancelled
          }
          
          // Show loading dialog again
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
          
          // Request permission
          status = await Permission.storage.request();
          if (status.isGranted) {
            hasPermission = true;
          } else {
            // Try manage external storage for Android 11+
            var manageStatus = await Permission.manageExternalStorage.status;
            if (manageStatus.isGranted) {
              hasPermission = true;
            } else {
              manageStatus = await Permission.manageExternalStorage.request();
              hasPermission = manageStatus.isGranted;
            }
          }
        } else if (status.isPermanentlyDenied) {
          hasPermission = false; // Will trigger settings dialog
        } else {
          // Request permission directly
          status = await Permission.storage.request();
          if (status.isGranted) {
            hasPermission = true;
          } else {
            // Try manage external storage for Android 11+
            var manageStatus = await Permission.manageExternalStorage.request();
            hasPermission = manageStatus.isGranted;
          }
        }
      } else if (Platform.isIOS) {
        // iOS permission handling - check photos permission for saving to Photos
        var photosStatus = await Permission.photos.status;
        if (photosStatus.isGranted) {
          hasPermission = true;
        } else {
          photosStatus = await Permission.photos.request();
          hasPermission = photosStatus.isGranted;
        }
        
        // Even if photos permission is denied, we can still save to app documents
        if (!hasPermission) {
          hasPermission = true; // Always allow saving to app documents on iOS
        }
      } else {
        hasPermission = true; // Other platforms
      }

      if (!hasPermission && Platform.isAndroid) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Close loading dialog
        
        // Ask user if they want to open settings to grant permission
        // ignore: use_build_context_synchronously
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Storage Permission Required"),
            content: const Text(
              "This app needs storage permission to download PDF files. "
              "Would you like to open settings to grant permission?"
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Open Settings"),
              ),
            ],
          ),
        ) ?? false;
        
        if (shouldOpenSettings) {
          // Open app settings
          final settingsOpened = await openAppSettings();
          if (!settingsOpened) {
            // ignore: use_build_context_synchronously
            context.errorBar("Could not open settings. Please grant storage permission manually.");
          }
        }
        return;
      }

      // Get authorization token
      final userDataRes = await sl<UserLocalDataSource>().getUserData();
      String? authToken;
      userDataRes.fold(
        (failure) => debugPrint('Failed to get user data: $failure'),
        (userData) => authToken = userData.accessToken,
      );

      if (authToken == null) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        context.errorBar("Authentication failed");
        return;
      }

      // Create Dio instance for download
      final dio = Dio();
      final url = "${APIInterceptor.BASE_URL}/contract/$contractID/pdf";
      
      // Get appropriate directory for saving PDF based on platform
      Directory? downloadDir;
      String storageLocation = "";
      
      try {
        if (Platform.isAndroid) {
          // Android: Try to save to Downloads folder
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final downloadsDir = Directory('${externalDir.path}/Download');
            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }
            downloadDir = downloadsDir;
            storageLocation = "Downloads";
          } else {
            downloadDir = await getApplicationDocumentsDirectory();
            storageLocation = "App Documents";
          }
        } else if (Platform.isIOS) {
          // iOS: Save to app documents directory
          downloadDir = await getApplicationDocumentsDirectory();
          storageLocation = "Files App";
        } else {
          // Other platforms
          downloadDir = await getApplicationDocumentsDirectory();
          storageLocation = "Documents";
        }
      } catch (e) {
        debugPrint('Error getting directory: $e');
        downloadDir = await getApplicationDocumentsDirectory();
        storageLocation = "App Documents";
      }

      if (downloadDir == null) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        context.errorBar("Could not access storage folder");
        return;
      }

      // Create filename
      final fileName = "contract_${leadName.replaceAll(' ', '_')}_$contractID.pdf";
      final filePath = "${downloadDir.path}/$fileName";

      debugPrint('Downloading PDF from: $url');
      debugPrint('Saving to: $filePath');

      // Download the PDF
      await dio.download(
        url,
        filePath,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'application/pdf',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // Close loading dialog
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      
      // Show success message with actual storage location
      // ignore: use_build_context_synchronously
      context.successBar("PDF saved to $storageLocation: $fileName");

    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      // Close loading dialog if still open
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      context.errorBar("Failed to download PDF: $e");
    }
  }

  // Web-specific - just open PDF in new tab
  Future<void> _downloadPdfWeb(BuildContext context) async {
    try {
      final url = "${APIInterceptor.BASE_URL}/contract/$contractID/pdf";
      debugPrint('Opening PDF in new tab: $url');

      // Simply open the PDF URL in a new tab using the platform-specific helper
      // The browser will handle authentication via cookies/session
      openUrlInNewTab(url);

      // Show success message
      context.successBar("PDF opened in new tab");

    } catch (e) {
      debugPrint('Error opening PDF: $e');
      context.errorBar("Failed to open PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('=== CONTRACT VIEW MODAL DEBUG ===');
    debugPrint('Contract ID: $contractID');
    debugPrint('Lead Name: $leadName');
    debugPrint('Template String: $templateString');
    debugPrint('Template String Length: ${templateString.length}');
    debugPrint('================================');
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.grey.shade50,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 32,
          maxWidth: MediaQuery.of(context).size.width - 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Ensures alignment
              children: [
                TextButton(
                  onPressed: () => downloadPdf(context),
                  child: Text(kIsWeb ? "Open PDF" : "Download PDF"),
                ),

                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                ),
              ],
            ),
            const GapV(16),

            // Contract Preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ContractPreview(
                    templateString: templateString,
                    contractId: contractID,
                  ),
                ),
              ),
            ),

            const GapV(16),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

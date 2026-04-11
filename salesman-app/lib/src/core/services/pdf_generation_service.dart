import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class PdfGenerationService {
  static Future<File> generateContractPdf({
    required String templateContent,
    required SignatureController signatureController,
    required Map<String, String> formData,
    required Map<String, String> dropdownValues,
    required int contractId,
  }) async {
    try {
      // Create PDF document
      final pdf = pw.Document();
      
      // Get signature image with validation
      final signatureBytes = await signatureController.toPngBytes();
      print('Signature bytes length: ${signatureBytes?.length ?? 0}');
      
      if (signatureBytes == null || signatureBytes.isEmpty) {
        throw Exception('Signature is empty or invalid');
      }
      
      final signatureImage = pw.MemoryImage(signatureBytes);

      // Process template content
      String processedContent = _processTemplate(
        templateContent,
        formData,
        dropdownValues,
      );
      
      print('Processed content length: ${processedContent.length}');
      print('Processed content preview: ${processedContent.length > 200 ? processedContent.substring(0, 200) : processedContent}...');
      
      // Simplified PDF generation - just create basic text content with signature
      List<pw.Widget> widgets = [];
      
      // Add contract content as simple text
      String cleanContent = _stripHtmlTags(processedContent);
      List<String> paragraphs = cleanContent.split('\n').where((p) => p.trim().isNotEmpty).toList();
      
      print('Number of paragraphs: ${paragraphs.length}');
      
      // Add each paragraph as text
      for (String paragraph in paragraphs) {
        if (paragraph.trim().isNotEmpty) {
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Text(
                paragraph.trim(),
                style: pw.TextStyle(fontSize: 12, lineSpacing: 1.2),
              ),
            ),
          );
        }
      }
      
      // Always add signature at the end
      widgets.add(pw.SizedBox(height: 32));
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Customer Signature:',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                height: 80,
                width: 250,
                child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      );

      print('Total widgets created: ${widgets.length}');

      // Add pages to PDF with simplified approach
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => widgets,
          footer: (pw.Context context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 10),
            ),
          ),
        ),
      );

      print('PDF pages added successfully');

      // Generate PDF bytes
      final pdfBytes = await pdf.save();
      print('Generated PDF bytes length: ${pdfBytes.length}');
      
      if (pdfBytes.isEmpty) {
        throw Exception('PDF generation resulted in empty bytes');
      }
      
      // Save PDF to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/contract_$contractId.pdf');
      await file.writeAsBytes(pdfBytes);
      
      // Verify file was written
      final fileExists = await file.exists();
      final fileSize = await file.length();
      print('PDF file exists: $fileExists, size: $fileSize bytes');
      
      if (!fileExists) {
        throw Exception('PDF file was not created');
      }
      
      if (fileSize == 0) {
        throw Exception('PDF file is empty (0 bytes)');
      }
      
      print('PDF generation completed successfully');
      return file;
    } catch (e) {
      print('Error in PDF generation: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  static String _processTemplate(
    String template,
    Map<String, String> formData,
    Map<String, String> dropdownValues,
  ) {
    String result = template;
    
    // Replace form data fields
    formData.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    
    // Replace dropdown fields
    dropdownValues.forEach((key, value) {
      result = result.replaceAll('{dropdown:$key}', value);
    });
    
    // Add current date and signature date
    final now = DateTime.now();
    final dateString = '${now.day}/${now.month}/${now.year}';
    result = result.replaceAll('{date_signed}', dateString);
    result = result.replaceAll('{contract_date}', dateString);
    
    return result;
  }


  static String _stripHtmlTags(String htmlString) {
    // Remove HTML tags but preserve line breaks
    String result = htmlString
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<h[1-6][^>]*>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n- ')  // Use dash instead of bullet
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove all other HTML tags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
    
    // Clean up multiple line breaks
    result = result.replaceAll(RegExp(r'\n\s*\n'), '\n\n');
    
    return result;
  }

}
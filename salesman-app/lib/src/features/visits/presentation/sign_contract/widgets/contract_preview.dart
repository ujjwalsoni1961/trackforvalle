import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:track/src/core/network/api_interceptor.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/user_local_data_source.dart';

// Conditional imports for web platform
import 'contract_preview_stub.dart'
    if (dart.library.html) 'contract_preview_web.dart' as platform;

class ContractPreview extends StatefulWidget {
  final String templateString;
  final int? contractId;
  final String? pdfUrl;
  const ContractPreview({super.key, required this.templateString, this.contractId, this.pdfUrl});

  @override
  State<ContractPreview> createState() => _ContractPreviewState();
}

class _ContractPreviewState extends State<ContractPreview> {
  WebViewController? _webViewController;
  String? _viewId;

  String? _resolveContent() {
    // Priority: pdfUrl > contractId > templateString
    if (widget.pdfUrl != null && widget.pdfUrl!.isNotEmpty) {
      return 'pdf_url';
    }
    if (widget.contractId != null) {
      return 'contract_id';
    }
    return 'html';
  }

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _viewId = 'contract-preview-${DateTime.now().millisecondsSinceEpoch}-${widget.contractId ?? 0}-${widget.pdfUrl?.hashCode ?? 0}';
      _registerWebView();
    } else {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..enableZoom(true);

      _webViewController!.setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36');
      _loadContent();
    }
  }

  void _registerWebView() {
    final mode = _resolveContent();
    
    if (mode == 'pdf_url') {
      // Embed PDF directly — browsers render PDFs in iframes natively
      final iframe = platform.createIFrame(src: widget.pdfUrl!);
      debugPrint('Registering direct PDF iframe: $_viewId url=${widget.pdfUrl}');
      platform.registerPlatformView(_viewId!, (int viewId) => iframe);
    } else if (mode == 'contract_id') {
      final pdfUrl = "${APIInterceptor.BASE_URL}/contract/${widget.contractId}/pdf";
      final iframe = platform.createIFrame(src: pdfUrl);
      debugPrint('Registering contract PDF iframe: $_viewId');
      platform.registerPlatformView(_viewId!, (int viewId) => iframe);
    } else {
      final htmlContent = _buildHtml(widget.templateString);
      final iframe = platform.createIFrame(srcdoc: htmlContent);
      debugPrint('Registering HTML iframe: $_viewId');
      platform.registerPlatformView(_viewId!, (int viewId) => iframe);
    }
  }

  @override
  void didUpdateWidget(covariant ContractPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.templateString != widget.templateString || 
        oldWidget.contractId != widget.contractId || 
        oldWidget.pdfUrl != widget.pdfUrl) {
      if (kIsWeb) {
        setState(() {
          _viewId = 'contract-preview-${DateTime.now().millisecondsSinceEpoch}-${widget.contractId ?? 0}-${widget.pdfUrl?.hashCode ?? 0}';
          _registerWebView();
        });
      } else {
        _loadContent();
      }
    }
  }

  void _loadContent() async {
    if (!kIsWeb) {
      final mode = _resolveContent();
      
      if (mode == 'pdf_url') {
        // Load PDF directly in webview
        _webViewController?.loadRequest(Uri.parse(widget.pdfUrl!));
      } else if (mode == 'contract_id') {
        debugPrint('Loading PDF for contract ID: ${widget.contractId}');
        final pdfUrl = "${APIInterceptor.BASE_URL}/contract/${widget.contractId}/pdf";

        final userDataRes = await sl<UserLocalDataSource>().getUserData();
        Map<String, String> headers = {};
        userDataRes.fold(
          (failure) => debugPrint('Failed to get user data: $failure'),
          (userData) {
            headers['Authorization'] = 'Bearer ${userData.accessToken}';
          },
        );

        _webViewController?.loadRequest(Uri.parse(pdfUrl), headers: headers);
      } else {
        debugPrint('Loading HTML template for contract preview');
        _webViewController?.loadHtmlString(_buildHtml(widget.templateString));
      }
    }
  }

  String _buildHtml(String content) {
    String processedContent = _processImageTags(content);
    
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="Content-Security-Policy" content="img-src * data: blob: 'unsafe-inline'; script-src 'unsafe-inline';">
        <style>
          body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            padding: 16px; 
            color: #333; 
            background: #f9f9f9;
            line-height: 1.6;
          }
          h1, h2, h3 { color: #2c3e50; margin-top: 24px; margin-bottom: 12px; }
          h1 { font-size: 24px; border-bottom: 2px solid #3498db; padding-bottom: 8px; }
          h2 { font-size: 20px; color: #34495e; }
          p { margin-bottom: 12px; text-align: justify; }
          strong { color: #2c3e50; font-weight: 600; }
          .signature-container {
            border: 2px solid #e0e0e0; border-radius: 8px; padding: 12px;
            margin: 16px 0; background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center;
          }
          .signature-image {
            max-width: 200px; height: auto; border: 1px solid #ddd;
            border-radius: 4px; display: block; margin: 0 auto;
          }
          .signature-placeholder {
            border: 2px dashed #ccc; padding: 20px; margin: 8px 0;
            background: #f9f9f9; color: #666; text-align: center;
            border-radius: 8px; font-size: 14px;
          }
          img {
            max-width: 200px; height: auto; border: 2px solid #e0e0e0;
            border-radius: 8px; padding: 4px; background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1); display: block; margin: 8px 0;
          }
        </style>
      </head>
      <body>
        $processedContent
      </body>
      </html>
    ''';
  }
  
  String _processImageTags(String content) {
    final imgRegex = RegExp(r'<img[^>]*src="([^"]*)"[^>]*>', caseSensitive: false);
    
    content = content.replaceAllMapped(imgRegex, (match) {
      final imgSrc = match.group(1)!;
      return '<div class="signature-container"><img src="$imgSrc" alt="Customer Signature" class="signature-image" onerror="this.style.display=\'none\'; this.parentElement.innerHTML=\'<div class=&quot;signature-placeholder&quot;>Customer Signature</div>\';"></div>';
    });
    
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb
            ? (_viewId != null
                ? HtmlElementView(viewType: _viewId!)
                : const Center(child: CircularProgressIndicator()))
            : (_webViewController != null
                ? WebViewWidget(controller: _webViewController!)
                : const Center(child: CircularProgressIndicator())),
      ),
    );
  }
}

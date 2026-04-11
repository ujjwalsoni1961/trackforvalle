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
  const ContractPreview({super.key, required this.templateString, this.contractId});

  @override
  State<ContractPreview> createState() => _ContractPreviewState();
}

class _ContractPreviewState extends State<ContractPreview> {
  WebViewController? _webViewController;
  String? _viewId;

  @override
  void initState() {
    super.initState();

    // Generate a stable view ID for web and register immediately
    if (kIsWeb) {
      _viewId = 'contract-preview-${DateTime.now().millisecondsSinceEpoch}-${widget.contractId ?? 0}';

      // Register the platform view immediately in initState
      if (widget.contractId != null) {
        final pdfUrl = "${APIInterceptor.BASE_URL}/contract/${widget.contractId}/pdf";
        final iframe = platform.createIFrame(src: pdfUrl);
        debugPrint('Registering platform view in initState: $_viewId');
        platform.registerPlatformView(_viewId!, (int viewId) => iframe);
      } else {
        final htmlContent = _buildHtml(widget.templateString);
        final iframe = platform.createIFrame(srcdoc: htmlContent);
        debugPrint('Registering platform view in initState: $_viewId');
        platform.registerPlatformView(_viewId!, (int viewId) => iframe);
      }
    } else {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..enableZoom(true);

      // Configure additional settings for better PDF viewing
      _webViewController!.setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36');

      _loadContent();
    }
  }

  @override
  void didUpdateWidget(covariant ContractPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.templateString != widget.templateString || oldWidget.contractId != widget.contractId) {
      if (kIsWeb) {
        // For web, we need to re-register the platform view with new content
        setState(() {
          _viewId = 'contract-preview-${DateTime.now().millisecondsSinceEpoch}-${widget.contractId ?? 0}';

          if (widget.contractId != null) {
            final pdfUrl = "${APIInterceptor.BASE_URL}/contract/${widget.contractId}/pdf";
            final iframe = platform.createIFrame(src: pdfUrl);
            debugPrint('Re-registering platform view: $_viewId');
            platform.registerPlatformView(_viewId!, (int viewId) => iframe);
          } else {
            final htmlContent = _buildHtml(widget.templateString);
            final iframe = platform.createIFrame(srcdoc: htmlContent);
            debugPrint('Re-registering platform view with new template: $_viewId');
            platform.registerPlatformView(_viewId!, (int viewId) => iframe);
          }
        });
      } else {
        _loadContent();
      }
    }
  }

  void _loadContent() async {
    if (!kIsWeb) {
      // For mobile platforms, use WebView
      if (widget.contractId != null) {
        // If we have a contract ID, load the PDF directly
        debugPrint('Loading PDF for contract ID: ${widget.contractId}');
        final pdfUrl = "${APIInterceptor.BASE_URL}/contract/${widget.contractId}/pdf";
        debugPrint('PDF URL: $pdfUrl');

        // Get authorization header
        final userDataRes = await sl<UserLocalDataSource>().getUserData();
        Map<String, String> headers = {};
        userDataRes.fold(
          (failure) => debugPrint('Failed to get user data: $failure'),
          (userData) {
            headers['Authorization'] = 'Bearer ${userData.accessToken}';
          },
        );

        _webViewController?.loadRequest(
          Uri.parse(pdfUrl),
          headers: headers,
        );
      } else {
        // If no contract ID, show the template HTML (for contract creation/preview)
        debugPrint('Loading HTML template for contract preview');
        _webViewController?.loadHtmlString(_buildHtml(widget.templateString));
      }
    }
  }


  String _buildHtml(String content) {
    debugPrint('=== BUILDING HTML FOR CONTRACT PREVIEW ===');
    debugPrint('Rendered HTML content: $content');
    
    // Process content to handle images better
    String processedContent = _processImageTags(content);
    
    // Use the rendered HTML directly - it's already complete with all data filled in
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
          
          h1, h2, h3 {
            color: #2c3e50;
            margin-top: 24px;
            margin-bottom: 12px;
          }
          
          h1 {
            font-size: 24px;
            border-bottom: 2px solid #3498db;
            padding-bottom: 8px;
          }
          
          h2 {
            font-size: 20px;
            color: #34495e;
          }
          
          p {
            margin-bottom: 12px;
            text-align: justify;
          }
          
          strong {
            color: #2c3e50;
            font-weight: 600;
          }
          
          .signature-container {
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            padding: 12px;
            margin: 16px 0;
            background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
          }
          
          .signature-image {
            max-width: 200px;
            height: auto;
            border: 1px solid #ddd;
            border-radius: 4px;
            display: block;
            margin: 0 auto;
          }
          
          .signature-placeholder {
            border: 2px dashed #ccc;
            padding: 20px;
            margin: 8px 0;
            background: #f9f9f9;
            color: #666;
            text-align: center;
            border-radius: 8px;
            font-size: 14px;
          }
          
          
          img {
            max-width: 200px;
            height: auto;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            padding: 4px;
            background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            display: block;
            margin: 8px 0;
          }
        </style>
        <script>
          setTimeout(function() {
            var images = document.querySelectorAll('img');
            console.log('Found ' + images.length + ' images to process');
            
            images.forEach(function(img, index) {
              console.log('Image ' + index + ' src:', img.src);
              console.log('Image ' + index + ' complete:', img.complete);
              console.log('Image ' + index + ' naturalWidth:', img.naturalWidth);
              
              // Force reload the image
              var originalSrc = img.src;
              img.src = '';
              img.src = originalSrc;
              
              img.onerror = function() {
                console.log('Image failed to load:', originalSrc);
                var container = document.createElement('div');
                container.className = 'signature-container';
                container.innerHTML = '<div class="signature-placeholder">🖊️ Customer Signature</div>';
                img.parentNode.replaceChild(container, img);
              };
              
              img.onload = function() {
                console.log('Image loaded successfully:', originalSrc);
                img.className = 'signature-image';
              };
            });
          }, 500);
        </script>
      </head>
      <body>
        $processedContent
      </body>
      </html>
    ''';
  }
  
  String _processImageTags(String content) {
    debugPrint('Processing image tags in content');
    
    // Find all img tags and process them
    final imgRegex = RegExp(r'<img[^>]*src="([^"]*)"[^>]*>', caseSensitive: false);
    
    content = content.replaceAllMapped(imgRegex, (match) {
      final fullImgTag = match.group(0)!;
      final imgSrc = match.group(1)!;
      
      debugPrint('Found img tag: $fullImgTag');
      debugPrint('Image src: $imgSrc');
      
      // Enhance the img tag with better error handling
      return '<div class="signature-container"><img src="$imgSrc" alt="Customer Signature" class="signature-image" onerror="console.log(\'Image load error:\', this.src); this.style.display=\'none\'; this.parentElement.innerHTML=\'<div class=&quot;signature-placeholder&quot;>🖊️ Customer Signature</div>\';"></div>';
    });
    
    debugPrint('Processed content: $content');
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

// Web-specific implementation
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: undefined_hidden_name, depend_on_referenced_packages
import 'dart:ui_web' as ui_web;

void registerPlatformView(String viewId, html.Element Function(int) factory) {
  ui_web.platformViewRegistry.registerViewFactory(viewId, factory);
}

html.IFrameElement createIFrame({String? src, String? srcdoc}) {
  final iframe = html.IFrameElement()
    ..style.border = 'none'
    ..style.width = '100%'
    ..style.height = '100%'
    ..setAttribute('sandbox', 'allow-scripts allow-same-origin allow-popups')
    ..setAttribute('allow', 'fullscreen');

  if (src != null) {
    // For PDF URLs, use Mozilla's hosted PDF.js viewer to guarantee inline rendering.
    // Direct iframe src to a PDF often triggers download instead of in-browser preview.
    if (src.toLowerCase().endsWith('.pdf') ||
        src.contains('/template-pdfs/') ||
        RegExp(r'/contract/\d+/pdf').hasMatch(src)) {
      final encodedUrl = Uri.encodeComponent(src);
      iframe.src = 'https://mozilla.github.io/pdf.js/web/viewer.html?file=$encodedUrl';
    } else {
      iframe.src = src;
    }
  }
  if (srcdoc != null) {
    iframe.srcdoc = srcdoc;
  }

  return iframe;
}

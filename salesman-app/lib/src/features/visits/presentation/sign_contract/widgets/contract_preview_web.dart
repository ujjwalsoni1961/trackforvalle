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
    ..style.height = '100%';

  if (src != null) {
    iframe.src = src;
  }
  if (srcdoc != null) {
    iframe.srcdoc = srcdoc;
  }

  return iframe;
}

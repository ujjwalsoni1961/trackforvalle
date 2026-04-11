// Stub for non-web platforms
void registerPlatformView(String viewId, dynamic Function(int) factory) {
  throw UnsupportedError('Platform views are only supported on web');
}

dynamic createIFrame({String? src, String? srcdoc}) {
  throw UnsupportedError('IFrame is only supported on web');
}

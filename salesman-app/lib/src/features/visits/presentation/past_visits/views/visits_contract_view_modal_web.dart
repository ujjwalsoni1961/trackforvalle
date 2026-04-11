// Web-specific implementation
import 'package:web/web.dart' as web;

void openUrlInNewTab(String url) {
  web.window.open(url, '_blank');
}

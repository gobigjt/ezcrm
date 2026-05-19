// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void resetUrlToRoot() {
  try {
    html.window.history.replaceState(null, '', '/');
  } catch (_) {}
}

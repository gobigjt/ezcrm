// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void requestOsNotificationPermission() {
  try {
    if (html.Notification.supported) {
      html.Notification.requestPermission();
    }
  } catch (_) {}
}

void showOsNotification(String title, String body) {
  try {
    if (html.Notification.supported &&
        html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    }
  } catch (_) {}
}

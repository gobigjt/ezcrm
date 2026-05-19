// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void playNotificationSound() {
  try {
    final audio = html.AudioElement('/notification.wav');
    audio.play();
  } catch (_) {}
}

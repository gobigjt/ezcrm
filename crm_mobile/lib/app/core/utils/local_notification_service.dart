import 'package:flutter/services.dart';

class LocalNotificationService {
  static const _channel = MethodChannel('com.redonix.ezcrm/notifications');
  static bool _initialized = false;

  static Future<void> init() async {
    _initialized = true;
  }

  static Future<void> show(String title, String body) async {
    if (!_initialized) return;
    try {
      await _channel.invokeMethod('showNotification', {'title': title, 'body': body});
    } catch (_) {}
  }
}

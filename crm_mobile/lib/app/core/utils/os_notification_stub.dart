import 'local_notification_service.dart';

void requestOsNotificationPermission() => LocalNotificationService.init();
void showOsNotification(String title, String body) => LocalNotificationService.show(title, body);

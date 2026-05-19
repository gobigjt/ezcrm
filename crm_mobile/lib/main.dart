import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import 'app/core/theme/app_theme.dart';
import 'app/core/navigation/deep_link_controller.dart';
import 'app/core/utils/web_url_helper.dart';
import 'app/modules/auth/auth_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

/// Runs in a separate isolate when the app is terminated or in background.
/// The 'notification' key in the FCM message already causes Android to show
/// the system notification automatically — this handler just ensures the
/// isolate is alive so Android doesn't skip delivery.
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage _) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // On web refresh, reset the URL to '/' so GetX always starts from splash
  // instead of trying to restore a deep route before controllers are ready.
  resetUrlToRoot();
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  } catch (_) {
    // App still runs without FCM if Firebase config is not set yet.
  }
  runApp(const CrmMobileApp());
}

class CrmMobileApp extends StatelessWidget {
  const CrmMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EzCRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.put(DeepLinkController(), permanent: true);
      }),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}

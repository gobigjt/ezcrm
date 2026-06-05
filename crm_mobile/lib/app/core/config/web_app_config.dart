import 'package:flutter/foundation.dart' show kIsWeb;

/// API base URL for the mobile app.
///
/// **Release / staging / physical device:** pass an explicit URL at build time, e.g.
/// `flutter build apk --dart-define=API_BASE_URL=https://your-api.example.com/api`
///
/// **Local API:** defaults aim at a Nest backend on port 4000 (see `backend/.env.example`):
/// - Android emulator: `http://10.0.2.2:4000/api` (host machine loopback)
/// - iOS Simulator & desktop: `http://127.0.0.1:4000/api`
///
/// On a **physical Android phone**, use your PC’s LAN IP, e.g.
/// `--dart-define=API_BASE_URL=http://192.168.1.50:4000/api`.
///
/// No trailing slash (trailing slashes are normalized in [ApiClient.normalizeApiBase]).
class WebAppConfig {
  static const _productionApi = 'https://api-ezcrm.redonix.in/api';

  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) {
      // On web, derive API host from the page origin so LAN access works.
      try {
        final origin = Uri.base;
        if (origin.host.isNotEmpty) {
          return '${origin.scheme}://${origin.host}:4000/api';
        }
      } catch (_) {}
      return 'http://127.0.0.1:4000/api';
    }
    // Physical device — uses Hostinger VPS production backend.
    // For local testing on same Wi-Fi: flutter run --dart-define=API_BASE_URL=http://192.168.1.8:4000/api
    return _productionApi;
  }
}

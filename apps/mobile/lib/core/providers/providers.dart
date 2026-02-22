import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'data_providers.dart';
export 'database_providers.dart';
export 'analytics_preferences_provider.dart';
export 'auth_session_providers.dart';
export 'backend_api_providers.dart';
export 'firebase_runtime_config_provider.dart';
export 'operational_telemetry_provider.dart';
export 'theme_provider.dart';
export 'items_view_mode_provider.dart';
export 'collections_view_mode_provider.dart';
export 'locale_provider.dart';
export 'sync_providers.dart';

final onboardingCompleteProvider = Provider<bool>((ref) => false);

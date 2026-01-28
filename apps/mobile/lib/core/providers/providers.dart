import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'data_providers.dart';
export 'database_providers.dart';
export 'theme_provider.dart';
export 'items_view_mode_provider.dart';

final onboardingCompleteProvider = Provider<bool>((ref) => false);

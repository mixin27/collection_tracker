import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'data_providers.dart';
export 'database_providers.dart';

final onboardingCompleteProvider = Provider<bool>((ref) => false);

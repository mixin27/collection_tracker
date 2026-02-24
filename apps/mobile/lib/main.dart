import 'package:collection_tracker/app.dart';
import 'package:collection_tracker/core/bootstrap/app_bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection_tracker/core/observers/riverpod_logger.dart';

import 'core/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bootstrapData = await AppBootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: [
        onboardingCompleteProvider.overrideWith(
          (ref) => bootstrapData.onboardingComplete,
        ),
        initialFirebaseRuntimeConfigProvider.overrideWith(
          (ref) => bootstrapData.firebaseRuntimeConfig,
        ),
      ],
      observers: [if (kDebugMode) RiverpodLogger()],
      child: const CollectionTrackerApp(),
    ),
  );
}

import 'package:collection_tracker/core/providers/providers.dart';
import 'package:collection_tracker/core/router/app_router.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

class CollectionTrackerApp extends ConsumerWidget {
  const CollectionTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeSettings = ref.watch(themeSettingsProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Collection Tracker',

      // Theme
      theme: AppTheme.light(variant: themeSettings.variant),
      darkTheme: AppTheme.dark(
        variant: themeSettings.variant,
        amoled: themeSettings.amoled,
      ),
      themeMode: themeSettings.mode,

      // Localizations
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Routing and navigation
      routerConfig: router,
    );
  }
}

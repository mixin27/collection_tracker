import 'package:collection_tracker/core/providers/providers.dart';
import 'package:collection_tracker/core/firebase/firebase_runtime_config_auto_refresh.dart';
import 'package:collection_tracker/core/notifications/push_notification_bridge.dart';
import 'package:collection_tracker/core/router/app_router.dart';
import 'package:collection_tracker/core/sync/sync_auto_retry_on_resume.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

class CollectionTrackerApp extends ConsumerWidget {
  const CollectionTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeSettings = ref.watch(themeSettingsProvider);
    final language = ref.watch(localeSettingsProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: language.locale,

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
      builder: (context, child) {
        final mediaBrightness = MediaQuery.platformBrightnessOf(context);
        final resolvedBrightness = switch (themeSettings.mode) {
          ThemeMode.light => Brightness.light,
          ThemeMode.dark => Brightness.dark,
          ThemeMode.system => mediaBrightness,
        };
        final isDark = resolvedBrightness == Brightness.dark;
        final overlay = isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: PushNotificationBridge(
            child: SyncAutoRetryOnResume(
              child: FirebaseRuntimeConfigAutoRefresh(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:app_logger/app_logger.dart';
import 'package:app_firebase/app_firebase.dart';
import 'package:collection_tracker/core/firebase/firebase_runtime_config.dart';
import 'package:collection_tracker/core/observability/operational_telemetry.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../widgets/settings_primitives.dart';

class SettingsDevToolsScreen extends ConsumerWidget {
  const SettingsDevToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final runtimeConfig = ref.watch(firebaseRuntimeConfigProvider);
    final runtimeSummary = _firebaseRuntimeSummary(context, runtimeConfig);
    final pushPreferences = ref.watch(pushNotificationPreferencesProvider);
    final pushSummary = _pushDiagnosticsSummary(pushPreferences);

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.settingsSectionDeveloper} Tools')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          AppReveal(child: _FirebaseRuntimeHealthCard(config: runtimeConfig)),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger,
            child: SettingsSection(
              title: l10n.settingsSectionDeveloper,
              children: [
                SettingsTile(
                  icon: Icons.settings_remote_outlined,
                  title: l10n.settingsFirebaseRuntimeConfigTitle,
                  subtitle: runtimeSummary,
                  onTap: () => _showFirebaseRuntimeConfigSheet(context, ref),
                ),
                SettingsTile(
                  icon: Icons.cloud_sync_outlined,
                  title: 'Cloud Sync Diagnostics',
                  subtitle: 'Inspect sync readiness, failures, and queue state',
                  onTap: () => _showCloudSyncDiagnosticsSheet(context, ref),
                ),
                SettingsTile(
                  icon: Icons.cloud_outlined,
                  title: 'Backend API Configuration',
                  subtitle: 'Set base URL override for local/staging backend',
                  onTap: () => _showSyncApiConfigurationHelp(context, ref),
                ),
                SettingsTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Diagnostics',
                  subtitle: pushSummary,
                  onTap: () => _showPushDiagnosticsSheet(context, ref),
                ),
                SettingsTile(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Operational Telemetry',
                  subtitle: 'Inspect recent sync/data/runtime events',
                  onTap: () => _showOperationalTelemetrySheet(context, ref),
                ),
                SettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: l10n.settingsCrashlyticsTestTitle,
                  subtitle: l10n.settingsCrashlyticsTestSubtitle,
                  onTap: () => _handleCrashlyticsTest(context),
                ),
              ],
            ),
          ),
          if (!kDebugMode) ...[
            const SizedBox(height: AppSpacing.md),
            AppReveal(
              delay: AppMotion.stagger * 2,
              child: AppCard(
                child: Text(
                  'DevTools are available in debug builds only.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _firebaseRuntimeSummary(
    BuildContext context,
    FirebaseRuntimeConfig config,
  ) {
    final enabledCount = [
      config.analyticsCollectionEnabled,
      config.crashlyticsCollectionEnabled,
      config.performanceCollectionEnabled,
    ].where((value) => value).length;
    return context.l10n.settingsFirebaseRuntimeConfigSummary(enabledCount);
  }

  String _pushDiagnosticsSummary(PushNotificationPreferencesState preferences) {
    if (!preferences.runtimeFeatureEnabled) {
      return 'Feature disabled';
    }
    final tokenStatus = preferences.deviceToken?.trim().isNotEmpty == true
        ? 'Token available'
        : 'Token unavailable';
    return '$tokenStatus • ${_pushPermissionLabel(preferences.permissionStatus)}';
  }

  Future<void> _showPushDiagnosticsSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showAppSheet(
      context: context,
      builder: (sheetContext) {
        return Consumer(
          builder: (sheetContext, ref, _) {
            final preferences = ref.watch(pushNotificationPreferencesProvider);
            final notifier = ref.read(
              pushNotificationPreferencesProvider.notifier,
            );

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Push Diagnostics',
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _CloudSyncStateRow(
                    label: 'Feature flag',
                    value: preferences.runtimeFeatureEnabled
                        ? 'Enabled'
                        : 'Disabled',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _CloudSyncStateRow(
                    label: 'Preference',
                    value: preferences.preferenceEnabled
                        ? 'Enabled'
                        : 'Disabled',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _CloudSyncStateRow(
                    label: 'Permission',
                    value: _pushPermissionLabel(preferences.permissionStatus),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _CloudSyncStateRow(
                    label: 'Sync topic',
                    value: preferences.syncNeededEnabled ? 'On' : 'Off',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _CloudSyncStateRow(
                    label: 'Price topic',
                    value: preferences.priceAlertsEnabled ? 'On' : 'Off',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _CloudSyncStateRow(
                    label: 'Reminder topic',
                    value: preferences.remindersEnabled ? 'On' : 'Off',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _CloudSyncStateRow(
                    label: 'Security topic',
                    value: preferences.accountSecurityEnabled ? 'On' : 'Off',
                  ),
                  if (defaultTargetPlatform == TargetPlatform.iOS ||
                      defaultTargetPlatform == TargetPlatform.macOS) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _CloudSyncStateRow(
                      label: 'APNs token',
                      value: _apnsTokenLabel(preferences.apnsToken),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  _CloudSyncStateRow(
                    label: 'Device token',
                    value:
                        preferences.deviceToken != null &&
                            preferences.deviceToken!.trim().isNotEmpty
                        ? _truncateToken(preferences.deviceToken!)
                        : 'Not available',
                  ),
                  if (defaultTargetPlatform == TargetPlatform.iOS &&
                      (preferences.apnsToken == null ||
                          preferences.apnsToken!.trim().isEmpty)) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'APNs token is often unavailable on simulator. Test on a physical iPhone.',
                      style: Theme.of(sheetContext).textTheme.bodySmall
                          ?.copyWith(
                            color: Theme.of(
                              sheetContext,
                            ).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: preferences.isApplying
                        ? 'Refreshing...'
                        : 'Refresh permission status',
                    onPressed: preferences.isApplying
                        ? null
                        : () => notifier.refreshPermissionStatus(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: sheetContext.l10n.actionDismiss,
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSyncApiConfigurationHelp(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final initialOverride = ref.read(backendApiBaseUrlOverrideProvider);
    final effectiveUrl = ref.read(backendApiBaseUrlProvider);
    final controller = TextEditingController(text: initialOverride);

    await showAppSheet(
      context: context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure Backend API',
              style: Theme.of(
                sheetContext,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Enter backend API base URL used for sync and authentication.',
              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              controller: controller,
              labelText: 'Base URL override',
              hintText: 'http://localhost:4000',
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Effective URL: $effectiveUrl',
              style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Save',
              onPressed: () async {
                await ref
                    .read(backendApiBaseUrlOverrideProvider.notifier)
                    .setBaseUrl(controller.text);
                if (!sheetContext.mounted) {
                  return;
                }
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backend API URL updated.')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Clear override',
              variant: AppButtonVariant.secondary,
              onPressed: () async {
                await ref
                    .read(backendApiBaseUrlOverrideProvider.notifier)
                    .clear();
                if (!sheetContext.mounted) {
                  return;
                }
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Backend API URL override cleared.'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: sheetContext.l10n.actionDismiss,
              variant: AppButtonVariant.ghost,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _showCloudSyncDiagnosticsSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showAppSheet(
      context: context,
      builder: (sheetContext) {
        return Consumer(
          builder: (sheetContext, ref, _) {
            final readiness = ref.watch(syncReadinessProvider);
            final transportConfig = ref.watch(syncTransportConfigProvider);
            final pendingCount =
                ref.watch(syncOutboxCountProvider).asData?.value ?? 0;
            final syncState = ref.watch(syncStateProvider).asData?.value;
            final envFlagOverridesActive = ref.watch(
              backendDebugEnvFlagOverridesActiveProvider,
            );
            final session = ref.watch(authSessionProvider).value;
            final hasSession = session?.isAuthenticated ?? false;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cloud Sync Diagnostics',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _CloudSyncStateRow(
                  label: 'Readiness',
                  value: readiness.status.name,
                ),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(label: 'Message', value: readiness.message),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(
                  label: 'Backend flag',
                  value: transportConfig.backendFeatureEnabled
                      ? 'Enabled'
                      : 'Disabled',
                ),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(
                  label: 'Sync flag',
                  value: transportConfig.syncFeatureEnabled
                      ? 'Enabled'
                      : 'Disabled',
                ),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(
                  label: 'Auth flag',
                  value: transportConfig.authFeatureEnabled
                      ? 'Enabled'
                      : 'Disabled',
                ),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(
                  label: 'Env overrides',
                  value: envFlagOverridesActive ? 'Active' : 'Inactive',
                ),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(
                  label: 'Base URL',
                  value: transportConfig.baseUrl.isEmpty
                      ? 'Not configured'
                      : transportConfig.baseUrl,
                ),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(
                  label: 'Resolved URL',
                  value: transportConfig.isApiBaseUrlConfigured
                      ? transportConfig.normalizedApiBaseUrl
                      : 'Not available',
                ),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(
                  label: 'Outbox',
                  value: '$pendingCount pending',
                ),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(
                  label: 'Failures',
                  value: '${syncState?.consecutiveFailures ?? 0}',
                ),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(
                  label: 'Next retry',
                  value: _formatSyncRetryAt(syncState?.nextRetryAt),
                ),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(
                  label: 'Auth',
                  value: hasSession ? 'Signed in' : 'Signed out',
                ),
                const SizedBox(height: AppSpacing.xs),
                _CloudSyncStateRow(
                  label: 'Device',
                  value: session?.deviceId ?? 'Unavailable',
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Configure API',
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    await _showSyncApiConfigurationHelp(context, ref);
                  },
                  expand: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Rebuild local sync queue',
                  variant: AppButtonVariant.secondary,
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    await _rebuildSyncOutboxFromLocal(context, ref);
                  },
                  expand: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: sheetContext.l10n.actionDismiss,
                  variant: AppButtonVariant.ghost,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  expand: true,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _rebuildSyncOutboxFromLocal(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final result = await ref
          .read(syncOutboxBootstrapperProvider)
          .rebuildFromLocalData();
      await OperationalTelemetry.trackSyncQueueRebuild(
        success: true,
        queuedOperations: result.totalOperations,
      );

      if (!context.mounted) {
        return;
      }
      final message = result.totalOperations > 0
          ? 'Rebuilt queue with ${result.totalOperations} local change(s). Run Sync now.'
          : 'No local data found to queue for sync.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: result.totalOperations > 0
              ? Colors.green
              : Colors.orange,
        ),
      );
    } catch (error, stackTrace) {
      await OperationalTelemetry.trackSyncQueueRebuild(
        success: false,
        queuedOperations: 0,
        error: error,
        stackTrace: stackTrace,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to rebuild local sync queue: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showOperationalTelemetrySheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showAppSheet(
      context: context,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.72;
        return SizedBox(
          height: maxHeight,
          child: Consumer(
            builder: (sheetContext, ref, _) {
              final historyAsync = ref.watch(
                operationalTelemetryHistoryProvider,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational Telemetry',
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Recent sync/data/runtime events captured locally for debug.',
                    style: Theme.of(sheetContext).textTheme.bodyMedium
                        ?.copyWith(
                          color: Theme.of(
                            sheetContext,
                          ).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: historyAsync.when(
                      data: (entries) {
                        if (entries.isEmpty) {
                          return Center(
                            child: Text(
                              'No telemetry events yet.',
                              style: Theme.of(sheetContext).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      sheetContext,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: entries.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            return _OperationalTelemetryEventTile(
                              entry: entries[index],
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(
                        child: Text(
                          'Failed to load telemetry: $error',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppButton(
                        label: 'Refresh',
                        variant: AppButtonVariant.secondary,
                        onPressed: () =>
                            refreshOperationalTelemetryHistory(ref),
                      ),
                      AppButton(
                        label: 'Clear',
                        variant: AppButtonVariant.ghost,
                        onPressed: () => clearOperationalTelemetryHistory(ref),
                      ),
                      AppButton(
                        label: sheetContext.l10n.actionDismiss,
                        variant: AppButtonVariant.ghost,
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showFirebaseRuntimeConfigSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showAppSheet(
      context: context,
      builder: (sheetContext) {
        return Consumer(
          builder: (sheetContext, ref, _) {
            final l10n = sheetContext.l10n;
            final runtimeConfig = ref.watch(firebaseRuntimeConfigProvider);
            final remoteConfigStatus = ref.watch(
              firebaseRemoteConfigStatusProvider,
            );
            final isRefreshing = ref.watch(
              firebaseRuntimeConfigRefreshInProgressProvider,
            );
            final lastFetchTimeText = _lastFetchTimeLabel(
              sheetContext,
              remoteConfigStatus.lastFetchTime,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsFirebaseRuntimeConfigSheetTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.settingsFirebaseRuntimeConfigDescription,
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.insights_outlined),
                  title: Text(l10n.settingsFirebaseRuntimeConfigAnalyticsLabel),
                  subtitle: const Text('app_analytics_collection_enabled'),
                  trailing: Text(
                    _enabledDisabledLabel(
                      sheetContext,
                      runtimeConfig.analyticsCollectionEnabled,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(
                    l10n.settingsFirebaseRuntimeConfigCrashlyticsLabel,
                  ),
                  subtitle: const Text('app_crashlytics_collection_enabled'),
                  trailing: Text(
                    _enabledDisabledLabel(
                      sheetContext,
                      runtimeConfig.crashlyticsCollectionEnabled,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.speed_outlined),
                  title: Text(
                    l10n.settingsFirebaseRuntimeConfigPerformanceLabel,
                  ),
                  subtitle: const Text('app_performance_collection_enabled'),
                  trailing: Text(
                    _enabledDisabledLabel(
                      sheetContext,
                      runtimeConfig.performanceCollectionEnabled,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('App Check'),
                  subtitle: const Text('app_app_check_enabled'),
                  trailing: Text(
                    _enabledDisabledLabel(
                      sheetContext,
                      runtimeConfig.appCheckEnabled,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Push notifications'),
                  subtitle: const Text('app_fcm_enabled'),
                  trailing: Text(
                    _enabledDisabledLabel(
                      sheetContext,
                      runtimeConfig.fcmEnabled,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.auto_awesome_outlined),
                  title: const Text('Metadata fetching'),
                  subtitle: const Text('app_metadata_feature_enabled'),
                  trailing: Text(
                    _enabledDisabledLabel(
                      sheetContext,
                      runtimeConfig.metadataFeatureEnabled,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.hub_outlined),
                  title: const Text('Backend integration'),
                  subtitle: const Text('app_backend_integration_enabled'),
                  trailing: Text(
                    _enabledDisabledLabel(
                      sheetContext,
                      runtimeConfig.backendIntegrationEnabled,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Authentication'),
                  subtitle: const Text('app_auth_feature_enabled'),
                  trailing: Text(
                    _enabledDisabledLabel(
                      sheetContext,
                      runtimeConfig.authFeatureEnabled,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cloud_sync_outlined),
                  title: Text(l10n.settingsCloudSyncTitle),
                  subtitle: const Text('app_sync_feature_enabled'),
                  trailing: Text(
                    _enabledDisabledLabel(
                      sheetContext,
                      runtimeConfig.syncFeatureEnabled,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.sync_alt_outlined),
                  title: Text(
                    l10n.settingsFirebaseRuntimeConfigFetchStatusTitle,
                  ),
                  subtitle: Text(
                    _remoteConfigFetchStatusLabel(
                      sheetContext,
                      remoteConfigStatus.lastFetchStatus,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text(l10n.settingsFirebaseRuntimeConfigLastFetchTitle),
                  subtitle: Text(lastFetchTimeText),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: isRefreshing
                      ? l10n.settingsFirebaseRuntimeConfigRefreshingAction
                      : l10n.settingsFirebaseRuntimeConfigRefreshAction,
                  onPressed: isRefreshing
                      ? null
                      : () => _refreshFirebaseRuntimeConfig(sheetContext, ref),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _refreshFirebaseRuntimeConfig(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final isRefreshing = ref.read(
      firebaseRuntimeConfigRefreshInProgressProvider,
    );
    if (isRefreshing) {
      return;
    }

    final l10n = context.l10n;

    try {
      final result = await ref
          .read(firebaseRuntimeConfigControllerProvider.notifier)
          .refreshFromRemoteConfig(forceFetch: true);
      await ref
          .read(analyticsPreferencesProvider.notifier)
          .syncToAnalyticsService();

      if (!context.mounted) {
        return;
      }

      final message = result.didActivateChanges
          ? l10n.settingsFirebaseRuntimeConfigRefreshSuccess
          : l10n.settingsFirebaseRuntimeConfigRefreshNoChanges;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error, stackTrace) {
      Logger.error(
        'Failed to refresh Firebase runtime config.',
        error,
        stackTrace,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.settingsFirebaseRuntimeConfigRefreshFailed('$error'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleCrashlyticsTest(BuildContext context) async {
    final l10n = context.l10n;
    final shouldCrash = await showAppDialog<bool>(
      context: context,
      title: Text(l10n.settingsCrashlyticsTestConfirmTitle),
      content: Text(l10n.settingsCrashlyticsTestConfirmMessage),
      actions: [
        AppButton(
          label: l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context, false),
        ),
        AppButton(
          label: l10n.settingsCrashlyticsTestConfirmAction,
          variant: AppButtonVariant.danger,
          onPressed: () => closeAppDialog(context, true),
        ),
      ],
    );

    if (shouldCrash != true || !context.mounted) {
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsCrashlyticsTestTriggered)),
      );

      await FirebaseCrashlytics.instance.log(
        'Manual Crashlytics test from debug settings action.',
      );
      await FirebaseCrashlytics.instance.setCustomKey(
        'debug_action',
        'settings_crashlytics_test',
      );

      await Future<void>.delayed(const Duration(milliseconds: 350));
      FirebaseCrashlytics.instance.crash();
    } catch (error, stackTrace) {
      Logger.error(
        'Failed to trigger Crashlytics test crash.',
        error,
        stackTrace,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsCrashlyticsTestFailed('$error')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatSyncRetryAt(DateTime? value) {
    if (value == null) {
      return 'Not scheduled';
    }

    final local = value.toLocal();
    String twoDigits(int part) => part.toString().padLeft(2, '0');
    return '${local.year}-'
        '${twoDigits(local.month)}-'
        '${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}:'
        '${twoDigits(local.second)}';
  }

  String _enabledDisabledLabel(BuildContext context, bool enabled) {
    final l10n = context.l10n;
    return enabled
        ? l10n.settingsFirebaseRuntimeConfigValueEnabled
        : l10n.settingsFirebaseRuntimeConfigValueDisabled;
  }

  String _remoteConfigFetchStatusLabel(
    BuildContext context,
    Object? lastFetchStatus,
  ) {
    final l10n = context.l10n;
    final statusText = lastFetchStatus?.toString() ?? '';

    if (statusText.contains('success')) {
      return l10n.settingsFirebaseRuntimeConfigFetchStatusSuccess;
    }
    if (statusText.contains('failure')) {
      return l10n.settingsFirebaseRuntimeConfigFetchStatusFailure;
    }
    if (statusText.contains('throttle')) {
      return l10n.settingsFirebaseRuntimeConfigFetchStatusThrottled;
    }

    return l10n.settingsFirebaseRuntimeConfigFetchStatusNoFetch;
  }

  String _lastFetchTimeLabel(BuildContext context, DateTime? lastFetchTime) {
    if (lastFetchTime == null) {
      return context.l10n.settingsFirebaseRuntimeConfigFetchStatusNoFetch;
    }

    final materialLocalizations = MaterialLocalizations.of(context);
    final localTime = lastFetchTime.toLocal();
    final dateLabel = materialLocalizations.formatShortDate(localTime);
    final timeLabel = materialLocalizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(localTime),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    return '$dateLabel $timeLabel';
  }

  String _pushPermissionLabel(FirebaseMessagingPermissionStatus status) {
    return switch (status) {
      FirebaseMessagingPermissionStatus.notDetermined => 'Not determined',
      FirebaseMessagingPermissionStatus.denied => 'Denied',
      FirebaseMessagingPermissionStatus.authorized => 'Authorized',
      FirebaseMessagingPermissionStatus.provisional => 'Provisional',
      FirebaseMessagingPermissionStatus.unsupported => 'Unsupported',
    };
  }

  String _truncateToken(String token) {
    final sanitized = token.trim();
    if (sanitized.length <= 18) {
      return sanitized;
    }
    return '${sanitized.substring(0, 10)}...${sanitized.substring(sanitized.length - 8)}';
  }

  String _apnsTokenLabel(String? apnsToken) {
    final sanitized = apnsToken?.trim() ?? '';
    if (sanitized.isEmpty) {
      return 'Not available';
    }
    return _truncateToken(sanitized);
  }
}

class _CloudSyncStateRow extends StatelessWidget {
  const _CloudSyncStateRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        SizedBox(
          width: 112,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: valueStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _OperationalTelemetryEventTile extends StatelessWidget {
  const _OperationalTelemetryEventTile({required this.entry});

  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final name = entry['name'] as String? ?? 'unknown_event';
    final category = entry['category'] as String? ?? 'unknown';
    final hasError = entry['has_error'] as bool? ?? false;
    final timestamp = _formatTimestamp(entry['timestamp'] as String?);
    final rawProperties = entry['properties'];
    final properties = rawProperties is Map
        ? rawProperties.cast<String, dynamic>()
        : const <String, dynamic>{};
    final preview = properties.entries
        .take(4)
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(' | ');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasError ? Icons.error_outline : Icons.check_circle_outline,
                size: 18,
                color: hasError
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$category • $timestamp',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              preview,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(String? value) {
    if (value == null || value.isEmpty) {
      return 'unknown time';
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }
    final local = parsed.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)} '
        '${_two(local.hour)}:${_two(local.minute)}:${_two(local.second)}';
  }

  String _two(int value) => value < 10 ? '0$value' : '$value';
}

class _FirebaseRuntimeHealthCard extends StatelessWidget {
  const _FirebaseRuntimeHealthCard({required this.config});

  final FirebaseRuntimeConfig config;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enabledCount = [
      config.analyticsCollectionEnabled,
      config.crashlyticsCollectionEnabled,
      config.performanceCollectionEnabled,
    ].where((value) => value).length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsFirebaseRuntimeConfigTitle,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.settingsFirebaseRuntimeConfigSummary(enabledCount),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _FirebaseFlagStatusRow(
            icon: Icons.insights_outlined,
            label: l10n.settingsFirebaseRuntimeConfigAnalyticsLabel,
            enabled: config.analyticsCollectionEnabled,
          ),
          const SizedBox(height: AppSpacing.xs),
          _FirebaseFlagStatusRow(
            icon: Icons.bug_report_outlined,
            label: l10n.settingsFirebaseRuntimeConfigCrashlyticsLabel,
            enabled: config.crashlyticsCollectionEnabled,
          ),
          const SizedBox(height: AppSpacing.xs),
          _FirebaseFlagStatusRow(
            icon: Icons.speed_outlined,
            label: l10n.settingsFirebaseRuntimeConfigPerformanceLabel,
            enabled: config.performanceCollectionEnabled,
          ),
        ],
      ),
    );
  }
}

class _FirebaseFlagStatusRow extends StatelessWidget {
  const _FirebaseFlagStatusRow({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labelText = enabled
        ? l10n.settingsFirebaseRuntimeConfigValueEnabled
        : l10n.settingsFirebaseRuntimeConfigValueDisabled;
    final badgeColor = enabled
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;
    final badgeForeground = enabled
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            labelText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: badgeForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

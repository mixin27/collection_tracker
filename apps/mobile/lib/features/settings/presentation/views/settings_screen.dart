import 'package:app_logger/app_logger.dart';
import 'package:auth_session/auth_session.dart';
import 'package:collection_tracker/core/analytics/analytics_consent_dialog.dart';
import 'package:collection_tracker/core/analytics/analytics_preferences.dart';
import 'package:collection_tracker/core/firebase/firebase_runtime_config.dart';
import 'package:collection_tracker/core/observability/operational_telemetry.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:collection_tracker/core/router/routes.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storage/storage.dart';
import 'package:ui/ui.dart';

import '../view_models/export_import_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeSettings = ref.watch(themeSettingsProvider);
    final currentLanguage = ref.watch(localeSettingsProvider);
    final analyticsPreferences = ref.watch(analyticsPreferencesProvider);
    final firebaseRuntimeConfig = ref.watch(firebaseRuntimeConfigProvider);
    final syncReadiness = ref.watch(syncReadinessProvider);
    final accountReadiness = ref.watch(backendAuthReadinessProvider);
    final pendingSyncCount = ref.watch(syncOutboxCountProvider).value ?? 0;
    final authSession = ref.watch(authSessionProvider).value;
    final themeSummary =
        '${_themeModeLabel(context, themeSettings.mode)} - ${themeSettings.variant.label}';
    final languageSummary = _languageLabel(context, currentLanguage);
    final analyticsSummary = _analyticsSummary(context, analyticsPreferences);
    final accountSummary = _authAccountSummary(authSession, accountReadiness);
    final accountFeatureEnabled = accountReadiness.enabled;
    final cloudSyncSummary = _cloudSyncSummary(
      syncReadiness,
      pendingSyncCount: pendingSyncCount,
    );
    final cloudSyncFeatureEnabled =
        syncReadiness.status != SyncReadinessStatus.disabledByFeatureFlag;
    final firebaseRuntimeSummary = _firebaseRuntimeSummary(
      context,
      firebaseRuntimeConfig,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          AppReveal(
            child: _SettingsSection(
              title: l10n.settingsSectionGeneral,
              children: [
                _SettingsTile(
                  icon: Icons.palette,
                  title: l10n.settingsThemeTitle,
                  subtitle: themeSummary,
                  onTap: () => _showThemeSelector(context, ref),
                ),
                _SettingsTile(
                  icon: Icons.language,
                  title: l10n.settingsLanguageTitle,
                  subtitle: languageSummary,
                  onTap: () => _showLanguageSelector(context, ref),
                ),
                _SettingsTile(
                  icon: Icons.insights_outlined,
                  title: l10n.settingsAnalyticsTitle,
                  subtitle: analyticsSummary,
                  onTap: () => _showAnalyticsSettings(context, ref),
                ),
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Account',
                  subtitle: accountSummary,
                  enabled: accountFeatureEnabled,
                  onTap: accountFeatureEnabled
                      ? () => context.push(Routes.auth)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppReveal(
            delay: AppMotion.stagger,
            child: _FirebaseRuntimeHealthCard(config: firebaseRuntimeConfig),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger * 2,
            child: _SettingsSection(
              title: l10n.settingsSectionData,
              children: [
                _SettingsTile(
                  icon: Icons.file_download,
                  title: l10n.settingsExportJsonTitle,
                  subtitle: l10n.settingsExportJsonSubtitle,
                  onTap: () => _handleExportJson(context, ref),
                ),
                _SettingsTile(
                  icon: Icons.table_chart,
                  title: l10n.settingsExportCsvTitle,
                  subtitle: l10n.settingsExportCsvSubtitle,
                  onTap: () => _handleExportCsv(context, ref),
                ),
                _SettingsTile(
                  icon: Icons.file_upload,
                  title: l10n.settingsImportJsonTitle,
                  subtitle: l10n.settingsImportJsonSubtitle,
                  onTap: () => _handleImportJson(context, ref),
                ),
                _SettingsTile(
                  icon: Icons.cloud_upload,
                  title: l10n.settingsCloudSyncTitle,
                  subtitle: cloudSyncSummary,
                  enabled: cloudSyncFeatureEnabled,
                  onTap: cloudSyncFeatureEnabled
                      ? () => _showCloudSyncStatusSheet(context, ref)
                      : null,
                ),
                _SettingsTile(
                  icon: Icons.sell_outlined,
                  title: l10n.settingsManageTagsTitle,
                  subtitle: l10n.settingsManageTagsSubtitle,
                  onTap: () => context.push('/settings/tags'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger * 3,
            child: _SettingsSection(
              title: l10n.settingsSectionAbout,
              children: [
                _SettingsTile(
                  icon: Icons.info,
                  title: l10n.settingsVersionTitle,
                  subtitle: '1.0.0',
                ),
                _SettingsTile(
                  icon: Icons.description,
                  title: l10n.settingsPrivacyPolicyTitle,
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.gavel,
                  title: l10n.settingsTermsTitle,
                  onTap: () {},
                ),
              ],
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.lg),
            AppReveal(
              delay: AppMotion.stagger * 4,
              child: _SettingsSection(
                title: l10n.settingsSectionDeveloper,
                children: [
                  _SettingsTile(
                    icon: Icons.settings_remote_outlined,
                    title: l10n.settingsFirebaseRuntimeConfigTitle,
                    subtitle: firebaseRuntimeSummary,
                    onTap: () => _showFirebaseRuntimeConfigSheet(context, ref),
                  ),
                  _SettingsTile(
                    icon: Icons.cloud_sync_outlined,
                    title: 'Cloud Sync Diagnostics',
                    subtitle: 'Debug sync transport and auth readiness',
                    onTap: () => _showCloudSyncDiagnosticsSheet(context, ref),
                  ),
                  _SettingsTile(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Operational Telemetry',
                    subtitle: 'Inspect recent sync/data/runtime events',
                    onTap: () => _showOperationalTelemetrySheet(context, ref),
                  ),
                  _SettingsTile(
                    icon: Icons.bug_report_outlined,
                    title: l10n.settingsCrashlyticsTestTitle,
                    subtitle: l10n.settingsCrashlyticsTestSubtitle,
                    onTap: () => _handleCrashlyticsTest(context),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleExportJson(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsExportingData)),
      );

      final filePath = await ref
          .read(exportImportViewModelProvider.notifier)
          .exportAllDataToJson();

      final exportService = ExportImportService();
      await exportService.shareFile(filePath, 'collection_tracker_export.json');

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.settingsDataExportSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsExportFailed('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleExportCsv(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsExportingData)),
      );

      final filePath = await ref
          .read(exportImportViewModelProvider.notifier)
          .exportItemsToCsv();

      final exportService = ExportImportService();
      await exportService.shareFile(filePath, 'collection_tracker_export.csv');

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.settingsDataExportSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsExportFailed('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleImportJson(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: Text(l10n.settingsImportDataTitle),
      content: Text(l10n.settingsImportDataMessage),
      actions: [
        AppButton(
          label: l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context, false),
        ),
        AppButton(
          label: l10n.actionImport,
          onPressed: () => closeAppDialog(context, true),
        ),
      ],
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsImportingData)),
      );

      await ref.read(exportImportViewModelProvider.notifier).importFromJson();

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.settingsDataImportSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsImportFailed('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _cloudSyncSummary(
    SyncReadinessState readiness, {
    required int pendingSyncCount,
  }) {
    return switch (readiness.status) {
      SyncReadinessStatus.ready =>
        pendingSyncCount > 0
            ? 'Ready • $pendingSyncCount pending change(s)'
            : 'Ready',
      SyncReadinessStatus.disabledByFeatureFlag => 'Unavailable',
      SyncReadinessStatus.missingApiConfiguration => 'Configuration required',
      SyncReadinessStatus.checkingAuthentication => 'Checking session...',
      SyncReadinessStatus.authenticationRequired => 'Sign in required',
    };
  }

  String _authAccountSummary(
    AuthSession? session,
    BackendApiReadiness readiness,
  ) {
    if (!readiness.enabled) {
      final message = readiness.message.toLowerCase();
      if (message.contains('missing') || message.contains('configure')) {
        return 'Configuration required';
      }
      return 'Unavailable';
    }
    if (session == null || !session.isAuthenticated) {
      return 'Not signed in';
    }
    return 'Signed in';
  }

  String _cloudSyncPrimaryCta(SyncReadinessStatus status) {
    return switch (status) {
      SyncReadinessStatus.ready => 'Sync now',
      SyncReadinessStatus.authenticationRequired => 'Sign in',
      SyncReadinessStatus.missingApiConfiguration => 'Configure API',
      SyncReadinessStatus.disabledByFeatureFlag => 'Feature disabled',
      SyncReadinessStatus.checkingAuthentication => 'Checking session',
    };
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

  Future<void> _showCloudSyncStatusSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showAppSheet(
      context: context,
      builder: (sheetContext) {
        return Consumer(
          builder: (sheetContext, ref, _) {
            final readiness = ref.watch(syncReadinessProvider);
            final pendingCount =
                ref.watch(syncOutboxCountProvider).asData?.value ?? 0;
            final isBusy =
                readiness.status == SyncReadinessStatus.checkingAuthentication;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sheetContext.l10n.settingsCloudSyncTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _cloudSyncSummary(readiness, pendingSyncCount: pendingCount),
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: _cloudSyncPrimaryCta(readiness.status),
                  onPressed: isBusy
                      ? null
                      : () => _handleCloudSyncPrimaryAction(
                          context: context,
                          sheetContext: sheetContext,
                          ref: ref,
                          readiness: readiness,
                        ),
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
      },
    );
  }

  Future<void> _handleCloudSyncPrimaryAction({
    required BuildContext context,
    required BuildContext sheetContext,
    required WidgetRef ref,
    required SyncReadinessState readiness,
  }) async {
    switch (readiness.status) {
      case SyncReadinessStatus.ready:
        await _triggerSyncNow(context, ref);
        return;
      case SyncReadinessStatus.authenticationRequired:
        Navigator.of(sheetContext).pop();
        if (!context.mounted) return;
        await context.push<bool>('${Routes.auth}?mode=signin');
        return;
      case SyncReadinessStatus.missingApiConfiguration:
        Navigator.of(sheetContext).pop();
        await _showSyncApiConfigurationHelp(context, ref);
        return;
      case SyncReadinessStatus.disabledByFeatureFlag:
        return;
      case SyncReadinessStatus.checkingAuthentication:
        return;
    }
  }

  Future<void> _triggerSyncNow(BuildContext context, WidgetRef ref) async {
    final readiness = ref.read(syncReadinessProvider);
    final pendingBefore = await ref
        .read(syncOrchestratorProvider)
        .getPendingOperationCount();
    await OperationalTelemetry.trackSyncAttempt(
      trigger: 'settings_manual_sync',
      readinessStatus: readiness.status.name,
      pendingBefore: pendingBefore,
    );

    final session = ref.read(authSessionProvider).asData?.value;
    final deviceId = session?.deviceId;
    if (deviceId == null || deviceId.trim().isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing device id. Sign in again to enable sync.'),
        ),
      );
      return;
    }

    final bootstrapResult = await ref
        .read(syncOutboxBootstrapperProvider)
        .seedFromLocalDataIfNeeded();
    await OperationalTelemetry.trackSyncSeed(
      queuedOperations: bootstrapResult.totalOperations,
      skipped: bootstrapResult.skipped,
    );

    final result = await ref
        .read(syncOrchestratorProvider)
        .syncNow(deviceId: deviceId);
    await OperationalTelemetry.trackSyncResult(
      success: result.success,
      executed: result.executed,
      partial: result.partial,
      pendingOperations: result.pendingOperations,
      processedOperations: result.processedOperations,
      syncedCollections: result.syncedCollections,
      syncedItems: result.syncedItems,
      syncedTags: result.syncedTags,
      conflictCount: result.conflictCount,
      appliedServerCollections: result.appliedServerCollections,
      appliedServerItems: result.appliedServerItems,
      appliedServerTags: result.appliedServerTags,
      skippedServerCollections: result.skippedServerCollections,
      skippedServerItems: result.skippedServerItems,
      skippedServerTags: result.skippedServerTags,
      message: result.message,
      error: result.error,
      stackTrace: result.stackTrace,
    );

    if (!context.mounted) return;
    final bootstrapMessage = bootstrapResult.totalOperations > 0
        ? 'Prepared ${bootstrapResult.totalOperations} local change(s). '
        : '';
    final recoveryHint = bootstrapResult.skipped && !result.executed
        ? ' If existing local data is missing on cloud, open Cloud Sync Diagnostics and use "Rebuild local sync queue".'
        : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$bootstrapMessage${result.message}$recoveryHint'),
        backgroundColor: result.success ? Colors.green : Colors.orange,
      ),
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

      if (!context.mounted) return;
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
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to rebuild local sync queue: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                if (!sheetContext.mounted) return;
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
                if (!sheetContext.mounted) return;
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
                if (!transportConfig.isApiBaseUrlConfigured) ...[
                  AppButton(
                    label: 'Configure API',
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await _showSyncApiConfigurationHelp(context, ref);
                    },
                    expand: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
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

  Future<void> _showThemeSelector(BuildContext context, WidgetRef ref) async {
    await showAppSheet(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final settings = ref.watch(themeSettingsProvider);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.settingsThemeModeTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: ThemeMode.values.map((mode) {
                    final isSelected = settings.mode == mode;
                    return ChoiceChip(
                      label: Text(_themeModeLabel(context, mode)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (!selected) return;
                        ref
                            .read(themeSettingsProvider.notifier)
                            .setThemeMode(mode);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  context.l10n.settingsThemeColorVariantTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppThemeVariant.values.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final variant = AppThemeVariant.values[index];
                      final isSelected = settings.variant == variant;
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(themeSettingsProvider.notifier)
                              .setThemeVariant(variant);
                        },
                        child: AnimatedContainer(
                          duration: AppMotion.fast,
                          curve: AppMotion.emphasized,
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: variant.color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.settingsAmoledTitle),
                  subtitle: Text(context.l10n.settingsAmoledSubtitle),
                  value: settings.amoled,
                  onChanged: (value) {
                    ref.read(themeSettingsProvider.notifier).setAmoled(value);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAnalyticsSettings(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showAppSheet(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final l10n = context.l10n;
            final preferences = ref.watch(analyticsPreferencesProvider);
            final notifier = ref.read(analyticsPreferencesProvider.notifier);
            final consentLabel = switch (preferences.consentStatus) {
              AnalyticsConsentStatus.granted =>
                l10n.settingsAnalyticsConsentStatusGranted,
              AnalyticsConsentStatus.denied =>
                l10n.settingsAnalyticsConsentStatusDenied,
              AnalyticsConsentStatus.unknown =>
                l10n.settingsAnalyticsConsentStatusPending,
            };

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsAnalyticsSheetTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.settingsAnalyticsDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsAnalyticsToggleTitle),
                  subtitle: Text(l10n.settingsAnalyticsToggleSubtitle),
                  value: preferences.enabled,
                  onChanged: (value) {
                    notifier.setEnabled(value);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.settingsAnalyticsConsentStatusTitle),
                  subtitle: Text(consentLabel),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (preferences.enabled &&
                        preferences.consentStatus !=
                            AnalyticsConsentStatus.granted)
                      AppButton(
                        label: l10n.settingsAnalyticsReviewConsentAction,
                        onPressed: () async {
                          final decision = await showAnalyticsConsentDialog(
                            context,
                            barrierDismissible: true,
                          );
                          if (!context.mounted) return;
                          if (decision == AnalyticsConsentDecision.allow) {
                            await notifier.grantConsent();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.settingsAnalyticsConsentAccepted,
                                  ),
                                ),
                              );
                            }
                          } else {
                            await notifier.denyConsent();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.settingsAnalyticsConsentDeclined,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    if (preferences.consentStatus ==
                        AnalyticsConsentStatus.granted)
                      AppButton(
                        label: l10n.settingsAnalyticsRevokeConsentAction,
                        variant: AppButtonVariant.ghost,
                        onPressed: () async {
                          await notifier.denyConsent();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.settingsAnalyticsConsentDeclined,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ],
            );
          },
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
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final l10n = context.l10n;
            final runtimeConfig = ref.watch(firebaseRuntimeConfigProvider);
            final remoteConfigStatus = ref.watch(
              firebaseRemoteConfigStatusProvider,
            );
            final isRefreshing = ref.watch(
              firebaseRuntimeConfigRefreshInProgressProvider,
            );
            final lastFetchTimeText = _lastFetchTimeLabel(
              context,
              remoteConfigStatus.lastFetchTime,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsFirebaseRuntimeConfigSheetTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.settingsFirebaseRuntimeConfigDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                      context,
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
                      context,
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
                      context,
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
                      context,
                      runtimeConfig.appCheckEnabled,
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
                      context,
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
                      context,
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
                      context,
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
                      context,
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
                      : () => _refreshFirebaseRuntimeConfig(context, ref),
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

    if (shouldCrash != true || !context.mounted) return;

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
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsCrashlyticsTestFailed('$error')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showLanguageSelector(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showAppSheet(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final selectedLanguage = ref.watch(localeSettingsProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.settingsLanguageTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...AppLanguage.values.map((language) {
                  final selected = selectedLanguage == language;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_languageLabel(context, language)),
                    trailing: selected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      ref
                          .read(localeSettingsProvider.notifier)
                          .setLanguage(language);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  String _themeModeLabel(BuildContext context, ThemeMode mode) {
    final l10n = context.l10n;
    return switch (mode) {
      ThemeMode.system => l10n.themeModeSystem,
      ThemeMode.light => l10n.themeModeLight,
      ThemeMode.dark => l10n.themeModeDark,
    };
  }

  String _languageLabel(BuildContext context, AppLanguage language) {
    final l10n = context.l10n;
    return switch (language) {
      AppLanguage.system => l10n.languageSystem,
      AppLanguage.english => l10n.languageEnglish,
      AppLanguage.spanish => l10n.languageSpanish,
      AppLanguage.indonesian => l10n.languageIndonesian,
      AppLanguage.japanese => l10n.languageJapanese,
      AppLanguage.korean => l10n.languageKorean,
      AppLanguage.chineseSimplified => l10n.languageChineseSimplified,
      AppLanguage.burmese => l10n.languageBurmese,
    };
  }

  String _analyticsSummary(
    BuildContext context,
    AnalyticsPreferences preferences,
  ) {
    final l10n = context.l10n;
    if (!preferences.enabled) {
      return l10n.settingsAnalyticsSummaryDisabled;
    }

    return switch (preferences.consentStatus) {
      AnalyticsConsentStatus.granted => l10n.settingsAnalyticsSummaryEnabled,
      AnalyticsConsentStatus.denied => l10n.settingsAnalyticsSummaryDenied,
      AnalyticsConsentStatus.unknown => l10n.settingsAnalyticsSummaryPending,
    };
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
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: _withDividers(context, children)),
        ),
      ],
    );
  }

  static List<Widget> _withDividers(BuildContext context, List<Widget> items) {
    if (items.isEmpty) return const [];
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i < items.length - 1) {
        out.add(
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        );
      }
    }
    return out;
  }
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && onTap != null;

    return ListTile(
      enabled: enabled,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: canTap
          ? Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : (!enabled
                ? Icon(
                    Icons.lock_outline_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )
                : null),
      onTap: canTap ? onTap : null,
    );
  }
}

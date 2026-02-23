import 'package:app_firebase/app_firebase.dart';
import 'package:auth_session/auth_session.dart';
import 'package:collection_tracker/core/analytics/analytics_consent_dialog.dart';
import 'package:collection_tracker/core/analytics/analytics_preferences.dart';
import 'package:collection_tracker/core/observability/operational_telemetry.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:collection_tracker/core/router/routes.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storage/storage.dart';
import 'package:ui/ui.dart';

import '../view_models/export_import_view_model.dart';
import '../widgets/settings_primitives.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeSettings = ref.watch(themeSettingsProvider);
    final currentLanguage = ref.watch(localeSettingsProvider);
    final analyticsPreferences = ref.watch(analyticsPreferencesProvider);
    final pushPreferences = ref.watch(pushNotificationPreferencesProvider);
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
    final pushSummary = _pushNotificationSummary(pushPreferences);
    final cloudSyncFeatureEnabled =
        syncReadiness.status != SyncReadinessStatus.disabledByFeatureFlag;

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
            child: SettingsStatusCard(
              title: l10n.settingsTitle,
              firstLabel: l10n.settingsCloudSyncTitle,
              secondLabel: 'Push',
              syncStatus: cloudSyncSummary,
              notificationStatus: pushSummary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger,
            child: SettingsSection(
              title: l10n.settingsSectionGeneral,
              children: [
                SettingsTile(
                  icon: Icons.palette,
                  title: l10n.settingsThemeTitle,
                  subtitle: themeSummary,
                  onTap: () => _showThemeSelector(context, ref),
                ),
                SettingsTile(
                  icon: Icons.language,
                  title: l10n.settingsLanguageTitle,
                  subtitle: languageSummary,
                  onTap: () => _showLanguageSelector(context, ref),
                ),
                SettingsTile(
                  icon: Icons.insights_outlined,
                  title: l10n.settingsAnalyticsTitle,
                  subtitle: analyticsSummary,
                  onTap: () => _showAnalyticsSettings(context, ref),
                ),
                if (accountFeatureEnabled)
                  SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Account',
                    subtitle: accountSummary,
                    onTap: () => context.push(Routes.auth),
                  ),
                SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: pushSummary,
                  onTap: () => context.push(Routes.settingsNotifications),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger * 2,
            child: SettingsSection(
              title: l10n.settingsSectionData,
              children: [
                SettingsTile(
                  icon: Icons.file_download,
                  title: l10n.settingsExportJsonTitle,
                  subtitle: l10n.settingsExportJsonSubtitle,
                  onTap: () => _handleExportJson(context, ref),
                ),
                SettingsTile(
                  icon: Icons.table_chart,
                  title: l10n.settingsExportCsvTitle,
                  subtitle: l10n.settingsExportCsvSubtitle,
                  onTap: () => _handleExportCsv(context, ref),
                ),
                SettingsTile(
                  icon: Icons.file_upload,
                  title: l10n.settingsImportJsonTitle,
                  subtitle: l10n.settingsImportJsonSubtitle,
                  onTap: () => _handleImportJson(context, ref),
                ),
                SettingsTile(
                  icon: Icons.cloud_upload,
                  title: l10n.settingsCloudSyncTitle,
                  subtitle: cloudSyncSummary,
                  enabled: cloudSyncFeatureEnabled,
                  onTap: cloudSyncFeatureEnabled
                      ? () => _showCloudSyncStatusSheet(context, ref)
                      : null,
                ),
                SettingsTile(
                  icon: Icons.sell_outlined,
                  title: l10n.settingsManageTagsTitle,
                  subtitle: l10n.settingsManageTagsSubtitle,
                  onTap: () => context.push(Routes.settingsTags),
                ),
                SettingsTile(
                  icon: Icons.handshake_outlined,
                  title: l10n.settingsLoanTrackingTitle,
                  subtitle: l10n.settingsLoanTrackingSubtitle,
                  onTap: () => context.push(Routes.settingsLoans),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger * 3,
            child: SettingsSection(
              title: l10n.settingsSectionAbout,
              children: [
                SettingsTile(
                  icon: Icons.info,
                  title: l10n.settingsVersionTitle,
                  subtitle: '1.0.0',
                ),
              ],
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.lg),
            AppReveal(
              delay: AppMotion.stagger * 4,
              child: SettingsSection(
                title: l10n.settingsSectionDeveloper,
                children: [
                  SettingsTile(
                    icon: Icons.developer_mode_outlined,
                    title: '${l10n.settingsSectionDeveloper} Tools',
                    subtitle: 'Runtime flags, diagnostics, and crash testing',
                    onTap: () => context.push(Routes.settingsDevtools),
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

      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsDataExportSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsExportFailed('$error')),
          backgroundColor: Colors.red,
        ),
      );
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

      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsDataExportSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsExportFailed('$error')),
          backgroundColor: Colors.red,
        ),
      );
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

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsImportingData)),
      );

      await ref.read(exportImportViewModelProvider.notifier).importFromJson();

      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsDataImportSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsImportFailed('$error')),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                if (kDebugMode) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label:
                        '${sheetContext.l10n.settingsSectionDeveloper} Tools',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      if (!context.mounted) {
                        return;
                      }
                      context.push(Routes.settingsDevtools);
                    },
                  ),
                ],
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
        if (!context.mounted) {
          return;
        }
        await context.push<bool>('${Routes.auth}?mode=signin');
        return;
      case SyncReadinessStatus.missingApiConfiguration:
        Navigator.of(sheetContext).pop();
        if (!context.mounted) {
          return;
        }
        if (kDebugMode) {
          context.push(Routes.settingsDevtools);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cloud sync is currently unavailable.'),
            ),
          );
        }
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
      if (!context.mounted) {
        return;
      }
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
      syncedLoans: result.syncedLoans,
      conflictCount: result.conflictCount,
      appliedServerCollections: result.appliedServerCollections,
      appliedServerItems: result.appliedServerItems,
      appliedServerTags: result.appliedServerTags,
      appliedServerLoans: result.appliedServerLoans,
      skippedServerCollections: result.skippedServerCollections,
      skippedServerItems: result.skippedServerItems,
      skippedServerTags: result.skippedServerTags,
      skippedServerLoans: result.skippedServerLoans,
      message: result.message,
      error: result.error,
      stackTrace: result.stackTrace,
    );

    if (!context.mounted) {
      return;
    }
    final bootstrapMessage = bootstrapResult.totalOperations > 0
        ? 'Prepared ${bootstrapResult.totalOperations} local change(s). '
        : '';
    final recoveryHint = bootstrapResult.skipped && !result.executed
        ? kDebugMode
              ? ' If existing local data is missing on cloud, open Developer Tools and use "Rebuild local sync queue".'
              : ''
        : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$bootstrapMessage${result.message}$recoveryHint'),
        backgroundColor: result.success ? Colors.green : Colors.orange,
      ),
    );
  }

  Future<void> _showThemeSelector(BuildContext context, WidgetRef ref) async {
    await showAppSheet(
      context: context,
      builder: (sheetContext) {
        return Consumer(
          builder: (sheetContext, ref, _) {
            final settings = ref.watch(themeSettingsProvider);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sheetContext.l10n.settingsThemeModeTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
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
                      label: Text(_themeModeLabel(sheetContext, mode)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (!selected) {
                          return;
                        }
                        ref
                            .read(themeSettingsProvider.notifier)
                            .setThemeMode(mode);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  sheetContext.l10n.settingsThemeColorVariantTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
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
                                      sheetContext,
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
                  title: Text(sheetContext.l10n.settingsAmoledTitle),
                  subtitle: Text(sheetContext.l10n.settingsAmoledSubtitle),
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

  Future<void> _showLanguageSelector(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showAppSheet(
      context: context,
      builder: (sheetContext) {
        return Consumer(
          builder: (sheetContext, ref, _) {
            final selectedLanguage = ref.watch(localeSettingsProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sheetContext.l10n.settingsLanguageTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...AppLanguage.values.map((language) {
                  final selected = selectedLanguage == language;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_languageLabel(sheetContext, language)),
                    trailing: selected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(sheetContext).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      ref
                          .read(localeSettingsProvider.notifier)
                          .setLanguage(language);
                      Navigator.pop(sheetContext);
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

  Future<void> _showAnalyticsSettings(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showAppSheet(
      context: context,
      builder: (sheetContext) {
        return Consumer(
          builder: (sheetContext, ref, _) {
            final l10n = sheetContext.l10n;
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
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.settingsAnalyticsDescription,
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
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
                            sheetContext,
                            barrierDismissible: true,
                          );
                          if (!sheetContext.mounted) {
                            return;
                          }
                          if (decision == AnalyticsConsentDecision.allow) {
                            await notifier.grantConsent();
                            if (sheetContext.mounted) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.settingsAnalyticsConsentAccepted,
                                  ),
                                ),
                              );
                            }
                          } else {
                            await notifier.denyConsent();
                            if (sheetContext.mounted) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
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
                          if (sheetContext.mounted) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
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
      SyncReadinessStatus.missingApiConfiguration =>
        kDebugMode ? 'Open dev tools' : 'Unavailable',
      SyncReadinessStatus.disabledByFeatureFlag => 'Feature disabled',
      SyncReadinessStatus.checkingAuthentication => 'Checking session',
    };
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

  String _pushNotificationSummary(
    PushNotificationPreferencesState preferences,
  ) {
    if (!preferences.runtimeFeatureEnabled) {
      return 'Feature disabled';
    }
    if (!preferences.preferenceEnabled) {
      return 'Disabled';
    }
    if (!preferences.permissionStatus.isGranted) {
      return 'Permission required';
    }

    final enabledTopics = [
      preferences.syncNeededEnabled,
      preferences.priceAlertsEnabled,
      preferences.remindersEnabled,
      preferences.accountSecurityEnabled,
    ].where((enabled) => enabled).length;

    return 'Enabled ($enabledTopics topics)';
  }
}

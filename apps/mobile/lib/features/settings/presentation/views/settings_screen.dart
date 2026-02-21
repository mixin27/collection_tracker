import 'package:app_logger/app_logger.dart';
import 'package:collection_tracker/core/analytics/analytics_consent_dialog.dart';
import 'package:collection_tracker/core/analytics/analytics_preferences.dart';
import 'package:collection_tracker/core/providers/providers.dart';
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
    final themeSummary =
        '${_themeModeLabel(context, themeSettings.mode)} - ${themeSettings.variant.label}';
    final languageSummary = _languageLabel(context, currentLanguage);
    final analyticsSummary = _analyticsSummary(context, analyticsPreferences);

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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger,
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
                  subtitle: l10n.settingsCloudSyncSubtitle,
                  onTap: () {},
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
            delay: AppMotion.stagger * 2,
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
              delay: AppMotion.stagger * 3,
              child: _SettingsSection(
                title: l10n.settingsSectionDeveloper,
                children: [
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : null,
      onTap: onTap,
    );
  }
}

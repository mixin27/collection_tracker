import 'package:collection_tracker/core/providers/providers.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../../domain/app_update_models.dart';
import '../providers/app_update_providers.dart';
import '../../../settings/presentation/widgets/settings_primitives.dart';

class SettingsAppUpdateScreen extends ConsumerWidget {
  const SettingsAppUpdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appUpdateControllerProvider);
    final notifier = ref.read(appUpdateControllerProvider.notifier);
    final runtimeEnabled = ref.watch(appUpdateFeatureFlagProvider);
    final displayVersion = ref.watch(appDisplayVersionProvider);
    final result = state.lastResult;

    return Scaffold(
      appBar: AppBar(title: const Text('App Update')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          AppReveal(
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    runtimeEnabled
                        ? 'Keep your app secure and up to date.'
                        : 'Update checks are disabled by runtime configuration.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      state.errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger,
            child: SettingsSection(
              title: context.l10n.settingsSectionAbout,
              children: [
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: context.l10n.settingsVersionTitle,
                  subtitle: displayVersion,
                ),
                SettingsTile(
                  icon: Icons.system_update_alt_rounded,
                  title: 'Update Status',
                  subtitle: _statusLabel(result),
                ),
                if (result?.latestVersion != null)
                  SettingsTile(
                    icon: Icons.new_releases_outlined,
                    title: 'Latest Version',
                    subtitle: result!.latestVersion,
                  ),
                if (result?.minSupportedVersion != null)
                  SettingsTile(
                    icon: Icons.security_update_warning_rounded,
                    title: 'Minimum Supported',
                    subtitle: result!.minSupportedVersion,
                  ),
                if (result?.storeUrl != null)
                  SettingsTile(
                    icon: Icons.storefront_outlined,
                    title: 'Store Link',
                    subtitle: result!.storeUrl,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger * 2,
            child: AppButton(
              label: state.isChecking
                  ? 'Checking...'
                  : context.l10n.actionRefresh,
              onPressed: state.isChecking
                  ? null
                  : () async {
                      final checked = await notifier.checkNow();
                      if (!context.mounted) {
                        return;
                      }
                      final statusMessage = _statusLabel(checked);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(statusMessage)));
                    },
            ),
          ),
          if (result != null && result.hasStoreUrl && result.hasUpdate) ...[
            const SizedBox(height: AppSpacing.sm),
            AppReveal(
              delay: AppMotion.stagger * 3,
              child: AppButton(
                label: result.isForceUpdate ? 'Update Required' : 'Update Now',
                variant: result.isForceUpdate
                    ? AppButtonVariant.danger
                    : AppButtonVariant.primary,
                onPressed: () async {
                  final opened = await notifier.openStore(result);
                  if (!context.mounted) {
                    return;
                  }
                  if (!opened) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to open store link.'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
          if (result != null && result.canSnooze && !result.isForceUpdate) ...[
            const SizedBox(height: AppSpacing.sm),
            AppReveal(
              delay: AppMotion.stagger * 4,
              child: AppButton(
                label: result.status == AppUpdateStatus.deferred
                    ? 'Clear Reminder'
                    : 'Remind Me Later',
                variant: AppButtonVariant.secondary,
                onPressed: () async {
                  if (result.status == AppUpdateStatus.deferred) {
                    await notifier.clearSnooze();
                  } else {
                    await notifier.snoozeCurrent(hours: result.snoozeHours);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(AppUpdateResult? result) {
    if (result == null) {
      return 'Tap refresh to check';
    }

    return switch (result.status) {
      AppUpdateStatus.upToDate => 'App is up to date',
      AppUpdateStatus.updateAvailable => 'Update available',
      AppUpdateStatus.updateRequired => 'Update required',
      AppUpdateStatus.deferred => 'Update deferred',
      AppUpdateStatus.disabled => 'Disabled by runtime config',
      AppUpdateStatus.notConfigured => 'No update policy configured',
      AppUpdateStatus.error => 'Update check failed',
    };
  }
}

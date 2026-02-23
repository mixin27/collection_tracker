import 'package:app_firebase/app_firebase.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../widgets/settings_primitives.dart';

class SettingsNotificationsScreen extends ConsumerWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(pushNotificationPreferencesProvider);
    final notifier = ref.read(pushNotificationPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Push Notifications')),
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
              child: Text(
                preferences.runtimeFeatureEnabled
                    ? 'Manage sync-needed, price alert, reminder, and account security notifications.'
                    : 'Push notifications are currently disabled by runtime feature flag.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger,
            child: SettingsSection(
              title: 'Preferences',
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  title: const Text('Enable push notifications'),
                  subtitle: Text(
                    _pushPermissionLabel(preferences.permissionStatus),
                  ),
                  value: preferences.preferenceEnabled,
                  onChanged: preferences.runtimeFeatureEnabled
                      ? (value) async {
                          await notifier.setPreferenceEnabled(value);
                          if (!context.mounted) {
                            return;
                          }
                          final updated = ref.read(
                            pushNotificationPreferencesProvider,
                          );
                          if (value && !updated.preferenceEnabled) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Notification permission is not granted.',
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger * 2,
            child: SettingsSection(
              title: 'Notification Types',
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  title: const Text('Sync needed'),
                  subtitle: const Text('When your local data should be synced'),
                  value: preferences.syncNeededEnabled,
                  onChanged: preferences.isEffectivelyEnabled
                      ? (value) {
                          notifier.setTopicEnabled(
                            PushNotificationTopic.syncNeeded,
                            value,
                          );
                        }
                      : null,
                ),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  title: const Text('Price alerts'),
                  subtitle: const Text('When tracked item prices change'),
                  value: preferences.priceAlertsEnabled,
                  onChanged: preferences.isEffectivelyEnabled
                      ? (value) {
                          notifier.setTopicEnabled(
                            PushNotificationTopic.priceAlerts,
                            value,
                          );
                        }
                      : null,
                ),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  title: const Text('Reminders'),
                  subtitle: const Text('Scheduled reminders and nudges'),
                  value: preferences.remindersEnabled,
                  onChanged: preferences.isEffectivelyEnabled
                      ? (value) {
                          notifier.setTopicEnabled(
                            PushNotificationTopic.reminders,
                            value,
                          );
                        }
                      : null,
                ),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  title: const Text('Account security'),
                  subtitle: const Text('Important account and session events'),
                  value: preferences.accountSecurityEnabled,
                  onChanged: preferences.isEffectivelyEnabled
                      ? (value) {
                          notifier.setTopicEnabled(
                            PushNotificationTopic.accountSecurity,
                            value,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger * 3,
            child: AppButton(
              label: preferences.isApplying
                  ? 'Refreshing...'
                  : context.l10n.actionRefresh,
              onPressed: preferences.isApplying
                  ? null
                  : () => notifier.refreshPermissionStatus(),
            ),
          ),
        ],
      ),
    );
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
}

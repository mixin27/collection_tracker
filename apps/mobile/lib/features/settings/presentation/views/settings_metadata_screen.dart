import 'package:collection_tracker/core/providers/metadata_preferences_provider.dart';
import 'package:collection_tracker/core/providers/metadata_providers.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../widgets/settings_primitives.dart';

class SettingsMetadataScreen extends ConsumerWidget {
  const SettingsMetadataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final preferences = ref.watch(metadataPreferencesProvider);
    final notifier = ref.read(metadataPreferencesProvider.notifier);
    final metadataService = ref.read(metadataLookupServiceProvider);

    final canConfigure = preferences.runtimeFeatureEnabled;
    final canTuneAutofill = preferences.isEnabled;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsMetadataTitle)),
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
                _statusMessage(context, preferences),
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
              title: l10n.settingsSectionGeneral,
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  title: Text(l10n.settingsMetadataEnableToggleTitle),
                  subtitle: Text(l10n.settingsMetadataEnableToggleSubtitle),
                  value: preferences.preferenceEnabled,
                  onChanged: canConfigure
                      ? notifier.setPreferenceEnabled
                      : null,
                ),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  title: Text(l10n.settingsMetadataAutoFetchToggleTitle),
                  subtitle: Text(l10n.settingsMetadataAutoFetchToggleSubtitle),
                  value: preferences.autoFetchBarcodeEnabled,
                  onChanged: canTuneAutofill
                      ? notifier.setAutoFetchBarcodeEnabled
                      : null,
                ),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  title: Text(l10n.settingsMetadataFillEmptyOnlyToggleTitle),
                  subtitle: Text(
                    l10n.settingsMetadataFillEmptyOnlyToggleSubtitle,
                  ),
                  value: preferences.fillOnlyEmptyFields,
                  onChanged: canTuneAutofill
                      ? notifier.setFillOnlyEmptyFields
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger * 2,
            child: SettingsSection(
              title: l10n.settingsMetadataSourcesSectionTitle,
              children: [
                _MetadataSourceTile(
                  icon: Icons.menu_book_rounded,
                  title: l10n.collectionTypeBooks,
                  source: 'Google Books',
                  statusText: l10n.settingsMetadataSourceAvailable,
                  enabled: true,
                ),
                _MetadataSourceTile(
                  icon: Icons.sports_esports_rounded,
                  title: l10n.collectionTypeGames,
                  source: 'IGDB',
                  statusText:
                      metadataService.supportsSearch(CollectionType.game)
                      ? l10n.settingsMetadataSourceAvailable
                      : l10n.settingsMetadataSourceNotConfigured,
                  enabled: metadataService.supportsSearch(CollectionType.game),
                ),
                _MetadataSourceTile(
                  icon: Icons.movie_creation_rounded,
                  title: l10n.collectionTypeMovies,
                  source: 'TMDB',
                  statusText:
                      metadataService.supportsSearch(CollectionType.movie)
                      ? l10n.settingsMetadataSourceAvailable
                      : l10n.settingsMetadataSourceNotConfigured,
                  enabled: metadataService.supportsSearch(CollectionType.movie),
                ),
                _MetadataSourceTile(
                  icon: Icons.category_rounded,
                  title: l10n.collectionTypeCustom,
                  source: l10n.settingsMetadataManualCollectionsLabel,
                  statusText: l10n.settingsMetadataSourceManualOnly,
                  enabled: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusMessage(
    BuildContext context,
    MetadataPreferencesState preferences,
  ) {
    final l10n = context.l10n;
    if (!preferences.runtimeFeatureEnabled) {
      return l10n.settingsMetadataSummaryFeatureDisabled;
    }
    if (!preferences.preferenceEnabled) {
      return l10n.settingsMetadataSummaryDisabled;
    }
    return l10n.settingsMetadataSummaryEnabled;
  }
}

class _MetadataSourceTile extends StatelessWidget {
  const _MetadataSourceTile({
    required this.icon,
    required this.title,
    required this.source,
    required this.statusText,
    required this.enabled,
  });

  final IconData icon;
  final String title;
  final String source;
  final String statusText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = enabled ? colors.primary : colors.onSurfaceVariant;

    return ListTile(
      leading: Icon(icon, color: colors.primary),
      title: Text(title),
      subtitle: Text(source),
      trailing: Text(
        statusText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';
import 'package:ui/ui.dart';

import '../view_models/export_import_view_model.dart';
import '../widgets/settings_primitives.dart';

class SettingsDataTransferScreen extends ConsumerStatefulWidget {
  const SettingsDataTransferScreen({super.key});

  @override
  ConsumerState<SettingsDataTransferScreen> createState() =>
      _SettingsDataTransferScreenState();
}

class _SettingsDataTransferScreenState
    extends ConsumerState<SettingsDataTransferScreen> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.settingsExportJsonTitle} / ${l10n.settingsImportJsonTitle}',
        ),
      ),
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
                    l10n.settingsSectionData,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.settingsExportJsonSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.settingsImportJsonSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger,
            child: SettingsSection(
              title: l10n.settingsExportJsonTitle,
              children: [
                SettingsTile(
                  icon: Icons.file_download_outlined,
                  title: l10n.settingsExportJsonTitle,
                  subtitle: l10n.settingsExportJsonSubtitle,
                  enabled: !_isBusy,
                  onTap: _isBusy ? null : _handleExportJson,
                ),
                SettingsTile(
                  icon: Icons.table_chart_outlined,
                  title: l10n.settingsExportCsvTitle,
                  subtitle: l10n.settingsExportCsvSubtitle,
                  enabled: !_isBusy,
                  onTap: _isBusy ? null : _handleExportCsv,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: AppMotion.stagger * 2,
            child: SettingsSection(
              title: l10n.settingsImportJsonTitle,
              children: [
                SettingsTile(
                  icon: Icons.file_upload_outlined,
                  title: l10n.settingsImportJsonTitle,
                  subtitle: l10n.settingsImportJsonSubtitle,
                  enabled: !_isBusy,
                  onTap: _isBusy ? null : _handleImportJson,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportJson() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (_isBusy) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsExportingData)),
      );
      await ref
          .read(exportImportViewModelProvider.notifier)
          .exportAllDataToJson();
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsDataExportSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } on UserCancelledStorageOperationException {
      // User canceled picker/save dialog. Keep silent.
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsExportFailed('$error')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _handleExportCsv() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (_isBusy) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsExportingData)),
      );
      await ref.read(exportImportViewModelProvider.notifier).exportItemsToCsv();
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsDataExportSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } on UserCancelledStorageOperationException {
      // User canceled picker/save dialog. Keep silent.
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsExportFailed('$error')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _handleImportJson() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (_isBusy) {
      return;
    }

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

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsImportingData)),
      );
      await ref.read(exportImportViewModelProvider.notifier).importFromJson();
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsDataImportSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } on UserCancelledStorageOperationException {
      // User canceled picker/save dialog. Keep silent.
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsImportFailed('$error')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}

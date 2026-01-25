import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';

import '../view_models/export_import_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader(title: 'General'),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            onTap: () {
              // todo(mixin27): Implement theme selector
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            onTap: () {
              // todo(mixin27): Implement language selector
            },
          ),
          const Divider(),
          _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export to JSON'),
            subtitle: const Text('Export all data as JSON file'),
            onTap: () => _handleExportJson(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export to CSV'),
            subtitle: const Text('Export items as CSV spreadsheet'),
            onTap: () => _handleExportCsv(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Import from JSON'),
            subtitle: const Text('Import data from JSON file'),
            onTap: () => _handleImportJson(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Cloud Sync'),
            subtitle: const Text('Not configured'),
            onTap: () {
              // todo(mixin27): Implement cloud sync
            },
          ),
          const Divider(),
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Privacy Policy'),
            onTap: () {
              // todo(mixin27): Show privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Terms of Service'),
            onTap: () {
              // todo(mixin27): Show terms of service
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportJson(BuildContext context, WidgetRef ref) async {
    try {
      final messenger = ScaffoldMessenger.of(context);

      messenger.showSnackBar(
        const SnackBar(content: Text('Exporting data...')),
      );

      final filePath = await ref
          .read(exportImportViewModelProvider.notifier)
          .exportAllDataToJson();

      final exportService = ExportImportService();
      await exportService.shareFile(filePath, 'collection_tracker_export.json');

      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleExportCsv(BuildContext context, WidgetRef ref) async {
    try {
      final messenger = ScaffoldMessenger.of(context);

      messenger.showSnackBar(
        const SnackBar(content: Text('Exporting data...')),
      );

      final filePath = await ref
          .read(exportImportViewModelProvider.notifier)
          .exportItemsToCsv();

      final exportService = ExportImportService();
      await exportService.shareFile(filePath, 'collection_tracker_export.csv');

      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleImportJson(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'This will import collections and items from a JSON file. '
          'Existing data will not be deleted.\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final messenger = ScaffoldMessenger.of(context);

      messenger.showSnackBar(
        const SnackBar(content: Text('Importing data...')),
      );

      await ref.read(exportImportViewModelProvider.notifier).importFromJson();

      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Data imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

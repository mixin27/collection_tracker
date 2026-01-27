import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportImportService {
  // Export data to JSON
  Future<String> exportToJson(Map<String, dynamic> data) async {
    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = await _getExportFile(
        'collection_tracker_export_$timestamp.json',
      );
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export to JSON: $e');
    }
  }

  // Export data to CSV
  Future<String> exportToCsv(List<Map<String, dynamic>> items) async {
    try {
      if (items.isEmpty) {
        throw Exception('No data to export');
      }

      final headers = items.first.keys.toList();
      final csvLines = <String>[];

      // Add header row
      csvLines.add(headers.map((h) => _escapeCsvValue(h)).join(','));

      // Add data rows
      for (final item in items) {
        final row = headers
            .map((header) {
              final value = item[header]?.toString() ?? '';
              return _escapeCsvValue(value);
            })
            .join(',');
        csvLines.add(row);
      }

      final csvString = csvLines.join('\n');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = await _getExportFile(
        'collection_tracker_export_$timestamp.csv',
      );
      await file.writeAsString(csvString);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export to CSV: $e');
    }
  }

  Future<File> _getExportFile(String fileName) async {
    Directory? directory;
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      directory = await getDownloadsDirectory();
    } else if (Platform.isAndroid) {
      // Try to get the public downloads directory on Android
      final externalDirs = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (externalDirs != null && externalDirs.isNotEmpty) {
        directory = externalDirs.first;
      } else {
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      // getApplicationDocumentsDirectory is public if UIFileSharingEnabled is set in Info.plist
      directory = await getApplicationDocumentsDirectory();
    }

    directory ??= await getApplicationDocumentsDirectory();

    final filePath = '${directory.path}/$fileName';
    return File(filePath);
  }

  String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  // Share exported file
  Future<void> shareFile(String filePath, String fileName) async {
    try {
      final file = XFile(filePath);
      await SharePlus.instance.share(
        ShareParams(
          files: [file],
          subject: 'Collection Tracker Export',
          text: 'My collection data from Collection Tracker',
        ),
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  // Import from JSON
  Future<Map<String, dynamic>> importFromJson() async {
    try {
      final result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      return data;
    } catch (e) {
      throw Exception('Failed to import from JSON: $e');
    }
  }

  // Import from CSV
  Future<List<Map<String, dynamic>>> importFromCsv() async {
    try {
      final result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final file = File(result.files.first.path!);
      final csvString = await file.readAsString();

      final lines = csvString.split('\n');
      if (lines.isEmpty) {
        throw Exception('Empty CSV file');
      }

      final headers = _parseCsvLine(lines[0]);
      final data = <Map<String, dynamic>>[];

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;

        final values = _parseCsvLine(lines[i]);
        final row = <String, dynamic>{};

        for (int j = 0; j < headers.length && j < values.length; j++) {
          row[headers[j]] = values[j];
        }

        data.add(row);
      }

      return data;
    } catch (e) {
      throw Exception('Failed to import from CSV: $e');
    }
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        values.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    values.add(buffer.toString());
    return values;
  }
}

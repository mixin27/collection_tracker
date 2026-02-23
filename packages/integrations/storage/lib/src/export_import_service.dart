import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:share_plus/share_plus.dart';
import 'package:storage/src/exceptions/storage_exception.dart';

class ExportImportService {
  Future<String> exportToJson(Map<String, dynamic> data) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'collection_tracker_export_$timestamp.json';
    return _saveToUserSelectedLocation(
      bytes: bytes,
      fileName: fileName,
      allowedExtensions: const ['json'],
      dialogTitle: 'Save JSON export',
    );
  }

  Future<String> exportToCsv(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) {
      throw StorageException('No data to export as CSV.');
    }

    final headers = items.first.keys.toList();
    final csvLines = <String>[];

    csvLines.add(headers.map((h) => _escapeCsvValue(h)).join(','));
    for (final item in items) {
      final row = headers
          .map((header) => _escapeCsvValue(item[header]?.toString() ?? ''))
          .join(',');
      csvLines.add(row);
    }

    final csvString = csvLines.join('\n');
    final bytes = Uint8List.fromList(utf8.encode(csvString));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'collection_tracker_export_$timestamp.csv';

    return _saveToUserSelectedLocation(
      bytes: bytes,
      fileName: fileName,
      allowedExtensions: const ['csv'],
      dialogTitle: 'Save CSV export',
    );
  }

  Future<String> _saveToUserSelectedLocation({
    required Uint8List bytes,
    required String fileName,
    required List<String> allowedExtensions,
    required String dialogTitle,
  }) async {
    try {
      final savedPath = await fp.FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: fileName,
        type: fp.FileType.custom,
        allowedExtensions: allowedExtensions,
        bytes: bytes,
      );

      if (savedPath == null || savedPath.trim().isEmpty) {
        throw UserCancelledStorageOperationException(
          'File save was cancelled by user.',
        );
      }

      return savedPath;
    } on UserCancelledStorageOperationException {
      rethrow;
    } catch (error) {
      throw StorageException(
        'Failed to save export file.',
        originalError: error,
      );
    }
  }

  String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

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
    } catch (error) {
      throw StorageException('Failed to share file.', originalError: error);
    }
  }

  Future<Map<String, dynamic>> importFromJson() async {
    try {
      final result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        throw UserCancelledStorageOperationException(
          'Import cancelled by user.',
        );
      }

      final selected = result.files.first;
      final bytes = selected.bytes;
      final path = selected.path;

      String jsonString;
      if (bytes != null) {
        jsonString = utf8.decode(bytes);
      } else if (path != null && path.trim().isNotEmpty) {
        jsonString = await XFile(path).readAsString();
      } else {
        throw StorageException('Unable to read selected file.');
      }

      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw StorageException('Invalid JSON format: expected an object root.');
      }
      return decoded;
    } on UserCancelledStorageOperationException {
      rethrow;
    } catch (error) {
      throw StorageException(
        'Failed to import JSON file.',
        originalError: error,
      );
    }
  }

  Future<List<Map<String, dynamic>>> importFromCsv() async {
    try {
      final result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        throw UserCancelledStorageOperationException(
          'Import cancelled by user.',
        );
      }

      final selected = result.files.first;
      final bytes = selected.bytes;
      final path = selected.path;

      String csvString;
      if (bytes != null) {
        csvString = utf8.decode(bytes);
      } else if (path != null && path.trim().isNotEmpty) {
        csvString = await XFile(path).readAsString();
      } else {
        throw StorageException('Unable to read selected file.');
      }

      final lines = csvString.split('\n');
      if (lines.isEmpty) {
        throw StorageException('CSV file is empty.');
      }

      final headers = _parseCsvLine(lines.first);
      final data = <Map<String, dynamic>>[];

      for (var index = 1; index < lines.length; index++) {
        final line = lines[index].trimRight();
        if (line.isEmpty) {
          continue;
        }

        final values = _parseCsvLine(line);
        final row = <String, dynamic>{};
        for (var i = 0; i < headers.length && i < values.length; i++) {
          row[headers[i]] = values[i];
        }
        data.add(row);
      }

      return data;
    } on UserCancelledStorageOperationException {
      rethrow;
    } catch (error) {
      throw StorageException(
        'Failed to import CSV file.',
        originalError: error,
      );
    }
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
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

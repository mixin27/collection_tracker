import 'dart:convert';
import 'dart:io';

import 'package:app_logger/src/models/log_entry.dart';
import 'package:app_logger/src/models/log_level.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

// A file writer for logging messages to a file.
class FileWriter {
  FileWriter({
    required this.logFileNamePrefix,
    this.enabled = true,
    this.maxFileSizeBytes = 10 * 1024 * 1024, // 10MB
    this.maxLogFiles = 5,
  });

  bool enabled;
  File? _logFile;
  final int maxFileSizeBytes;
  final int maxLogFiles;
  final String logFileNamePrefix;

  Future<void> initialize() async {
    if (!enabled) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      if (!logDir.existsSync()) {
        await logDir.create(recursive: true);
      }

      final dateFormat = DateFormat('yyyy-MM-dd');
      final fileName =
          '$logFileNamePrefix${dateFormat.format(DateTime.now())}.log';
      _logFile = File('${logDir.path}/$fileName');

      // Rotate logs if needed
      await _rotateLogsIfNeeded();
    } on Exception catch (e) {
      print('Failed to initialize file logger: $e');
    }
  }

  Future<void> write(LogEntry entry) async {
    if (!enabled || _logFile == null) return;

    try {
      final logLine = '${jsonEncode(entry.toJson())}\n';
      await _logFile!.writeAsString(logLine, mode: FileMode.append);

      // Check file size and rotate if necessary
      final fileSize = await _logFile!.length();
      if (fileSize > maxFileSizeBytes) {
        await _rotateLogsIfNeeded();
      }
    } on Exception catch (e) {
      print('Failed to write log to file: $e');
    }
  }

  Future<void> _rotateLogsIfNeeded() async {
    if (_logFile == null) return;

    try {
      final directory = _logFile!.parent;
      final files =
          directory
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.log'))
              .toList()
            // Sort by last modified date
            ..sort(
              (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
            );

      // Remove old files if exceeding max count
      if (files.length >= maxLogFiles) {
        for (var i = maxLogFiles - 1; i < files.length; i++) {
          await files[i].delete();
        }
      }
    } on Exception catch (e) {
      print('Failed to rotate logs: $e');
    }
  }

  Future<void> clearLogs() async {
    if (_logFile == null) return;

    try {
      final directory = _logFile!.parent;
      final files = directory
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();

      for (final file in files) {
        await file.delete();
      }

      // Reinitialize the current log file
      await initialize();
    } on Exception catch (e) {
      print('Failed to clear logs: $e');
    }
  }

  Future<List<LogEntry>> readLogs() async {
    if (_logFile == null || !_logFile!.existsSync()) return [];

    try {
      final lines = await _logFile!.readAsLines();
      return lines.map((line) {
        final json = jsonDecode(line) as Map<String, dynamic>;
        return LogEntry(
          timestamp: DateTime.parse(json['timestamp'] as String),
          level: LogLevel.values.firstWhere((l) => l.name == json['level']),
          message: json['message'] as String,
          context: json['context'] as Map<String, dynamic>?,
          error: json['error'],
          stackTrace: json['stackTrace'] != null
              ? StackTrace.fromString(json['stackTrace'] as String)
              : null,
        );
      }).toList();
    } on Exception catch (e) {
      print('Failed to read logs: $e');
      return [];
    }
  }

  Future<List<File>> getLogFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      if (!logDir.existsSync()) {
        return [];
      }

      final files =
          logDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.log'))
              .toList()
            // Sort by last modified date (newest first)
            ..sort(
              (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
            );

      return files;
    } on Exception catch (e) {
      print('Failed to get log files: $e');
      return [];
    }
  }

  File? getCurrentLogFile() => _logFile;
}

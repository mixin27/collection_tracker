import 'dart:convert';

import 'package:app_logger/src/models/log_entry.dart';
import 'package:app_logger/src/models/log_level.dart';
import 'package:http/http.dart' as http;

/// A remote writer for logging messages to a remote server.
class RemoteWriter {
  RemoteWriter({
    this.enabled = false,
    this.endpoint,
    this.headers,
    this.minLevel = LogLevel.error,
    this.bufferSize = 10,
  });

  bool enabled;
  final String? endpoint;
  final Map<String, String>? headers;
  final LogLevel minLevel;
  final List<LogEntry> _buffer = [];
  final int bufferSize;

  Future<void> write(LogEntry entry) async {
    if (!enabled || endpoint == null || entry.level < minLevel) return;

    _buffer.add(entry);

    // Send logs when buffer is full or log is fatal
    if (_buffer.length >= bufferSize || entry.level == LogLevel.fatal) {
      await flush();
    }
  }

  Future<void> flush() async {
    if (_buffer.isEmpty || endpoint == null) return;

    try {
      final logs = _buffer.map((e) => e.toJson()).toList();

      final response = await http
          .post(
            Uri.parse(endpoint!),
            headers: {'Content-Type': 'application/json', ...?headers},
            body: jsonEncode({
              'logs': logs,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _buffer.clear();
      } else {
        print('Failed to send logs to remote server: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print('Failed to send logs to remote server: $e');
    }
  }

  Future<void> dispose() async {
    await flush();
  }
}

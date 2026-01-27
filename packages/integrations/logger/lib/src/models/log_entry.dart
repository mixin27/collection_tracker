import 'package:intl/intl.dart';

import 'log_level.dart';

/// A log entry
class LogEntry {
  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.context,
    this.error,
    this.stackTrace,
  });

  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? context;
  final dynamic error;
  final StackTrace? stackTrace;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
    };

    if (context != null && context!.isNotEmpty) {
      json['context'] = context;
    }

    if (error != null) {
      // Convert error to string safely
      json['error'] = error.toString();
    }

    if (stackTrace != null) {
      // Convert stackTrace to string and split into lines for better JSON handling
      final traceLines = stackTrace.toString().split('\n');
      json['stackTrace'] = traceLines;
    }

    return json;
  }

  String toFormattedString() {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final buffer = StringBuffer()
      ..writeln(
        '[${dateFormat.format(timestamp)}] [${level.name.toUpperCase()}] $message',
      );

    if (context != null && context!.isNotEmpty) {
      buffer.writeln('Context: $context');
    }

    if (error != null) {
      buffer.writeln('Error: $error');
    }

    if (stackTrace != null) {
      buffer.writeln('StackTrace:\n$stackTrace');
    }

    return buffer.toString();
  }

  @override
  String toString() => toFormattedString();
}

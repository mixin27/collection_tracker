import 'package:app_logger/src/models/log_entry.dart';
import 'package:app_logger/src/models/log_level.dart';
import 'package:logger/logger.dart';

/// A console writer for logging messages to the console.
class ConsoleWriter {
  ConsoleWriter({this.enabled = true})
    : _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
      );

  final Logger _logger;
  bool enabled;

  void write(LogEntry entry) {
    if (!enabled) return;

    final context = entry.context;
    final error = entry.error;
    final stackTrace = entry.stackTrace;

    // Format message with context for better readability
    var formattedMessage = entry.message;
    if (context != null && context.isNotEmpty) {
      formattedMessage += '\nContext: $context';
    }

    switch (entry.level) {
      case LogLevel.debug:
        _logger.d(formattedMessage);
      case LogLevel.info:
        _logger.i(formattedMessage);
      case LogLevel.warning:
        _logger.w(formattedMessage);
      case LogLevel.error:
        // Pass the actual error and stackTrace to preserve the real trace
        _logger.e(formattedMessage, error: error, stackTrace: stackTrace);
      case LogLevel.fatal:
        _logger.f(formattedMessage, error: error, stackTrace: stackTrace);
    }
  }

  Future<void> dispose() async {
    await _logger.close();
  }
}

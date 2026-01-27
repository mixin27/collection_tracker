import 'dart:io';

import 'package:app_logger/src/models/log_entry.dart';
import 'package:app_logger/src/models/log_level.dart';
import 'package:app_logger/src/writers/console_writer.dart';
import 'package:app_logger/src/writers/file_writer.dart';
import 'package:app_logger/src/writers/remote_writer.dart';

import 'log_uploader.dart';

class LoggerConfig {
  const LoggerConfig({
    this.enableConsoleLogging = true,
    this.enableFileLogging = true,
    this.enableRemoteLogging = false,
    this.minLevel = LogLevel.debug,
    this.remoteEndpoint,
    this.remoteHeaders,
    this.uploadConfig,
    this.logFileNamePrefix = 'app_log_',
  });

  final bool enableConsoleLogging;
  final bool enableFileLogging;
  final bool enableRemoteLogging;
  final LogLevel minLevel;
  final String? remoteEndpoint;
  final Map<String, String>? remoteHeaders;
  final LogUploadConfig? uploadConfig;
  final String logFileNamePrefix;
}

/// Logger service class that handles logging to console, file, and remote server.
class LoggerService {
  LoggerService._();

  static LoggerService? _instance;
  static LoggerService get instance => _instance ??= LoggerService._();

  late ConsoleWriter _consoleWriter;
  late FileWriter _fileWriter;
  late RemoteWriter _remoteWriter;
  LogUploader? _logUploader;

  LogLevel _minLevel = LogLevel.debug;
  String? _userId;
  String? _sessionId;
  String? _currentScreen;

  bool _initialized = false;
  bool _autoUploadEnabled = false;

  late LoggerConfig _config;

  Future<void> initialize({LoggerConfig? config}) async {
    if (_initialized) return;

    _config = config ?? const LoggerConfig();

    _minLevel = _config.minLevel;

    _consoleWriter = ConsoleWriter(enabled: _config.enableConsoleLogging);
    _fileWriter = FileWriter(
      enabled: _config.enableFileLogging,
      logFileNamePrefix: _config.logFileNamePrefix,
    );
    _remoteWriter = RemoteWriter(
      enabled: _config.enableRemoteLogging,
      endpoint: _config.remoteEndpoint,
      headers: _config.remoteHeaders,
    );

    if (_config.uploadConfig != null) {
      _logUploader = LogUploader(_config.uploadConfig!);
      _autoUploadEnabled =
          _config.uploadConfig!.uploadDaily ||
          _config.uploadConfig!.uploadOnError;
    }

    await _fileWriter.initialize();
    _initialized = true;

    // Start auto-upload if enabled
    if (_autoUploadEnabled && _logUploader != null) {
      _startAutoUpload();
    }
  }

  void _startAutoUpload() {
    if (_logUploader == null) return;

    // Check and upload periodically
    Future.delayed(_logUploader!.config.uploadInterval, () async {
      if (_logUploader!.shouldUploadNow()) {
        await uploadAllLogFiles();
      }
      _startAutoUpload();
    });
  }

  String get userId => _userId ?? '';

  set userId(String userId) {
    _userId = userId;
  }

  set sessionId(String sessionId) {
    _sessionId = sessionId;
  }

  String get sessionId => _sessionId ?? '';

  set screen(String screen) {
    _currentScreen = screen;
  }

  String get screen => _currentScreen ?? '';

  Map<String, dynamic> _buildContext([
    Map<String, dynamic>? additionalContext,
  ]) {
    final context = <String, dynamic>{};

    if (_userId != null) context['userId'] = _userId;
    if (_sessionId != null) context['sessionId'] = _sessionId;
    if (_currentScreen != null) context['screen'] = _currentScreen;

    if (additionalContext != null) {
      context.addAll(additionalContext);
    }

    return context;
  }

  void _log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (!_initialized) {
      print('Warning: LoggerService not initialized. Call initialize() first.');
      return;
    }

    if (level < _minLevel) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      context: _buildContext(context),
      error: error,
      stackTrace: stackTrace,
    );

    _consoleWriter.write(entry);
    _fileWriter.write(entry);
    _remoteWriter.write(entry);

    // Auto-upload on error if configured
    if (_autoUploadEnabled &&
        _logUploader != null &&
        _logUploader!.config.uploadOnError &&
        level >= LogLevel.error) {
      uploadAllLogFiles();
    }
  }

  void debug(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.debug, message, context: context);
  }

  void info(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.info, message, context: context);
  }

  void warning(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.warning, message, context: context);
  }

  void error(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ]) {
    _log(
      LogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.fatal, message, error: error, stackTrace: stackTrace);
  }

  Future<void> clearLogs() async {
    await _fileWriter.clearLogs();
  }

  // ========== Log Upload Methods ==========

  /// Upload a specific log file to the server
  Future<LogUploadResult> uploadLogFile(File logFile) async {
    if (_logUploader == null) {
      return LogUploadResult(
        success: false,
        message: 'Log uploader not configured',
        filesUploaded: 0,
        totalFiles: 1,
      );
    }

    return _logUploader!.uploadLogFile(logFile);
  }

  /// Upload multiple log files to the server (as separate files)
  Future<LogUploadResult> uploadLogFiles(List<File> logFiles) async {
    if (_logUploader == null) {
      return LogUploadResult(
        success: false,
        message: 'Log uploader not configured',
        filesUploaded: 0,
        totalFiles: logFiles.length,
      );
    }

    return _logUploader!.uploadLogFiles(logFiles);
  }

  /// Upload all log files from the logs directory
  Future<LogUploadResult> uploadAllLogFiles({bool asJson = false}) async {
    if (_logUploader == null) {
      return LogUploadResult(
        success: false,
        message: 'Log uploader not configured',
        filesUploaded: 0,
        totalFiles: 0,
      );
    }

    final logFiles = await _fileWriter.getLogFiles();

    if (logFiles.isEmpty) {
      return LogUploadResult(
        success: true,
        message: 'No log files to upload',
        filesUploaded: 0,
        totalFiles: 0,
      );
    }

    if (asJson) {
      return _logUploader!.uploadAsJson(logFiles);
    } else {
      return _logUploader!.uploadLogFiles(logFiles);
    }
  }

  /// Upload logs as a single JSON payload
  Future<LogUploadResult> uploadLogsAsJson() async {
    if (_logUploader == null) {
      return LogUploadResult(
        success: false,
        message: 'Log uploader not configured',
        filesUploaded: 0,
        totalFiles: 0,
      );
    }

    final logFiles = await _fileWriter.getLogFiles();

    if (logFiles.isEmpty) {
      return LogUploadResult(
        success: true,
        message: 'No log files to upload',
        filesUploaded: 0,
        totalFiles: 0,
      );
    }

    return _logUploader!.uploadAsJson(logFiles);
  }

  /// Get all log files
  Future<List<File>> getLogFiles() async {
    return _fileWriter.getLogFiles();
  }

  /// Get the current log file
  File? getCurrentLogFile() {
    return _fileWriter.getCurrentLogFile();
  }

  /// Check if uploader is currently uploading
  bool get isUploading => _logUploader?.isUploading ?? false;

  /// Get last upload time
  DateTime? get lastUploadTime => _logUploader?.lastUploadTime;

  Future<void> dispose() async {
    await _consoleWriter.dispose();
    await _remoteWriter.dispose();
  }
}

// Global singleton access
final LoggerService Logger = LoggerService.instance;

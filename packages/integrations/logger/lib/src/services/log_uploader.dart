import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class LogUploadConfig {
  const LogUploadConfig({
    required this.endpoint,
    this.headers,
    this.uploadOnError = false,
    this.uploadDaily = false,
    this.uploadInterval = const Duration(hours: 24),
    this.maxRetries = 3,
  });

  final String endpoint;
  final Map<String, String>? headers;
  final bool uploadOnError;
  final bool uploadDaily;
  final Duration uploadInterval;
  final int maxRetries;
}

class LogUploadResult {
  LogUploadResult({
    required this.success,
    required this.filesUploaded,
    required this.totalFiles,
    this.message,
  });

  final bool success;
  final String? message;
  final int filesUploaded;
  final int totalFiles;
}

class LogUploader {
  LogUploader(this.config);

  final LogUploadConfig config;
  DateTime? _lastUploadTime;
  bool _isUploading = false;

  Future<LogUploadResult> uploadLogFile(File logFile) async {
    try {
      if (!logFile.existsSync()) {
        return LogUploadResult(
          success: false,
          message: 'Log file does not exist',
          filesUploaded: 0,
          totalFiles: 1,
        );
      }

      final fileName = logFile.path.split('/').last;

      final request = http.MultipartRequest('POST', Uri.parse(config.endpoint));

      // Add headers
      if (config.headers != null) {
        request.headers.addAll(config.headers!);
      }

      // Add the log file
      request.files.add(
        await http.MultipartFile.fromPath(
          'logFile',
          logFile.path,
          filename: fileName,
        ),
      );

      // Add metadata
      request.fields['fileName'] = fileName;
      request.fields['uploadTime'] = DateTime.now().toIso8601String();
      request.fields['fileSize'] = (await logFile.length()).toString();

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LogUploadResult(
          success: true,
          message: 'Log file uploaded successfully',
          filesUploaded: 1,
          totalFiles: 1,
        );
      } else {
        return LogUploadResult(
          success: false,
          message:
              'Upload failed with status: ${response.statusCode}, body: ${response.body}',
          filesUploaded: 0,
          totalFiles: 1,
        );
      }
    } on Exception catch (e, stackTrace) {
      print('Upload error: $e');
      print('StackTrace: $stackTrace');
      return LogUploadResult(
        success: false,
        message: 'Upload error: $e',
        filesUploaded: 0,
        totalFiles: 1,
      );
    }
  }

  Future<LogUploadResult> uploadLogFiles(List<File> logFiles) async {
    if (_isUploading) {
      return LogUploadResult(
        success: false,
        message: 'Upload already in progress',
        filesUploaded: 0,
        totalFiles: logFiles.length,
      );
    }

    _isUploading = true;
    var uploadedCount = 0;
    final errors = <String>[];

    try {
      for (final file in logFiles) {
        var retries = 0;
        var uploaded = false;

        while (retries < config.maxRetries && !uploaded) {
          final result = await uploadLogFile(file);

          if (result.success) {
            uploadedCount++;
            uploaded = true;
          } else {
            retries++;
            if (retries < config.maxRetries) {
              await Future.delayed(Duration(seconds: retries * 2));
            } else {
              errors.add('${file.path.split('/').last}: ${result.message}');
            }
          }
        }
      }

      _lastUploadTime = DateTime.now();

      return LogUploadResult(
        success: uploadedCount > 0,
        message: errors.isEmpty
            ? 'All files uploaded successfully'
            : 'Some files failed: ${errors.join(', ')}',
        filesUploaded: uploadedCount,
        totalFiles: logFiles.length,
      );
    } finally {
      _isUploading = false;
    }
  }

  Future<LogUploadResult> uploadAsJson(List<File> logFiles) async {
    if (_isUploading) {
      return LogUploadResult(
        success: false,
        message: 'Upload already in progress',
        filesUploaded: 0,
        totalFiles: logFiles.length,
      );
    }

    _isUploading = true;

    try {
      final allLogs = <Map<String, dynamic>>[];
      var parseErrors = 0;

      for (final file in logFiles) {
        try {
          if (!file.existsSync()) {
            print('File does not exist: ${file.path}');
            continue;
          }

          final content = await file.readAsString();
          final lines = content.split('\n');

          for (final line in lines) {
            final trimmedLine = line.trim();
            if (trimmedLine.isEmpty) continue;

            try {
              final logEntry = jsonDecode(trimmedLine);
              if (logEntry is Map<String, dynamic>) {
                allLogs.add(logEntry);
              }
            } on Exception catch (parseError) {
              parseErrors++;
              print(
                'Error parsing log line (error #$parseErrors): $parseError',
              );
              print(
                'Problematic line: ${trimmedLine.substring(0, trimmedLine.length > 100 ? 100 : trimmedLine.length)}...',
              );
              // Continue with other lines instead of failing completely
            }
          }
        } on Exception catch (e) {
          print('Error reading file ${file.path}: $e');
          // Continue with other files
        }
      }

      if (allLogs.isEmpty) {
        return LogUploadResult(
          success: parseErrors <= 0,
          message: parseErrors > 0
              ? 'No valid logs found. $parseErrors parsing errors occurred.'
              : 'No logs to upload',
          filesUploaded: 0,
          totalFiles: logFiles.length,
        );
      }

      print('Successfully parsed ${allLogs.length} logs ($parseErrors errors)');

      final response = await http
          .post(
            Uri.parse(config.endpoint),
            headers: {'Content-Type': 'application/json', ...?config.headers},
            body: jsonEncode({
              'logs': allLogs,
              'uploadTime': DateTime.now().toIso8601String(),
              'fileCount': logFiles.length,
              'logCount': allLogs.length,
            }),
          )
          .timeout(const Duration(seconds: 30));

      _lastUploadTime = DateTime.now();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LogUploadResult(
          success: true,
          message:
              'Successfully uploaded ${allLogs.length} logs from ${logFiles.length} files${parseErrors > 0 ? " ($parseErrors parse errors)" : ""}',
          filesUploaded: logFiles.length,
          totalFiles: logFiles.length,
        );
      } else {
        return LogUploadResult(
          success: false,
          message:
              'Upload failed with status: ${response.statusCode}, body: ${response.body}',
          filesUploaded: 0,
          totalFiles: logFiles.length,
        );
      }
    } on Exception catch (e, stackTrace) {
      print('Upload error: $e');
      print('StackTrace: $stackTrace');
      return LogUploadResult(
        success: false,
        message: 'Upload error: $e',
        filesUploaded: 0,
        totalFiles: logFiles.length,
      );
    } finally {
      _isUploading = false;
    }
  }

  bool shouldUploadNow() {
    if (_lastUploadTime == null) return true;

    final timeSinceLastUpload = DateTime.now().difference(_lastUploadTime!);
    return timeSinceLastUpload >= config.uploadInterval;
  }

  bool get isUploading => _isUploading;
  DateTime? get lastUploadTime => _lastUploadTime;
}

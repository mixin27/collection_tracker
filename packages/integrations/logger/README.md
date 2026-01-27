# App Logger

A comprehensive structured logging package for Flutter applications. Provides console, file, and remote logging with automatic context management.

## Features

- 🎨 **Colored Console Output** - Beautiful, readable logs with the `logger` package
- 📁 **File Logging** - Persistent logs saved to device storage with automatic rotation
- 🌐 **Remote Logging** - Send critical logs to your server
- ☁️ **Log File Upload** - Upload log files to server manually or automatically
- 🔍 **Automatic Context** - Attach userId, sessionId, screen name automatically
- 🎚️ **Log Filtering** - Control log levels for different environments
- 🔄 **Singleton Pattern** - Easy access throughout your app
- 💾 **Log Management** - Clear old logs, read logs programmatically

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  app_logger: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize the Logger

```dart
import 'package:app_logger/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with configuration
  await Logger.initialize(
    config: LoggerConfig(
      enableConsoleLogging: true,
      enableFileLogging: true,
      enableRemoteLogging: false,
      minLevel: LogLevel.debug,

      // Configure automatic log file uploads
      uploadConfig: LogUploadConfig(
        endpoint: 'https://your-api.com/upload-logs',
        headers: {'Authorization': 'Bearer your-token'},
        uploadOnError: true,      // Auto-upload when error occurs
        uploadDaily: true,        // Upload daily
        uploadInterval: Duration(hours: 24),
        maxRetries: 3,
      ),
    ),
  );

  runApp(MyApp());
}
```

### 2. Use the Logger

```dart
// Simple logging
Logger.debug('User tapped login button');
Logger.info('Login successful');
Logger.warning('API rate limit approaching');
Logger.error('API call failed', error, stackTrace);
Logger.fatal('Critical system error', error, stackTrace);

// Logging with context
Logger.info('Login successful', {'userId': '123', 'email': 'user@example.com'});
Logger.error('Failed to load', error, stackTrace, {'page': 'students'});

// Set context for automatic inclusion
Logger.setUserId('user_12345');
Logger.setSessionId('session_abc');
Logger.setScreen('LoginScreen');

// Upload log files
final result = await Logger.uploadAllLogFiles();
print('Uploaded ${result.filesUploaded} files');
```

## Log File Upload

### Manual Upload

```dart
// Upload all log files (as separate multipart files)
final result = await Logger.uploadAllLogFiles();
if (result.success) {
  print('Uploaded ${result.filesUploaded}/${result.totalFiles} files');
}

// Upload logs as a single JSON payload
final result = await Logger.uploadLogsAsJson();

// Upload a specific log file
final logFiles = await Logger.getLogFiles();
if (logFiles.isNotEmpty) {
  final result = await Logger.uploadLogFile(logFiles.first);
}

// Get all log files
final logFiles = await Logger.getLogFiles();
for (var file in logFiles) {
  print('${file.path}: ${file.lengthSync()} bytes');
}
```

### Automatic Upload

Configure automatic uploads during initialization:

```dart
await Logger.initialize(
  LoggerConfig(
    uploadConfig: LogUploadConfig(
      endpoint: 'https://your-api.com/upload-logs',
      headers: {'Authorization': 'Bearer token'},

      // Upload automatically when error or fatal log occurs
      uploadOnError: true,

      // Upload daily at specified interval
      uploadDaily: true,
      uploadInterval: Duration(hours: 24),

      // Retry failed uploads
      maxRetries: 3,
    ),
  ),
);
```

### Server Endpoint Requirements

#### For Multipart File Upload

Your server should accept `multipart/form-data` with:
- `logFile`: The log file
- `fileName`: Original file name
- `uploadTime`: ISO 8601 timestamp
- `fileSize`: File size in bytes

```dart
// Example Express.js endpoint
app.post('/upload-logs', upload.single('logFile'), (req, res) => {
  const { fileName, uploadTime, fileSize } = req.body;
  // Save file and metadata
  res.status(200).json({ success: true });
});
```

#### For JSON Upload

Your server should accept `application/json` with:

```json
{
  "logs": [
    {
      "timestamp": "2024-01-15T10:30:45.123Z",
      "level": "error",
      "message": "API failed",
      "context": {...}
    }
  ],
  "uploadTime": "2024-01-15T11:00:00.000Z",
  "fileCount": 3
}
```

## Configuration

### LoggerConfig Options

```dart
const LoggerConfig({
  bool enableConsoleLogging = true,      // Show logs in console
  bool enableFileLogging = true,         // Save logs to files
  bool enableRemoteLogging = false,      // Send logs to server
  LogLevel minLevel = LogLevel.debug,    // Minimum log level to record
  String? remoteEndpoint,                // API endpoint for remote logging
  Map<String, String>? remoteHeaders,    // Headers for remote API calls
  LogUploadConfig? uploadConfig,         // Configuration for log file uploads
});
```

### LogUploadConfig Options

```dart
const LogUploadConfig({
  required String endpoint,              // Upload endpoint URL
  Map<String, String>? headers,          // HTTP headers (auth, etc.)
  bool uploadOnError = false,            // Auto-upload when error/fatal occurs
  bool uploadDaily = false,              // Enable daily uploads
  Duration uploadInterval = const Duration(hours: 24),  // Upload frequency
  int maxRetries = 3,                    // Number of retry attempts
});
```

### Production Configuration Example

```dart
await Logger.initialize(
  const LoggerConfig(
    enableConsoleLogging: false,           // Disable console in production
    enableFileLogging: true,               // Keep file logging
    enableRemoteLogging: true,             // Enable remote logging
    minLevel: LogLevel.error,              // Only log errors and above
    remoteEndpoint: 'https://api.yourschool.com/logs',
    remoteHeaders: {'Authorization': 'Bearer YOUR_TOKEN'},
  ),
);
```

## Log Levels

The package supports 5 log levels in order of severity:

1. **Debug** - Detailed information for debugging
2. **Info** - General informational messages
3. **Warning** - Warning messages for potentially harmful situations
4. **Error** - Error events that might still allow the app to continue
5. **Fatal** - Critical errors that may cause app termination

## API Reference

### Logging Methods

```dart
// Debug level
Logger.debug(String message, [Map<String, dynamic>? context])

// Info level
Logger.info(String message, [Map<String, dynamic>? context])

// Warning level
Logger.warning(String message, [Map<String, dynamic>? context])

// Error level
Logger.error(
  String message,
  [dynamic error,
  StackTrace? stackTrace,
  Map<String, dynamic>? context]
)

// Fatal level
Logger.fatal(
  String message,
  [dynamic error,
  StackTrace? stackTrace]
)
```

### Context Management

```dart
// Set user ID (included in all subsequent logs)
Logger.setUserId(String userId)

// Set session ID (included in all subsequent logs)
Logger.setSessionId(String sessionId)

// Set current screen name (included in all subsequent logs)
Logger.setScreen(String screenName)
```

### Utility Methods

```dart
// Clear all log files
await Logger.clearLogs()

// Dispose logger (call before app shutdown)
await Logger.dispose()

// Upload log files
await Logger.uploadAllLogFiles()          // Upload all as separate files
await Logger.uploadLogsAsJson()           // Upload all as single JSON
await Logger.uploadLogFile(file)          // Upload specific file

// Get log files
await Logger.getLogFiles()                // Get all log files
Logger.getCurrentLogFile()                // Get current log file

// Check upload status
Logger.isUploading                        // Check if upload in progress
Logger.lastUploadTime                     // Get last upload timestamp
```

## File Logging

Logs are automatically saved to the application documents directory in JSON format:

- **Location**: `{app_documents_dir}/logs/`
- **Format**: `app_log_YYYY-MM-DD.log`
- **Rotation**: Automatic when file size exceeds 10MB
- **Max Files**: Keeps last 5 log files

### Log File Format

Each log entry is saved as a JSON line:

```json
{
  "timestamp": "2024-01-15T10:30:45.123Z",
  "level": "error",
  "message": "API call failed",
  "context": {
    "userId": "123",
    "sessionId": "abc",
    "screen": "LoginScreen",
    "endpoint": "/api/login"
  },
  "error": "Exception: Network timeout",
  "stackTrace": "..."
}
```

## Remote Logging

When enabled, logs are batched and sent to your server:

- **Buffer Size**: 10 logs (configurable)
- **Auto-flush**: On fatal errors
- **Min Level**: Error and above by default
- **Timeout**: 10 seconds per request

### Remote API Payload

```json
{
  "logs": [
    {
      "timestamp": "2024-01-15T10:30:45.123Z",
      "level": "error",
      "message": "API call failed",
      "context": {...},
      "error": "...",
      "stackTrace": "..."
    }
  ],
  "timestamp": "2024-01-15T10:30:45.123Z"
}
```

## Best Practices

### 1. Initialize Early

Always initialize the logger before using it:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Logger.initialize(config);
  runApp(MyApp());
}
```

### 2. Set Context in Screens

Set screen context in `initState` and clear in `dispose`:

```dart
@override
void initState() {
  super.initState();
  Logger.setScreen('StudentListScreen');
  Logger.info('Screen opened');
}

@override
void dispose() {
  Logger.info('Screen closed');
  super.dispose();
}
```

### 3. Use Appropriate Log Levels

```dart
// ❌ Don't use info for errors
Logger.info('Failed to load data');

// ✅ Use appropriate levels
Logger.error('Failed to load data', error, stackTrace);

// ❌ Don't use error for normal flow
Logger.error('User logged in successfully');

// ✅ Use info for normal events
Logger.info('User logged in successfully');
```

### 4. Add Context to Important Logs

```dart
// ❌ Minimal context
Logger.error('Failed', error);

// ✅ Rich context
Logger.error('Failed to fetch students', error, stackTrace, {
  'endpoint': '/api/students',
  'classId': '10A',
  'retryCount': 3,
});
```

### 5. Different Configs for Different Environments

```dart
final isProduction = kReleaseMode;

await Logger.initialize(
  LoggerConfig(
    enableConsoleLogging: !isProduction,
    minLevel: isProduction ? LogLevel.error : LogLevel.debug,
    enableRemoteLogging: isProduction,
    remoteEndpoint: isProduction ? productionEndpoint : null,
    uploadConfig: isProduction ? LogUploadConfig(
      endpoint: 'https://api.production.com/upload-logs',
      headers: {'Authorization': 'Bearer $prodToken'},
      uploadOnError: true,
      uploadDaily: true,
    ) : null,
  ),
);
```

### 6. Monitor Upload Status

```dart
// Before upload
if (!Logger.isUploading) {
  final result = await Logger.uploadAllLogFiles();
  print('Upload status: ${result.success}');
  print('Last upload: ${Logger.lastUploadTime}');
}
```

## Example Usage in LMS

### Student Login Flow

```dart
class LoginScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    Logger.setScreen('LoginScreen');
  }

  Future<void> _login(String email, String password) async {
    Logger.debug('Login attempt started', {'email': email});

    try {
      final response = await authService.login(email, password);

      Logger.setUserId(response.userId);
      Logger.info('Login successful', {
        'userId': response.userId,
        'role': response.role,
        'loginMethod': 'email',
      });

      Navigator.pushReplacement(context, DashboardScreen());
    } catch (e, stackTrace) {
      Logger.error('Login failed', e, stackTrace, {
        'email': email,
        'errorType': e.runtimeType.toString(),
      });

      // Logs will be auto-uploaded if uploadOnError is enabled
      showErrorDialog('Login failed. Please try again.');
    }
  }
}
```

### Support/Debug Features

```dart
class SettingsScreen extends StatelessWidget {
  Future<void> _sendLogsToSupport() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Uploading logs...'),
          ],
        ),
      ),
    );

    final result = await Logger.uploadAllLogFiles();

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(result.success ? 'Success' : 'Failed'),
        content: Text(
          result.success
              ? 'Logs uploaded successfully. Support team has been notified.'
              : 'Failed to upload logs: ${result.message}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Send Logs to Support'),
      subtitle: Text('Help us diagnose issues'),
      trailing: Icon(Icons.cloud_upload),
      onTap: _sendLogsToSupport,
    );
  }
}
```

### API Service Layer

```dart
class StudentService {
  Future<List<Student>> getStudents(String classId) async {
    Logger.debug('Fetching students', {'classId': classId});

    try {
      final response = await http.get('/api/students?class=$classId');

      Logger.info('Students fetched successfully', {
        'classId': classId,
        'count': response.data.length,
        'responseTime': '${response.duration}ms',
      });

      return parseStudents(response.data);
    } catch (e, stackTrace) {
      Logger.error('Failed to fetch students', e, stackTrace, {
        'classId': classId,
        'endpoint': '/api/students',
      });
      rethrow;
    }
  }
}
```

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/firebase_messaging_message.dart';
import '../models/firebase_messaging_permission_status.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  static FirebaseMessagingService? _instance;

  static FirebaseMessagingService get instance {
    _instance ??= FirebaseMessagingService._();
    return _instance!;
  }

  final FirebaseMessaging _messaging;

  bool _initialized = false;
  bool _enabled = false;

  bool get isInitialized => _initialized;
  bool get isEnabled => _enabled;
  bool get isApplePlatform => _isApplePlatform;

  Stream<FirebaseMessagingMessage> get onMessage => FirebaseMessaging.onMessage
      .map(_mapRemoteMessage)
      .handleError((Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          debugPrint('FirebaseMessaging onMessage stream error: $error');
        }
      });

  Stream<FirebaseMessagingMessage> get onMessageOpenedApp => FirebaseMessaging
      .onMessageOpenedApp
      .map(_mapRemoteMessage)
      .handleError((Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          debugPrint(
            'FirebaseMessaging onMessageOpenedApp stream error: $error',
          );
        }
      });

  Stream<String> get onTokenRefresh =>
      _messaging.onTokenRefresh.handleError((Object error) {
        if (kDebugMode) {
          debugPrint('FirebaseMessaging onTokenRefresh stream error: $error');
        }
      });

  Future<void> initialize({required bool enabled}) async {
    if (!_isSupported) {
      _initialized = true;
      _enabled = false;
      return;
    }

    try {
      await _messaging.setAutoInitEnabled(enabled);
      if (_isApplePlatform) {
        // Foreground alerts are shown via local notifications for consistent UX.
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );
      }
      _initialized = true;
      _enabled = enabled;
    } catch (error) {
      _initialized = true;
      _enabled = false;
      if (kDebugMode) {
        debugPrint('FirebaseMessaging initialize failed: $error');
      }
    }
  }

  Future<void> setEnabled(bool enabled) async {
    if (!_isSupported) {
      _enabled = false;
      return;
    }

    try {
      await _messaging.setAutoInitEnabled(enabled);
      _enabled = enabled;
      if (!_initialized) {
        _initialized = true;
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FirebaseMessaging setEnabled failed: $error');
      }
    }
  }

  Future<FirebaseMessagingPermissionStatus> requestPermission() async {
    if (!_isSupported) {
      return FirebaseMessagingPermissionStatus.unsupported;
    }

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      return _mapAuthorizationStatus(settings.authorizationStatus);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FirebaseMessaging requestPermission failed: $error');
      }
      return FirebaseMessagingPermissionStatus.denied;
    }
  }

  Future<FirebaseMessagingPermissionStatus> getPermissionStatus() async {
    if (!_isSupported) {
      return FirebaseMessagingPermissionStatus.unsupported;
    }

    try {
      final settings = await _messaging.getNotificationSettings();
      return _mapAuthorizationStatus(settings.authorizationStatus);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FirebaseMessaging getPermissionStatus failed: $error');
      }
      return FirebaseMessagingPermissionStatus.notDetermined;
    }
  }

  Future<String?> getToken() async {
    if (!_isSupported || !_enabled) {
      return null;
    }

    if (_isApplePlatform) {
      final apnsToken = await waitForApnsToken();
      if (apnsToken == null || apnsToken.trim().isEmpty) {
        if (kDebugMode) {
          debugPrint(
            'FirebaseMessaging getToken skipped: APNs token not available.',
          );
        }
        return null;
      }
    }

    try {
      return await _messaging.getToken();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FirebaseMessaging getToken failed: $error');
      }
      return null;
    }
  }

  Future<FirebaseMessagingMessage?> getInitialMessage() async {
    if (!_isSupported) {
      return null;
    }

    try {
      final message = await _messaging.getInitialMessage();
      if (message == null) {
        return null;
      }
      return _mapRemoteMessage(message);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FirebaseMessaging getInitialMessage failed: $error');
      }
      return null;
    }
  }

  Future<String?> getApnsToken() async {
    if (!_isSupported || !_isApplePlatform) {
      return null;
    }

    try {
      return await _messaging.getAPNSToken();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FirebaseMessaging getAPNSToken failed: $error');
      }
      return null;
    }
  }

  Future<String?> waitForApnsToken({
    Duration timeout = const Duration(seconds: 8),
    Duration pollInterval = const Duration(milliseconds: 250),
  }) async {
    if (!_isSupported || !_isApplePlatform) {
      return null;
    }

    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      final token = await getApnsToken();
      if (token != null && token.trim().isNotEmpty) {
        return token;
      }

      await Future<void>.delayed(pollInterval);
    }

    return null;
  }

  Future<void> subscribeToTopic(String topic) async {
    if (!_isSupported || !_enabled || topic.trim().isEmpty) {
      return;
    }

    try {
      await _messaging.subscribeToTopic(topic.trim());
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FirebaseMessaging subscribeToTopic($topic) failed: $error');
      }
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_isSupported || topic.trim().isEmpty) {
      return;
    }

    try {
      await _messaging.unsubscribeFromTopic(topic.trim());
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'FirebaseMessaging unsubscribeFromTopic($topic) failed: $error',
        );
      }
    }
  }

  FirebaseMessagingMessage _mapRemoteMessage(RemoteMessage message) {
    return FirebaseMessagingMessage(
      messageId: message.messageId,
      title: message.notification?.title,
      body: message.notification?.body,
      sentTime: message.sentTime,
      data: message.data.map((key, value) => MapEntry(key, '$value')),
    );
  }

  FirebaseMessagingPermissionStatus _mapAuthorizationStatus(
    AuthorizationStatus status,
  ) {
    return switch (status) {
      AuthorizationStatus.authorized =>
        FirebaseMessagingPermissionStatus.authorized,
      AuthorizationStatus.denied => FirebaseMessagingPermissionStatus.denied,
      AuthorizationStatus.provisional =>
        FirebaseMessagingPermissionStatus.provisional,
      AuthorizationStatus.notDetermined =>
        FirebaseMessagingPermissionStatus.notDetermined,
    };
  }

  bool get _isSupported => !kIsWeb && Firebase.apps.isNotEmpty;

  bool get _isApplePlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

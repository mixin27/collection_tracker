import 'dart:async';
import 'dart:convert';

import 'package:app_firebase/app_firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'collection_tracker_general';
  static const _channelName = 'Collectra';
  static const _channelDescription =
      'Sync updates, price alerts, reminders, and account notifications.';

  static LocalNotificationService? _instance;

  static LocalNotificationService get instance {
    _instance ??= LocalNotificationService._();
    return _instance!;
  }

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<String> _routeTapController =
      StreamController<String>.broadcast();

  bool _initialized = false;
  String? _initialRouteFromLaunch;

  Stream<String> get onRouteTap => _routeTapController.stream;

  String? takeInitialRoute() {
    final route = _initialRouteFromLaunch;
    _initialRouteFromLaunch = null;
    return route;
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      // Permission prompts are handled by FirebaseMessagingService to keep
      // consent flow centralized (onboarding/settings).
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _initialRouteFromLaunch = _extractRouteFromPayload(
        launchDetails?.notificationResponse?.payload,
      );
    }

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );

    _initialized = true;
  }

  Future<void> showForegroundMessage({
    required FirebaseMessagingMessage message,
    required String notificationType,
    String? route,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final title = _resolveTitle(message, notificationType);
    final body = _resolveBody(message, notificationType);
    final notificationId = _notificationId(message);

    final payload = jsonEncode({
      'route': ?route,
      'messageId': ?message.messageId,
      'notificationType': notificationType,
    });

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(notificationId, title, body, details, payload: payload);
  }

  void dispose() {
    _routeTapController.close();
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    final route = _extractRouteFromPayload(response.payload);
    if (route == null || route.isEmpty) {
      return;
    }
    _routeTapController.add(route);
  }

  @pragma('vm:entry-point')
  static Future<void> _onBackgroundResponse(
    NotificationResponse response,
  ) async {
    // Route handling for terminated/background app is handled by FCM open events.
  }

  String _resolveTitle(FirebaseMessagingMessage message, String type) {
    final title = message.title?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }

    return switch (type) {
      'sync_needed' => 'Sync needed',
      'price_alert' => 'Price alert',
      'reminder' => 'Reminder',
      'account_security' => 'Account security',
      _ => 'Collectra',
    };
  }

  String _resolveBody(FirebaseMessagingMessage message, String type) {
    final body = message.body?.trim();
    if (body != null && body.isNotEmpty) {
      return body;
    }

    return switch (type) {
      'sync_needed' => 'Open the app to sync your latest changes.',
      'price_alert' => 'One of your tracked item prices changed.',
      'reminder' => 'You have a reminder from Collectra.',
      'account_security' => 'Please review a recent account security event.',
      _ => 'You have a new notification.',
    };
  }

  int _notificationId(FirebaseMessagingMessage message) {
    final messageId = message.messageId?.trim();
    if (messageId != null && messageId.isNotEmpty) {
      return messageId.hashCode & 0x7fffffff;
    }

    return DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
  }

  String? _extractRouteFromPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) {
        return null;
      }
      final route = decoded['route']?.toString().trim();
      if (route == null || route.isEmpty) {
        return null;
      }
      return route;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to parse local notification payload: $error');
      }
      return null;
    }
  }
}

import 'dart:async';

import 'package:app_analytics/app_analytics.dart';
import 'package:app_firebase/app_firebase.dart';
import 'package:collection_tracker/core/observability/operational_telemetry.dart';
import 'package:collection_tracker/core/providers/backend_api_providers.dart';
import 'package:collection_tracker/core/providers/push_notifications_provider.dart';
import 'package:collection_tracker/core/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'local_notification_service.dart';

class PushNotificationBridge extends ConsumerStatefulWidget {
  const PushNotificationBridge({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PushNotificationBridge> createState() =>
      _PushNotificationBridgeState();
}

class _PushNotificationBridgeState
    extends ConsumerState<PushNotificationBridge> {
  StreamSubscription<FirebaseMessagingMessage>? _foregroundSubscription;
  StreamSubscription<FirebaseMessagingMessage>? _openedSubscription;
  StreamSubscription<String>? _localNotificationTapSubscription;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeMessagingListeners());
  }

  @override
  void dispose() {
    unawaited(_foregroundSubscription?.cancel());
    unawaited(_openedSubscription?.cancel());
    unawaited(_localNotificationTapSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep push preferences controller alive so runtime/permission/topic sync stays active.
    ref.watch(pushNotificationPreferencesProvider);
    return widget.child;
  }

  Future<void> _initializeMessagingListeners() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    final messaging = FirebaseMessagingService.instance;
    final localNotifications = LocalNotificationService.instance;
    await localNotifications.initialize();

    _localNotificationTapSubscription = localNotifications.onRouteTap.listen((
      route,
    ) {
      _navigateToRoute(route);
    });

    final initialLocalRoute = localNotifications.takeInitialRoute();
    if (initialLocalRoute != null && initialLocalRoute.isNotEmpty) {
      _navigateToRoute(initialLocalRoute);
    }

    _foregroundSubscription = messaging.onMessage.listen((message) {
      unawaited(_handleForegroundMessage(message));
    });
    _openedSubscription = messaging.onMessageOpenedApp.listen((message) {
      unawaited(_handleOpenedMessage(message, launchedFromTerminated: false));
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null && mounted) {
      await _handleOpenedMessage(initialMessage, launchedFromTerminated: true);
    }
  }

  Future<void> _handleForegroundMessage(
    FirebaseMessagingMessage message,
  ) async {
    final notificationType = _notificationType(message.data);
    final route = _resolveRoute(message);

    await AnalyticsService.instance.track(
      NotificationEvents.notificationReceived(
        notificationType: notificationType,
        campaignId: _campaignId(message.data),
        properties: {'route': ?route, 'message_id': ?message.messageId},
      ),
    );
    await OperationalTelemetry.trackPushMessageReceived(
      notificationType: notificationType,
      hasRoute: route != null,
    );

    await LocalNotificationService.instance.showForegroundMessage(
      message: message,
      notificationType: notificationType,
      route: route,
    );
  }

  Future<void> _handleOpenedMessage(
    FirebaseMessagingMessage message, {
    required bool launchedFromTerminated,
  }) async {
    final notificationType = _notificationType(message.data);
    final route = _resolveRoute(message);

    await AnalyticsService.instance.track(
      NotificationEvents.notificationOpened(
        notificationType: notificationType,
        campaignId: _campaignId(message.data),
        action: route == null ? 'no_route' : 'navigate',
        properties: {'route': ?route, 'message_id': ?message.messageId},
      ),
    );
    await OperationalTelemetry.trackPushMessageOpened(
      notificationType: notificationType,
      hasRoute: route != null,
      launchedFromTerminated: launchedFromTerminated,
    );

    if (route == null || !mounted) {
      return;
    }

    _navigateToRoute(route);
  }

  void _navigateToRoute(String route) {
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      try {
        GoRouter.of(context).go(route);
      } catch (_) {
        // Best-effort navigation for push intents.
      }
    });
  }

  String? _resolveRoute(FirebaseMessagingMessage message) {
    final explicitRoute = message.data['route']?.trim();
    if (explicitRoute != null && explicitRoute.startsWith('/')) {
      return explicitRoute;
    }

    final itemId = (message.data['itemId'] ?? message.data['item_id'] ?? '')
        .trim();
    if (itemId.isNotEmpty) {
      return '/items/$itemId';
    }

    final collectionId =
        (message.data['collectionId'] ?? message.data['collection_id'] ?? '')
            .trim();
    if (collectionId.isNotEmpty) {
      return '/collections/$collectionId';
    }

    final authFeatureEnabled = ref.read(backendAuthFeatureFlagProvider);
    return switch (_notificationType(message.data)) {
      'sync_needed' => Routes.settings,
      'price_alert' => Routes.statistics,
      'reminder' => Routes.collections,
      'account_security' =>
        authFeatureEnabled ? '${Routes.auth}?mode=signin' : Routes.settings,
      _ => null,
    };
  }

  String _notificationType(Map<String, String> data) {
    final candidates = [
      data['notification_type'],
      data['type'],
      data['event'],
      data['category'],
    ];
    for (final candidate in candidates) {
      final normalized = (candidate ?? '').trim().toLowerCase();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return 'unknown';
  }

  String? _campaignId(Map<String, String> data) {
    final raw = (data['campaign_id'] ?? data['campaignId'] ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    return raw;
  }
}

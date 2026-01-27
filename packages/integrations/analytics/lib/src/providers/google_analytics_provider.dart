import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_user.dart';
import 'package:app_analytics/src/providers/base_analytics_provider.dart';

/// Google Analytics 4 provider
/// Note: This is a placeholder. For web, use the GA4 web script.
/// For mobile, you should use Firebase Analytics which supports GA4.
class GoogleAnalytics4Provider extends BaseAnalyticsProvider {
  final String measurementId;
  final String? apiSecret; // For Measurement Protocol

  GoogleAnalytics4Provider({required this.measurementId, this.apiSecret});

  @override
  String get name => 'Google Analytics 4';

  @override
  Future<void> onInitialize() async {
    // For web, GA4 is typically loaded via script tag
    // For mobile apps, use Firebase Analytics instead
    print('Google Analytics 4 initialized with $measurementId');

    // todo(mixin27): Implement Measurement Protocol API if needed
    // https://developers.google.com/analytics/devguides/collection/protocol/ga4
  }

  @override
  Future<void> onTrackEvent(AnalyticsEvent event) async {
    // Send via Measurement Protocol API
    if (apiSecret != null) {
      await _sendToMeasurementProtocol(event);
    } else {
      print('GA4: ${event.name} - ${event.properties}');
    }
  }

  @override
  Future<void> onTrackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    // GA4 uses 'page_view' event
    await onTrackEvent(
      AnalyticsEvent.custom(
        name: 'page_view',
        properties: {
          'page_title': screenName,
          'page_location': screenName,
          ...?properties,
        },
      ),
    );
  }

  @override
  Future<void> onIdentifyUser(AnalyticsUser user) async {
    // GA4 uses user_id parameter
    print('GA4: Set user_id = ${user.id}');
    // User properties would be sent with events
  }

  @override
  Future<void> onSetUserProperties(Map<String, dynamic> properties) async {
    // User properties in GA4 are sent with events
    print('GA4: Set user properties: $properties');
  }

  @override
  Future<void> onReset() async {
    print('GA4: Reset user');
  }

  Future<void> _sendToMeasurementProtocol(AnalyticsEvent event) async {
    if (apiSecret == null) return;

    final uri = Uri.parse(
      'https://www.google-analytics.com/mp/collect?measurement_id=$measurementId&api_secret=$apiSecret',
    );

    final eventBody = {
      'client_id': event.userId ?? event.sessionId ?? 'unknown_client',
      'events': [
        {'name': event.name, 'params': event.properties},
      ],
    };

    if (event.userId != null) {
      eventBody['user_id'] = event.userId!;
    }

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(eventBody),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
      } else {
        print(
          'GA4 Measurement Protocol error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('GA4 Measurement Protocol error: $e');
    }
  }
}

import 'dart:convert';

import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_user.dart';
import 'package:http/http.dart' as http;
import 'package:app_analytics/src/providers/base_analytics_provider.dart';

/// Generic HTTP-based analytics provider
/// Use this as a template for REST API-based analytics services
class CustomHttpAnalyticsProvider extends BaseAnalyticsProvider {
  final String baseUrl;
  final String apiKey;
  final Map<String, String>? customHeaders;

  late http.Client _client;

  CustomHttpAnalyticsProvider({
    required this.baseUrl,
    required this.apiKey,
    this.customHeaders,
  });

  @override
  String get name => 'CustomHTTP';

  @override
  Future<void> onInitialize() async {
    _client = http.Client();
  }

  @override
  Future<void> onTrackEvent(AnalyticsEvent event) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          ...?customHeaders,
        },
        body: jsonEncode({
          'event': event.name,
          'properties': event.properties,
          'timestamp': event.timestamp.toIso8601String(),
          'category': event.category,
          'value': event.value,
          'currency': event.currency,
          'user_id': event.userId,
          'session_id': event.sessionId,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to send event: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending event: $e');
    }
  }

  @override
  Future<void> onTrackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    await onTrackEvent(
      AnalyticsEvent.custom(
        name: 'screen_view',
        properties: {'screen_name': screenName, ...?properties},
      ),
    );
  }

  @override
  Future<void> onIdentifyUser(AnalyticsUser user) async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/identify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          ...?customHeaders,
        },
        body: jsonEncode({
          'user_id': user.id,
          'properties': user.properties,
          'created_at': user.createdAt?.toIso8601String(),
        }),
      );
    } catch (e) {
      print('Error identifying user: $e');
    }
  }

  @override
  Future<void> onSetUserProperties(Map<String, dynamic> properties) async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/user/properties'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          ...?customHeaders,
        },
        body: jsonEncode({'properties': properties}),
      );
    } catch (e) {
      print('Error setting user properties: $e');
    }
  }

  @override
  Future<void> onReset() async {
    // No-op for HTTP provider
    print('CustomHTTP: Reset');
  }

  @override
  Future<void> onDispose() async {
    _client.close();
  }
}

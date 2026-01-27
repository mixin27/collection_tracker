import 'package:app_analytics/app_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PIIFilterMiddleware Enhanced Detection', () {
    late PIIFilterMiddleware middleware;

    setUp(() {
      middleware = PIIFilterMiddleware();
    });

    test('detects and redacts phone numbers', () async {
      final event = AnalyticsEvent.custom(
        name: 'test_event',
        properties: {
          'user_phone': '+1-555-010-9988',
          'contact': '(555) 123-4567',
          'safe_text': 'Call me',
        },
      );

      AnalyticsEvent? processedEvent;
      await middleware.process(
        event,
        next: (e) {
          processedEvent = e;
          return true;
        },
      );

      expect(processedEvent?.properties['user_phone'], equals('[REDACTED]'));
      expect(processedEvent?.properties['contact'], equals('[REDACTED]'));
      expect(processedEvent?.properties['safe_text'], equals('Call me'));
    });

    test('detects and redacts credit cards', () async {
      final event = AnalyticsEvent.custom(
        name: 'payment_event',
        properties: {
          'card': '4111 1111 1111 1111',
          'not_card': '1234', // Too short for Card AND Phone
        },
      );

      AnalyticsEvent? processedEvent;
      await middleware.process(
        event,
        next: (e) {
          processedEvent = e;
          return true;
        },
      );

      expect(processedEvent?.properties['card'], equals('[REDACTED]'));
      expect(processedEvent?.properties['not_card'], equals('1234'));
    });

    test('detects and redacts SSN', () async {
      final event = AnalyticsEvent.custom(
        name: 'user_info',
        properties: {
          'ssn': '123-45-6789',
          'safe_id': '12-34', // Too short
        },
      );

      AnalyticsEvent? processedEvent;
      await middleware.process(
        event,
        next: (e) {
          processedEvent = e;
          return true;
        },
      );

      expect(processedEvent?.properties['ssn'], equals('[REDACTED]'));
      expect(processedEvent?.properties['safe_id'], equals('12-34'));
    });

    test('detects and redacts IP addresses', () async {
      final event = AnalyticsEvent.custom(
        name: 'network_event',
        properties: {'ipv4': '192.168.1.1', 'version': 'v1.0.0'},
      );

      AnalyticsEvent? processedEvent;
      await middleware.process(
        event,
        next: (e) {
          processedEvent = e;
          return true;
        },
      );

      expect(processedEvent?.properties['ipv4'], equals('[REDACTED]'));
      expect(processedEvent?.properties['version'], equals('v1.0.0'));
    });

    test('detects and redacts Dates', () async {
      final event = AnalyticsEvent.custom(
        name: 'dob_event',
        properties: {
          'dob_iso': '1990-01-01',
          'dob_us': '01/01/1990',
          'not_date': '1990/1/1', // Regex enforces 0-padding
        },
      );

      AnalyticsEvent? processedEvent;
      await middleware.process(
        event,
        next: (e) {
          processedEvent = e;
          return true;
        },
      );

      expect(processedEvent?.properties['dob_iso'], equals('[REDACTED]'));
      expect(processedEvent?.properties['dob_us'], equals('[REDACTED]'));
      expect(
        processedEvent?.properties['not_date'],
        isNot(equals('[REDACTED]')),
      );
    });
  });
}

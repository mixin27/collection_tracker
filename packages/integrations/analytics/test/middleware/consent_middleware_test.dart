import 'package:app_analytics/app_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'consent_middleware_test.mocks.dart';

@GenerateMocks([ConsentStorage])
void main() {
  group('ConsentMiddleware', () {
    late MockConsentStorage mockStorage;
    late ConsentMiddleware middleware;

    setUp(() {
      mockStorage = MockConsentStorage();
      middleware = ConsentMiddleware(storage: mockStorage);
    });

    test('drops event when consent not granted', () async {
      when(mockStorage.hasConsent()).thenAnswer((_) async => false);

      final event = AnalyticsEvent.custom(name: 'test_event');
      final result = await middleware.process(event, next: (_) => true);

      expect(result, MiddlewareResult.drop);
    });

    test('continues when consent granted', () async {
      when(mockStorage.hasConsent()).thenAnswer((_) async => true);

      final event = AnalyticsEvent.custom(name: 'test_event');
      final result = await middleware.process(event, next: (_) => true);

      expect(result, MiddlewareResult.continueProcessing);
    });
  });
}

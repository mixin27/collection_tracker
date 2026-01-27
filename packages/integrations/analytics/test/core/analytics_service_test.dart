import 'package:app_analytics/app_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'analytics_service_test.mocks.dart';

@GenerateMocks([AnalyticsProvider])
void main() {
  group('AnalyticsService', () {
    late MockAnalyticsProvider mockProvider;
    late AnalyticsConfig config;

    setUp(() {
      mockProvider = MockAnalyticsProvider();
      when(mockProvider.name).thenReturn('MockProvider');
      when(mockProvider.isEnabled).thenReturn(true);
      when(mockProvider.initialize()).thenAnswer((_) async => {});

      config = AnalyticsConfig(
        environment: AnalyticsEnvironment.development,
        providers: [mockProvider],
        enableLogging: true,
      );
    });

    test('initializes providers correctly', () async {
      await AnalyticsService.initialize(config);

      expect(AnalyticsService.instance.isInitialized, true);
      verify(mockProvider.initialize()).called(1);
    });

    test('tracks events when initialized', () async {
      when(mockProvider.trackEvent(any)).thenAnswer((_) async => {});

      await AnalyticsService.initialize(config);

      final event = AnalyticsEvent.custom(
        name: 'test_event',
        properties: {'key': 'value'},
      );

      await AnalyticsService.instance.track(event);

      verify(mockProvider.trackEvent(any)).called(1);
    });

    test('identifies user correctly', () async {
      when(mockProvider.identifyUser(any)).thenAnswer((_) async => {});

      await AnalyticsService.initialize(config);

      await AnalyticsService.instance.identifyUser(
        userId: 'user_123',
        properties: {'plan': 'premium'},
      );

      verify(mockProvider.identifyUser(any)).called(1);
    });

    test('respects consent when required', () async {
      final configWithConsent = config.copyWith(requireConsent: true);

      await AnalyticsService.initialize(configWithConsent);

      // Without consent
      final event = AnalyticsEvent.custom(name: 'test_event');
      await AnalyticsService.instance.track(event);

      verifyNever(mockProvider.trackEvent(any));

      // With consent
      await AnalyticsService.instance.setConsentGranted(true);
      await AnalyticsService.instance.track(event);

      verify(mockProvider.trackEvent(any)).called(1);
    });
  });
}

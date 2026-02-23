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

    setUp(() async {
      mockProvider = MockAnalyticsProvider();
      when(mockProvider.name).thenReturn('MockProvider');
      when(mockProvider.isEnabled).thenReturn(true);
      when(mockProvider.initialize()).thenAnswer((_) async => {});
      when(mockProvider.trackEvent(any)).thenAnswer((_) async => {});
      when(mockProvider.identifyUser(any)).thenAnswer((_) async => {});
      when(
        mockProvider.trackScreen(any, properties: anyNamed('properties')),
      ).thenAnswer((_) async => {});
      when(mockProvider.setUserProperties(any)).thenAnswer((_) async => {});
      when(mockProvider.reset()).thenAnswer((_) async => {});
      when(mockProvider.flush()).thenAnswer((_) async => {});
      when(mockProvider.dispose()).thenAnswer((_) async => {});

      config = AnalyticsConfig(
        environment: AnalyticsEnvironment.development,
        providers: [mockProvider],
        enableLogging: true,
        requireConsent: false,
        autoTrackAppLifecycle: false,
        enableOfflineQueue: false,
        flushInterval: 0,
      );

      await AnalyticsService.instance.dispose();
    });

    tearDown(() async {
      await AnalyticsService.instance.dispose();
    });

    test('initializes providers correctly', () async {
      await AnalyticsService.initialize(config);

      expect(AnalyticsService.instance.isInitialized, true);
      verify(mockProvider.initialize()).called(1);
    });

    test('tracks events when initialized', () async {
      await AnalyticsService.initialize(config);

      final event = AnalyticsEvent.custom(
        name: 'test_event',
        properties: {'key': 'value'},
      );

      await AnalyticsService.instance.track(event);

      verify(mockProvider.trackEvent(any)).called(1);
    });

    test('identifies user correctly', () async {
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

    test('blocks events when tracking is disabled', () async {
      await AnalyticsService.initialize(config);
      await AnalyticsService.instance.setTrackingEnabled(false);

      await AnalyticsService.instance.track(
        AnalyticsEvent.custom(name: 'test'),
      );

      verifyNever(mockProvider.trackEvent(any));
    });

    test('trackScreen respects autoTrackScreenViews config', () async {
      await AnalyticsService.initialize(
        config.copyWith(autoTrackScreenViews: false),
      );

      await AnalyticsService.instance.trackScreen('Home');

      verifyNever(mockProvider.trackEvent(any));
    });
  });
}

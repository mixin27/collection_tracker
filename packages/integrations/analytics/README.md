# Analytics Package

A reusable, extensible, and privacy-first analytics package for Flutter applications with multi-SDK support.

## 📋 Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Supported Providers](#supported-providers)
- [Configuration](#configuration)
- [Usage](#usage)
- [Events](#events)
- [Middleware](#middleware)
- [Custom Providers](#custom-providers)
- [Privacy & Compliance](#privacy--compliance)
- [Testing](#testing)
- [API Reference](#api-reference)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## ✨ Features

- 🎯 **Multi-Provider Support** - Use Firebase, Mixpanel, Amplitude, and more simultaneously
- 🔌 **Easily Extensible** - Add custom analytics providers without modifying core code
- 🛡️ **Privacy-First** - Built-in consent management and PII filtering
- 📦 **Type-Safe Events** - Strongly typed events with compile-time checks
- 🔄 **Offline Support** - Automatic event queueing when offline
- 🎨 **Middleware System** - Process, enrich, or filter events before sending
- 🐛 **Debug Mode** - Console provider for development and testing
- ⚡ **Performance** - Async/non-blocking event tracking
- 🧪 **Testable** - Easy to mock and test in your app

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_analytics:
    path: ../../packages/integrations/analytics

  # Required dependencies
  shared_preferences: ^2.2.0

  # Optional - add only the providers you need
  firebase_analytics: ^10.8.0      # For Firebase Analytics
  mixpanel_flutter: ^2.2.0         # For Mixpanel
  amplitude_flutter: ^3.16.0       # For Amplitude
  segment_analytics: ^0.1.0        # For Segment
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

### 1. Initialize Analytics

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:app_analytics/app_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure analytics
  final config = AnalyticsConfig(
    environment: AnalyticsEnvironment.production,
    enableLogging: false,
    providers: [
      FirebaseAnalyticsProvider(),
      MixpanelAnalyticsProvider(token: 'YOUR_MIXPANEL_TOKEN'),
    ],
    middleware: [
      ConsentMiddleware(),      // Check user consent
      PIIFilterMiddleware(),    // Remove PII
      ValidationMiddleware(),   // Validate events
      EnrichmentMiddleware(),   // Add common properties
    ],
    requireConsent: true,
    autoTrackScreenViews: true,
  );

  // Initialize
  await AnalyticsService.initialize(config);

  runApp(MyApp());
}
```

### 2. Track Events

```dart
import 'package:app_analytics/app_analytics.dart';

// Simple event
AnalyticsService.instance.track(
  AnalyticsEvent.custom(name: 'button_clicked'),
);

// Event with properties
AnalyticsService.instance.track(
  AnalyticsEvent.custom(
    name: 'item_purchased',
    properties: {
      'item_id': '123',
      'price': 9.99,
      'currency': 'USD',
    },
  ),
);

// Screen view
AnalyticsService.instance.trackScreen('HomeScreen');
```

### 3. Identify Users

```dart
// On login
await AnalyticsService.instance.identifyUser(
  userId: 'user_123',
  properties: {
    'email': 'user@example.com',
    'plan': 'premium',
  },
);

// On logout
await AnalyticsService.instance.reset();
```

---

## 🏗️ Architecture

### Core Components

```
┌─────────────────────────────────────┐
│      AnalyticsService               │  ← Main API
│      (Singleton)                    │
└──────────────┬──────────────────────┘
               │
        ┌──────┴──────┐
        ▼             ▼
   Middleware     Providers
        │             │
        ▼             ▼
   ┌────────┐   ┌──────────┐
   │Consent │   │Firebase  │
   │PII     │   │Mixpanel  │
   │Validate│   │Amplitude │
   └────────┘   └──────────┘
```

### Design Patterns

- **Strategy Pattern** - Multiple interchangeable providers
- **Chain of Responsibility** - Middleware pipeline
- **Singleton** - Single analytics service instance
- **Builder** - Event construction
- **Factory** - Provider creation

---

## 🔌 Supported Providers

### Built-in Providers

| Provider | Status | Use Case |
|----------|--------|----------|
| **Console** | ✅ Ready | Development/debugging |
| **Firebase Analytics** | ✅ Ready | Google's free analytics |
| **Mixpanel** | ✅ Ready | Product analytics |
| **Amplitude** | ✅ Ready | Behavioral analytics |
| **Segment** | ⚠️ Template | Customer data platform |
| **PostHog** | ⚠️ Template | Open-source analytics |
| **Google Analytics 4** | 📋 Planned | Web & app analytics |
| **Custom** | ✅ Template | Your own service |

### Console Provider (Development)

Perfect for debugging:

```dart
final config = AnalyticsConfig(
  environment: AnalyticsEnvironment.development,
  providers: [
    ConsoleAnalyticsProvider(prettyPrint: true),
  ],
);
```

Output:
```
📊 [Analytics] Event: button_clicked
   Category: engagement
   Properties: {button_name: add_item, screen: home}
```

---

## ⚙️ Configuration

### Basic Configuration

```dart
final config = AnalyticsConfig(
  // Environment
  environment: AnalyticsEnvironment.production,

  // Providers (can use multiple)
  providers: [
    FirebaseAnalyticsProvider(),
    MixpanelAnalyticsProvider(token: 'token'),
  ],

  // Middleware (order matters)
  middleware: [
    ConsentMiddleware(),
    PIIFilterMiddleware(),
    ValidationMiddleware(),
    EnrichmentMiddleware(),
  ],

  // Options
  enableLogging: false,
  requireConsent: true,
  autoTrackScreenViews: true,
  autoTrackAppLifecycle: true,

  // Queue settings
  enableOfflineQueue: true,
  maxQueueSize: 100,
  flushInterval: 30, // seconds

  // Common properties (added to all events)
  commonProperties: {
    'app_version': '1.0.0',
    'environment': 'production',
  },

  // Session settings
  sessionTimeout: 30, // minutes
);
```

### Environment-Specific Configuration

```dart
AnalyticsConfig getConfig() {
  final env = const String.fromEnvironment('ANALYTICS_ENV');

  switch (env) {
    case 'production':
      return AnalyticsConfig(
        environment: AnalyticsEnvironment.production,
        providers: [
          FirebaseAnalyticsProvider(),
          MixpanelAnalyticsProvider(token: prodToken),
        ],
        enableLogging: false,
      );

    case 'staging':
      return AnalyticsConfig(
        environment: AnalyticsEnvironment.staging,
        providers: [FirebaseAnalyticsProvider()],
        enableLogging: true,
      );

    default: // development
      return AnalyticsConfig(
        environment: AnalyticsEnvironment.development,
        providers: [ConsoleAnalyticsProvider()],
        enableLogging: true,
      );
  }
}
```

---

## 📊 Usage

### Tracking Events

#### Basic Events

```dart
// Simple event
AnalyticsService.instance.track(
  AnalyticsEvent.custom(name: 'button_clicked'),
);

// Event with properties
AnalyticsService.instance.track(
  AnalyticsEvent.custom(
    name: 'item_viewed',
    properties: {
      'item_id': '123',
      'item_name': 'Product Name',
      'category': 'electronics',
    },
  ),
);

// Event with value
AnalyticsService.instance.track(
  AnalyticsEvent.custom(
    name: 'purchase',
    value: 99.99,
    currency: 'USD',
    properties: {
      'order_id': 'order_123',
    },
  ),
);
```

#### Using Event Builders

```dart
// App events
AnalyticsService.instance.track(AppEvents.appOpened());
AnalyticsService.instance.track(AppEvents.appBackgrounded());

// User events
AnalyticsService.instance.track(
  UserEvents.signedUp(method: 'email'),
);
AnalyticsService.instance.track(
  UserEvents.loggedIn(method: 'google'),
);

// Screen events
AnalyticsService.instance.track(
  AnalyticsEvent.screenView(screenName: 'HomeScreen'),
);

// Button clicks
AnalyticsService.instance.track(
  AnalyticsEvent.buttonClicked(
    buttonName: 'add_to_cart',
    screenName: 'ProductScreen',
  ),
);
```

### Screen Tracking

#### Manual Tracking

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Track screen view
    AnalyticsService.instance.trackScreen(
      'HomeScreen',
      properties: {
        'tab': 'featured',
      },
    );

    return Scaffold(/*...*/);
  }
}
```

#### Automatic Tracking with Navigator

```dart
// For Firebase Analytics
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseProvider = AnalyticsService.instance._providers
        .whereType<FirebaseAnalyticsProvider>()
        .first;

    return MaterialApp(
      navigatorObservers: [
        firebaseProvider.observer,
      ],
      /*...*/
    );
  }
}
```

### User Identification

```dart
// Identify user (after login)
await AnalyticsService.instance.identifyUser(
  userId: 'user_123',
  properties: {
    'email': 'user@example.com',
    'name': 'John Doe',
    'plan': 'premium',
    'signup_date': '2024-01-15',
  },
);

// Update user properties
await AnalyticsService.instance.setUserProperties({
  'theme': 'dark',
  'notifications_enabled': true,
  'last_seen': DateTime.now().toIso8601String(),
});

// Reset user (logout)
await AnalyticsService.instance.reset();
```

### Consent Management

```dart
// Check if consent is granted
final hasConsent = AnalyticsService.instance.hasConsent;

// Request consent from user
final userConsent = await showConsentDialog(context);

// Set consent
await AnalyticsService.instance.setConsentGranted(userConsent);

// Consent dialog example
Future<bool> showConsentDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Analytics & Cookies'),
      content: Text(
        'We use analytics to improve your experience. '
        'Do you consent to anonymous usage tracking?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Decline'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Accept'),
        ),
      ],
    ),
  ) ?? false;
}
```

### Flushing Events

```dart
// Manually flush pending events
await AnalyticsService.instance.flush();

// Flush on app background
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AnalyticsService.instance.flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(/*...*/);
  }
}
```

---

## 🎯 Events

### Pre-built Event Builders

#### App Events

```dart
// App opened
AppEvents.appOpened(source: 'push_notification');

// App backgrounded
AppEvents.appBackgrounded();

// App resumed
AppEvents.appResumed();

// Error occurred
AppEvents.errorOccurred(
  error: 'NetworkException',
  screen: 'HomeScreen',
  context: 'fetching_data',
);

// App crashed
AppEvents.appCrashed(
  error: exception.toString(),
  stackTrace: stackTrace.toString(),
);
```

#### User Events

```dart
// User signed up
UserEvents.signedUp(method: 'email');

// User logged in
UserEvents.loggedIn(method: 'google');

// User logged out
UserEvents.loggedOut();

// Feature used
UserEvents.featureUsed(
  featureName: 'export_data',
  properties: {'format': 'csv'},
);
```

#### Commerce Events

```dart
// Product viewed
CommerceEvents.productViewed(
  productId: 'prod_123',
  productName: 'Premium Plan',
  category: 'subscription',
  price: 9.99,
);

// Purchase completed
CommerceEvents.purchaseCompleted(
  orderId: 'order_456',
  revenue: 9.99,
  currency: 'USD',
  properties: {
    'payment_method': 'credit_card',
  },
);

// Subscription started
CommerceEvents.subscriptionStarted(
  planId: 'premium_monthly',
  planName: 'Premium Plan',
  price: 9.99,
  currency: 'USD',
  billingPeriod: 'monthly',
);
```

### Custom Events

Create your own event builders:

```dart
// events/my_app_events.dart
class MyAppEvents {
  static AnalyticsEvent dataExported({
    required String format,
    required int itemCount,
  }) {
    return AnalyticsEvent.custom(
      name: 'data_exported',
      category: 'feature',
      properties: {
        'format': format,
        'item_count': itemCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static AnalyticsEvent searchPerformed({
    required String query,
    required int resultCount,
    required int duration,
  }) {
    return AnalyticsEvent.custom(
      name: 'search_performed',
      category: 'engagement',
      properties: {
        'query_length': query.length,
        'result_count': resultCount,
        'duration_ms': duration,
      },
    );
  }
}

// Usage
AnalyticsService.instance.track(
  MyAppEvents.dataExported(format: 'csv', itemCount: 150),
);
```

---

## 🔧 Middleware

Middleware processes events before they reach providers.

### Built-in Middleware

#### Consent Middleware

Checks if user has granted consent:

```dart
ConsentMiddleware()
```

#### PII Filter Middleware

Removes personally identifiable information:

```dart
PIIFilterMiddleware()
```

#### Validation Middleware

Validates event structure:

```dart
ValidationMiddleware(
  maxEventNameLength: 40,
  maxPropertyKeyLength: 40,
  maxPropertyValueLength: 100,
)
```

#### Enrichment Middleware

Adds common properties to all events:

```dart
final enrichment = EnrichmentMiddleware();

// Add common properties
enrichment.setCommonProperty('app_version', '1.0.0');
enrichment.setCommonProperty('build_number', '42');
```

#### Filtering Middleware

Blocks or allows specific events:

```dart
// Block events
final filtering = FilteringMiddleware(
  blockedEvents: ['debug_event', 'test_event'],
);

// Or use allowlist
final filtering = FilteringMiddleware(
  allowedEvents: ['purchase', 'signup', 'login'],
  useAllowlist: true,
);
```

### Custom Middleware

Create your own middleware:

```dart
class RateLimitMiddleware implements AnalyticsMiddleware {
  final int maxEventsPerMinute;
  final List<DateTime> _eventTimestamps = [];

  RateLimitMiddleware({this.maxEventsPerMinute = 60});

  @override
  int get priority => 50; // Higher = runs first

  @override
  Future<MiddlewareResult> process(
    AnalyticsEvent event, {
    required bool Function(AnalyticsEvent) next,
  }) async {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(Duration(minutes: 1));

    // Clean old timestamps
    _eventTimestamps.removeWhere((ts) => ts.isBefore(oneMinuteAgo));

    // Check rate limit
    if (_eventTimestamps.length >= maxEventsPerMinute) {
      return MiddlewareResult.drop;
    }

    _eventTimestamps.add(now);
    return MiddlewareResult.continueProcessing;
  }
}

// Use it
final config = AnalyticsConfig(
  middleware: [
    RateLimitMiddleware(maxEventsPerMinute: 30),
  ],
);
```

---

## 🔌 Custom Providers

### Creating a Custom Provider

```dart
class MyAnalyticsProvider extends BaseAnalyticsProvider {
  final String apiKey;

  MyAnalyticsProvider({required this.apiKey});

  @override
  String get name => 'MyAnalytics';

  @override
  Future<void> onInitialize() async {
    // Initialize your SDK
    print('Initializing MyAnalytics with key: $apiKey');
  }

  @override
  Future<void> onTrackEvent(AnalyticsEvent event) async {
    // Send event to your service
    print('Tracking: ${event.name} - ${event.properties}');

    // Example API call
    // await _httpClient.post(
    //   '/events',
    //   body: {
    //     'event': event.name,
    //     'properties': event.properties,
    //     'timestamp': event.timestamp.toIso8601String(),
    //   },
    // );
  }

  @override
  Future<void> onTrackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    // Track screen view
    print('Screen: $screenName');
  }

  @override
  Future<void> onIdentifyUser(AnalyticsUser user) async {
    // Identify user in your system
    print('Identify: ${user.id}');
  }

  @override
  Future<void> onSetUserProperties(
    Map<String, dynamic> properties,
  }) async {
    // Update user properties
    print('User properties: $properties');
  }

  @override
  Future<void> onReset() async {
    // Clear user data
    print('Reset user');
  }

  @override
  Future<void> onFlush() async {
    // Optional: flush pending events
    print('Flush events');
  }

  @override
  Future<void> onDispose() async {
    // Optional: cleanup resources
    print('Dispose');
  }
}

// Use your custom provider
final config = AnalyticsConfig(
  providers: [
    MyAnalyticsProvider(apiKey: 'your_api_key'),
  ],
);
```

---

## 🛡️ Privacy & Compliance

### GDPR Compliance

```dart
// 1. Request consent before tracking
final consent = await requestUserConsent();
await AnalyticsService.instance.setConsentGranted(consent);

// 2. Use PII filter middleware
final config = AnalyticsConfig(
  middleware: [
    PIIFilterMiddleware(), // Removes PII automatically
  ],
);

// 3. Allow users to delete their data
Future<void> deleteUserData(String userId) async {
  // Reset analytics
  await AnalyticsService.instance.reset();

  // Clear stored data
  final storage = AnalyticsStorage();
  await storage.clearQueue();

  final consentStorage = ConsentStorage();
  await consentStorage.clearConsent();
}
```

### CCPA Compliance

```dart
// Allow users to opt-out
Future<void> handleOptOut() async {
  await AnalyticsService.instance.setConsentGranted(false);
  await AnalyticsService.instance.reset();
}

// Show opt-out option
ElevatedButton(
  onPressed: handleOptOut,
  child: Text('Opt out of analytics'),
);
```

### PII Handling

```dart
// PII is automatically filtered by PIIFilterMiddleware
// These fields are redacted:
// - email, phone, ssn, credit_card, password, address, full_name

// Add custom PII fields
final piiFilter = PIIFilterMiddleware();
piiFilter.addPIIKey('social_security');
piiFilter.addPIIKey('passport_number');
```

---

## 🧪 Testing

### Unit Testing

```dart
void main() {
  group('Analytics', () {
    late MockAnalyticsProvider mockProvider;

    setUp(() async {
      mockProvider = MockAnalyticsProvider();
      when(mockProvider.name).thenReturn('Mock');
      when(mockProvider.isEnabled).thenReturn(true);
      when(mockProvider.initialize()).thenAnswer((_) async => {});

      await AnalyticsService.initialize(
        AnalyticsConfig(providers: [mockProvider]),
      );
    });

    test('tracks events', () async {
      when(mockProvider.trackEvent(any)).thenAnswer((_) async => {});

      await AnalyticsService.instance.track(
        AnalyticsEvent.custom(name: 'test_event'),
      );

      verify(mockProvider.trackEvent(any)).called(1);
    });
  });
}
```

### Integration Testing

```dart
void main() {
  testWidgets('Analytics integration test', (tester) async {
    // Use console provider for testing
    await AnalyticsService.initialize(
      AnalyticsConfig(
        providers: [ConsoleAnalyticsProvider()],
      ),
    );

    await tester.pumpWidget(MyApp());

    // Track event
    AnalyticsService.instance.track(
      AnalyticsEvent.custom(name: 'test'),
    );

    // Events should be printed to console
  });
}
```

---

## 📚 API Reference

### AnalyticsService

Main singleton service for analytics.

#### Methods

- `initialize(config)` - Initialize analytics
- `track(event)` - Track an event
- `trackScreen(screenName)` - Track screen view
- `identifyUser(userId, properties)` - Identify user
- `setUserProperties(properties)` - Update user properties
- `reset()` - Reset user (logout)
- `setConsentGranted(granted)` - Set user consent
- `flush()` - Flush pending events
- `dispose()` - Cleanup resources

### AnalyticsEvent

Represents an analytics event.

#### Factory Constructors

- `AnalyticsEvent.custom()` - Create custom event
- `AnalyticsEvent.screenView()` - Screen view event
- `AnalyticsEvent.buttonClicked()` - Button click event

### AnalyticsProvider

Interface for analytics providers.

#### Methods to Implement

- `initialize()` - Initialize provider
- `trackEvent(event)` - Track event
- `trackScreen(screenName)` - Track screen
- `identifyUser(user)` - Identify user
- `setUserProperties(properties)` - Set properties
- `reset()` - Reset user
- `flush()` - Flush events
- `dispose()` - Cleanup

### AnalyticsMiddleware

Interface for middleware.

#### Methods to Implement

- `process(event, next)` - Process event
- `priority` - Execution priority (higher first)

---

## ✅ Best Practices

### DO

✅ Always check consent before tracking
✅ Use event builders for consistency
✅ Add meaningful properties to events
✅ Track user flows and conversions
✅ Use console provider in development
✅ Filter out PII automatically
✅ Validate events before sending
✅ Use descriptive event names
✅ Document your custom events
✅ Test analytics in staging

### DON'T

❌ Track PII without explicit consent
❌ Send too many events (rate limit)
❌ Use dynamic event names
❌ Track in unit tests
❌ Hardcode API keys in code
❌ Block UI thread
❌ Track passwords or tokens
❌ Ignore errors silently
❌ Track every user action
❌ Skip error handling

---

## 🐛 Troubleshooting

### Events Not Appearing

```dart
// 1. Check if analytics is initialized
if (AnalyticsService.instance.isInitialized) {
  print('Analytics initialized');
} else {
  print('Analytics NOT initialized');
}

// 2. Enable logging
final config = AnalyticsConfig(
  enableLogging: true,
  providers: [ConsoleAnalyticsProvider()],
);

// 3. Check consent
if (AnalyticsService.instance.hasConsent) {
  print('Consent granted');
} else {
  print('Consent NOT granted - events blocked');
}
```

### Provider Not Working

```dart
// Check if provider is enabled
for (final provider in config.providers) {
  print('${provider.name}: ${provider.isEnabled}');
}

// Check initialization errors
try {
  await provider.initialize();
} catch (e) {
  print('Initialization error: $e');
}
```

### Events Being Dropped

```dart
// Check middleware
// Events might be dropped by:
// - ConsentMiddleware (no consent)
// - ValidationMiddleware (invalid event)
// - FilteringMiddleware (blocked event)
// - RateLimitMiddleware (too many events)

// Enable logging to see why
final config = AnalyticsConfig(
  enableLogging: true,
  middleware: [/* your middleware */],
);
```

---

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines.

### Adding a New Provider

1. Create provider class extending `BaseAnalyticsProvider`
2. Implement all required methods
3. Add tests
4. Update documentation
5. Submit PR

### Adding New Middleware

1. Implement `AnalyticsMiddleware` interface
2. Add tests
3. Document usage
4. Submit PR

---

## 📄 License

This package is part of the Collection Tracker project.

---

## 🙏 Acknowledgments

- Firebase Analytics
- Mixpanel
- Amplitude
- Flutter community

---

## 📞 Support

For issues, questions, or suggestions:

- Create an issue on GitHub
- Check documentation
- Review examples

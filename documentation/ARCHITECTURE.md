# Architecture

This document describes the architecture that is currently implemented in the repository.

## 1. Architecture Style

The app uses a layered setup aligned with clean architecture principles:

- Presentation layer in `apps/mobile/lib/features/*`
- Domain interfaces/entities in `packages/core/domain`
- Data/repository implementations in `packages/core/data`
- Integration packages for storage, database, Firebase, analytics, backend API, and sync transport

State management is Riverpod-based (including `riverpod_generator` notifiers/providers).

## 2. Workspace Modules

| Module | Purpose |
| --- | --- |
| `apps/mobile` | Main Flutter app, routing, screens, feature view models |
| `packages/core/domain` | Entities and repository contracts |
| `packages/core/data` | Repository implementations and local->sync outbox bridging |
| `packages/common/ui` | Custom design system primitives and motion widgets |
| `packages/common/utils` | Utility helpers |
| `packages/common/env` | Envied-based metadata API keys access |
| `packages/integrations/database` | Drift database, schema, DAOs |
| `packages/integrations/storage` | Shared preferences, secure storage, import/export, image helpers |
| `packages/integrations/analytics` | Provider-agnostic analytics service + middleware |
| `packages/integrations/firebase_services` | Firebase Remote Config + Performance wrappers |
| `packages/integrations/auth_session` | Persistent auth session storage abstractions |
| `packages/integrations/backend_api` | Backend auth HTTP client + models |
| `packages/integrations/sync_api` | Sync API contract, auth token adapter, backend sync client |

## 3. App Startup Flow

Bootstrap entrypoint: `apps/mobile/lib/main.dart` and `apps/mobile/lib/core/bootstrap/app_bootstrap.dart`

Startup sequence:

1. Initialize logger
2. Initialize preference storage
3. Initialize Firebase Core
4. Initialize Firebase services bootstrap (Remote Config + Performance)
5. Configure Crashlytics collection state
6. Initialize analytics service (with persisted consent and enabled preference)
7. Read onboarding completion flag and provide initial app state overrides

At runtime, app root wraps routed content with:

- `SyncAutoRetryOnResume` (retry pending sync on lifecycle resume when due)
- `FirebaseRuntimeConfigAutoRefresh` (refresh runtime flags on resume, throttled)

## 4. Navigation Model

Navigation stack uses `GoRouter` with:

- `StatefulShellRoute.indexedStack` for main tabs (collections, favorites, wishlist, settings)
- Global routes for item detail/edit, scanner, statistics, auth, and tag-item listing
- Custom shell widget (`AppShell`) with:
  - glass bottom navigation on compact screens
  - navigation rail on larger screens

Analytics screen tracking is connected through a navigator observer.

## 5. Presentation + State Patterns

Main pattern per feature:

- Screen widgets (`views/`)
- Riverpod providers/notifiers (`view_models/`, `providers/`)
- Reusable feature widgets (`widgets/`)

Common UI primitives come from `packages/common/ui`:

- `AppButton`, `AppCard`, `AppInput`, `AppDialog`, `AppSheet`
- `AppReveal`, `AppAnimatedSwitcher`, `LoadingView`
- `GlassSurface`, `GlassSegmentedNavigationBar`
- Theme + design tokens (`AppTheme`, `DesignTokens`, `AppMotion`, spacing/radii)

## 6. Data and Local Persistence

### Drift Database

Core tables include:

- `collections`
- `items`
- `tags`
- `item_tags`
- `item_price_history`
- `sync_outbox`
- `sync_state`

Schema is currently version `7` in `AppDatabase`.

### Repositories

- `CollectionRepositoryImpl` and `ItemRepositoryImpl` perform local DB operations.
- When sync outbox writes are enabled, repositories also enqueue outbox operations for mutations.

### Preferences and Secure Storage

- `PrefsStorageService`: UI/settings/runtime preferences and lightweight app state
- `SecureStorageService`: auth session payload and sensitive values

## 7. Sync and Backend Integration

Sync and backend auth are optional and feature-flag gated.

### Readiness Gates

Cloud sync becomes ready only when all are true:

1. Backend integration flag enabled
2. Sync feature flag enabled
3. API base URL resolved/configured
4. Auth session available (signed in)

### Sync Pipeline (v1)

- Local mutations enqueue outbox operations (`sync_outbox`)
- Sync orchestrator builds push payload from outbox entries (collections/items/tags)
- Backend response includes counters, conflicts, and server changes
- Server changes are applied locally with timestamp checks and pending-local-op protections
- Processed outbox operations are removed
- Sync state tracks last success/attempt and retry scheduling

Retry behavior includes immediate network retry attempts plus scheduled retries after failures.

## 8. Firebase and Observability

### Runtime Flags

Remote Config keys drive runtime behavior for:

- Analytics collection
- Crashlytics collection
- Performance collection
- Backend integration
- Sync feature

### Analytics

- Custom analytics service abstraction with middleware
- Consent gate shown after onboarding when consent status is unknown
- Tracking can be enabled/disabled via persisted settings

### Crashlytics and Performance

- Crashlytics global error handlers are wired at bootstrap
- Performance tracing wrappers are used in data transfer and sync operations

### Operational Telemetry

Operational events are tracked to:

- Analytics events
- Crashlytics logs/keys/errors (best effort)
- Local rolling history for diagnostics UI in settings

## 9. Localization

- Flutter `gen_l10n` with ARB files under `apps/mobile/lib/l10n/arb`
- Supported locales currently include: `en`, `es`, `id`, `ja`, `ko`, `my`, `zh`
- Language selection is persisted via Riverpod notifier + shared preferences

## 10. Build and Codegen

Workspace relies on generated files for Riverpod/Freezed/Drift code.

Primary commands:

- `dart pub get`
- `./scripts/build_all.sh`
- `./scripts/analyze_all.sh`
- `./scripts/test_all.sh`

CI workflows follow the same pattern and materialize Firebase files from secrets before build/analyze/test.

# Sync and Auth Integration

This document covers the currently implemented optional backend auth and sync architecture.

## 1. High-Level Behavior

- Users can use the app fully offline without signing in.
- Auth is required only for backend-connected features (primarily cloud sync).
- Sync is feature-flag gated and can be disabled at runtime.

## 2. Auth Flow (Optional)

### Components

- `BackendAuthClient` (`packages/integrations/backend_api`)
- `BackendAuthService` (`apps/mobile/lib/core/auth/backend_auth_service.dart`)
- `AuthSessionStore` / `SecureStorageAuthSessionStore` (`packages/integrations/auth_session`)
- `AuthScreen` (`apps/mobile/lib/features/auth/presentation/views/auth_screen.dart`)

### Supported auth operations

- Register
- Login
- Refresh token
- Logout
- Fetch current profile (`/auth/me`)

Session is persisted in secure storage and exposed as a Riverpod stream provider.

## 3. Sync Feature Gating and Readiness

Sync readiness provider checks:

1. Backend integration flag enabled
2. Sync feature flag enabled
3. API base URL configured
4. Auth session available and authenticated

Readiness statuses used by UI:

- `ready`
- `disabledByFeatureFlag`
- `missingApiConfiguration`
- `checkingAuthentication`
- `authenticationRequired`

## 4. Sync v1 Data Model

### Local sync tables

- `sync_outbox`
  - operation id, entity type/id, operation type, JSON payload, attempts, errors, timestamps
- `sync_state`
  - last success/attempt, next retry time, cursor, consecutive failures

### Synced entity types

- `collection`
- `item`
- `tag`

## 5. Outbox Write Strategy

When local mutation occurs in repositories:

- mutation persists locally first
- corresponding sync outbox operation is enqueued

Operation IDs are deterministic:

```text
<entityType>:<entityId>:<operationType>
```

This naturally coalesces duplicate same-entity operations.

## 6. Initial Outbox Seeding

`SyncOutboxBootstrapper` can seed outbox from existing local data:

- used before first sync attempt if queue is empty
- guarded by prefs keys to avoid repeated heavy seeding
- can be manually rebuilt from diagnostics

## 7. Sync Request/Response Contract

Sync transport package models currently support:

### Request

- `schemaVersion`
- `deviceId`
- `clientRequestId`
- `lastSyncAt`
- `changes` (`collections`, `items`, `tags`)

### Response

- `lastSyncAt`
- `serverChanges` (`collections`, `items`, `tags`)
- `conflicts`
- counters for synced entities and resolved conflicts

## 8. Retry and Failure Handling

Sync orchestrator behavior:

- immediate retry for transient network errors (limited attempts)
- exponential/jittered scheduled retry window via `sync_state.nextRetryAt`
- auth-required responses stop execution and ask for sign-in

App lifecycle integration:

- on app start/resume, pending sync may auto-retry if readiness is satisfied and retry window has elapsed

## 9. Server Change Apply Rules

Server changes are applied transactionally with safeguards:

- skip applying server entity if pending local outbox op exists for that entity
- skip outdated server updates if local `updatedAt` is newer (with small skew tolerance)
- apply tags before items so relations can be re-linked immediately
- recalculate collection item counts after relevant mutations

## 10. Access Token Refresh During Sync

`DioSyncBackendClient` uses auth token provider that can:

- read current access token
- refresh token using `/auth/refresh` and `deviceId`
- retry unauthorized sync requests once after refresh
- clear invalid sessions on repeated unauthorized responses

## 11. Current Scope and Limitations

- Sync coverage is currently limited to collections, items, tags.
- Runtime rollout remains feature-flag gated by default.
- Additional production hardening (conflict policy expansion, broader test matrix, rollout controls) is still in progress.

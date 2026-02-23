# Firebase and Runtime Flags

This app uses Firebase for analytics, crash reporting, performance traces, and runtime feature flags.

## 1. Required Firebase Files

These files are expected at runtime and are gitignored in `apps/mobile/.gitignore`:

- `apps/mobile/lib/firebase_options.dart`
- `apps/mobile/android/app/google-services.json`
- `apps/mobile/ios/Runner/GoogleService-Info.plist`
- `apps/mobile/macos/Runner/GoogleService-Info.plist`

Generate/materialize via:

```bash
./scripts/setup_firebase.sh --require dart
```

## 2. Remote Config Keys

Runtime flags are read in `FirebaseServicesBootstrap`.

| Key | Default | Effect |
| --- | --- | --- |
| `app_analytics_collection_enabled` | `true` | Enables/disables analytics collection runtime behavior |
| `app_crashlytics_collection_enabled` | `true` | Enables/disables Crashlytics collection |
| `app_performance_collection_enabled` | `true` | Enables/disables Firebase Performance collection |
| `app_app_check_enabled` | `false` | Enables/disables Firebase App Check activation |
| `app_backend_integration_enabled` | `false` | Gates backend-auth integration paths |
| `app_auth_feature_enabled` | `true` | Gates account authentication UI/service availability |
| `app_sync_feature_enabled` | `false` | Gates sync transport and sync UI readiness |

## 3. Why Cloud Sync Can Still Look Disabled

Cloud Sync readiness requires all of the following:

1. `app_backend_integration_enabled = true`
2. `app_auth_feature_enabled = true`
3. `app_sync_feature_enabled = true`
4. API base URL available (`BACKEND_API_BASE_URL` or settings override)
5. Signed-in auth session (sync is optional, but auth is required for sync)

If any condition fails, the settings sync tile shows non-ready state and relevant CTA.

## 4. Fetch/Refresh Behavior

### Remote Config fetch intervals

- Debug builds: minimum fetch interval = 5 minutes
- Release builds: minimum fetch interval = 12 hours

### Auto refresh on app resume

- Runtime config auto-refresh is throttled:
  - Debug: at most every 1 minute
  - Release: at most every 15 minutes

### Manual refresh

In debug settings, use Firebase Runtime Config sheet and tap refresh:

- Refresh uses forced fetch (`forceFetch: true`)
- App re-applies analytics preference state after refresh

## 5. Debug Overrides for Local Development

There are optional debug-only `--dart-define` overrides:

- `BACKEND_USE_ENV_FLAG_OVERRIDES=true`
- `BACKEND_INTEGRATION_ENABLED=true|false`
- `BACKEND_AUTH_ENABLED=true|false`
- `BACKEND_SYNC_ENABLED=true|false`

These overrides are ignored unless `BACKEND_USE_ENV_FLAG_OVERRIDES=true` and build is debug.

## 6. Crashlytics Notes

Crashlytics collection is also constrained by debug behavior:

- Disabled by default in debug unless `ENABLE_CRASHLYTICS_IN_DEBUG=true`
- Always controlled by runtime flag + build mode logic

## 7. App Check Notes

- App Check is activated from runtime config via `app_app_check_enabled`.
- Provider strategy:
  - Android debug: `AndroidDebugProvider`
  - Android release: `AndroidPlayIntegrityProvider`
  - Apple debug: `AppleDebugProvider`
  - Apple release: `AppleAppAttestWithDeviceCheckFallbackProvider`
- On web/unsupported desktop platforms, App Check activation is skipped.

## 8. Troubleshooting Checklist

If sync tile does not enable after toggling Remote Config keys:

1. Confirm backend, auth, and sync keys are all `true`.
2. Trigger manual refresh from debug settings.
3. Verify fetch status and last fetch time in runtime config sheet.
4. Check API base URL configuration.
5. Ensure account is signed in.
6. If using debug defines, ensure override gate flag is enabled.

# Setup and Run

This guide reflects the current workspace setup and runtime requirements.

## 1. Prerequisites

- Flutter stable (CI uses `3.41.x`)
- Dart SDK compatible with workspace (`^3.11.0`)
- Xcode (iOS/macOS) and/or Android SDK

Check environment:

```bash
flutter doctor -v
dart --version
```

## 2. Install Dependencies

From workspace root:

```bash
dart pub get
```

## 3. Configure Metadata API Keys

Create `packages/common/env/.env`:

```env
GOOGLE_BOOKS_API_KEY=...
TMDB_API_KEY=...
TMDB_READ_ACCESS_TOKEN=...
IGDB_CLIENT_ID=...
IGDB_CLIENT_SECRET=...
```

The app reads these through `packages/common/env/lib/src/app_env.dart`.

## 4. Configure Firebase Files

`apps/mobile/lib/firebase_options.dart` and platform service files are expected to exist (they are gitignored).

Recommended approach:

```bash
./scripts/setup_firebase.sh --require dart
```

For Android builds:

```bash
./scripts/setup_firebase.sh --require dart --require android
```

Supported env vars (raw or base64):

- `FIREBASE_OPTIONS_DART` or `FIREBASE_OPTIONS_DART_BASE64`
- `FIREBASE_ANDROID_GOOGLE_SERVICES_JSON` or `FIREBASE_ANDROID_GOOGLE_SERVICES_JSON_BASE64`
- `FIREBASE_IOS_GOOGLE_SERVICE_INFO_PLIST` or `FIREBASE_IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64`
- `FIREBASE_MACOS_GOOGLE_SERVICE_INFO_PLIST` or `FIREBASE_MACOS_GOOGLE_SERVICE_INFO_PLIST_BASE64`

## 5. Generate Code

```bash
./scripts/build_all.sh
```

## 6. Run the App

```bash
cd apps/mobile
flutter run
```

## 7. Optional: Local Backend + Sync Integration

By default, backend/sync features are runtime-flag disabled.

### Option A: Use Firebase Remote Config only (recommended)

Set these keys to `true` in Remote Config:

- `app_backend_integration_enabled`
- `app_auth_feature_enabled`
- `app_sync_feature_enabled`

### Option B: Debug-only `--dart-define` overrides

Use only when explicitly needed for local testing:

```bash
flutter run \
  --dart-define=BACKEND_USE_ENV_FLAG_OVERRIDES=true \
  --dart-define=BACKEND_INTEGRATION_ENABLED=true \
  --dart-define=BACKEND_AUTH_ENABLED=true \
  --dart-define=BACKEND_SYNC_ENABLED=true \
  --dart-define=BACKEND_API_BASE_URL=http://localhost:4000
```

Android emulator usually needs `http://10.0.2.2:4000` instead of `localhost`.

## 8. Quality Commands

```bash
./scripts/analyze_all.sh
./scripts/test_all.sh
dart format --set-exit-if-changed .
```

Or via Makefile:

```bash
make build
make analyze
make test
make run
```

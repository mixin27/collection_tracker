# Quick Start

For full documentation, start at [documentation/README.md](documentation/README.md).

## Minimal Local Run

1. Install dependencies:

```bash
dart pub get
```

2. Create env file:

```bash
cat > packages/common/env/.env <<'ENV'
GOOGLE_BOOKS_API_KEY=...
TMDB_API_KEY=...
TMDB_READ_ACCESS_TOKEN=...
IGDB_CLIENT_ID=...
IGDB_CLIENT_SECRET=...
ENV
```

3. Materialize Firebase config files:

```bash
./scripts/setup_firebase.sh --require dart
```

4. Generate code:

```bash
./scripts/build_all.sh
```

5. Run app:

```bash
cd apps/mobile
flutter run
```

## Useful Commands

```bash
./scripts/analyze_all.sh
./scripts/test_all.sh
dart format --set-exit-if-changed .
```

## Optional: Local Backend/Sync Debug Run

```bash
cd apps/mobile
flutter run \
  --dart-define=BACKEND_USE_ENV_FLAG_OVERRIDES=true \
  --dart-define=BACKEND_INTEGRATION_ENABLED=true \
  --dart-define=BACKEND_SYNC_ENABLED=true \
  --dart-define=BACKEND_API_BASE_URL=http://localhost:4000
```

See [documentation/FIREBASE_AND_FLAGS.md](documentation/FIREBASE_AND_FLAGS.md) for runtime flag details.

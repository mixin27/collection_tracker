# Collection Tracker

Collection Tracker is an offline-first Flutter app for organizing personal collections (books, movies, games, and custom categories), with optional cloud sync and Firebase-powered observability.

## Current State

This repository is actively developed and already includes:

- Collection and item management (list/grid views, create/edit/delete)
- Tag system (assign tags, rename/merge/delete tags, bulk tag actions)
- Favorites and wishlist flows
- Item detail with price tracking and value history
- Statistics dashboard with valuation and distribution insights
- Import/export (JSON and CSV)
- Barcode scanner flow
- Localization support for 7 languages
- Custom design system and glass bottom navigation
- Firebase Crashlytics, Analytics (consent-based), Performance, Remote Config
- Optional backend auth and sync (feature-flag gated)

For a detailed status matrix, see [documentation/APP_PROGRESS.md](documentation/APP_PROGRESS.md).

## Tech Stack

- Flutter + Dart (workspace/monorepo)
- Riverpod (with code generation)
- Drift (local database)
- GoRouter (navigation)
- Firebase (Core, Analytics, Crashlytics, Performance, Remote Config)
- Dio (backend/sync transport)

## Workspace Layout

```text
apps/mobile/                  Flutter app
packages/core/domain/         Domain contracts/entities
packages/core/data/           Repository implementations
packages/common/ui/           Shared design system components
packages/common/utils/        Shared utilities
packages/common/env/          Compile-time env access (Envied)
packages/integrations/*       Database, analytics, auth session, backend API, sync API, etc.
documentation/                Project documentation hub
```

## Quick Start

1. Install dependencies:

```bash
dart pub get
```

2. Create API env file used by metadata integrations:

```bash
cat > packages/common/env/.env <<'ENV'
GOOGLE_BOOKS_API_KEY=...
TMDB_API_KEY=...
TMDB_READ_ACCESS_TOKEN=...
IGDB_CLIENT_ID=...
IGDB_CLIENT_SECRET=...
ENV
```

3. Materialize Firebase files (recommended, especially for CI/local parity):

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

Detailed setup instructions: [documentation/SETUP_AND_RUN.md](documentation/SETUP_AND_RUN.md)

## Cloud Sync Flags (Important)

Cloud Sync is enabled only when both Remote Config flags are `true`:

- `app_backend_integration_enabled`
- `app_sync_feature_enabled`

If either is `false`, sync UI/actions are disabled. Full explanation: [documentation/FIREBASE_AND_FLAGS.md](documentation/FIREBASE_AND_FLAGS.md)

## Documentation

- [documentation/README.md](documentation/README.md) - docs index
- [documentation/ARCHITECTURE.md](documentation/ARCHITECTURE.md) - architecture and runtime flow
- [documentation/APP_PROGRESS.md](documentation/APP_PROGRESS.md) - implemented vs in-progress features
- [documentation/SYNC_AND_AUTH.md](documentation/SYNC_AND_AUTH.md) - sync/auth integration details
- [documentation/LOCALIZATION.md](documentation/LOCALIZATION.md) - i18n status and workflow

## CI/CD

GitHub Actions currently runs:

- Analyze (`.github/workflows/ci.yaml`)
- Tests (`.github/workflows/ci.yaml`)
- PR checks (`.github/workflows/pr-checks.yaml`)
- Android release pipeline (`.github/workflows/release.yaml`)

Firebase secrets are materialized during CI using `scripts/setup_firebase.sh`.

## License

MIT. See [LICENSE](LICENSE).

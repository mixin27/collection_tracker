# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0+1] - 2026-01-28

### Added

- **Core Features**
  - Barcode scanning functionality for quick item entry.
  - Advanced search and filtering for collection items.
  - Comprehensive statistics dashboard.
  - Image upload and storage for collection items.
- **User Experience**
  - Interactive onboarding screens for first-time users.
  - Data portability with Export (JSON) and Import functionality.
- **Architecture & Infrastructure**
  - Integrated Metadata API for fetching item details (IGDB, etc.).
  - Robust Analytics package with multi-provider support and PII detection.
  - Centralized Logger service with file and console transport.
  - Reliable Database layer for local collection management.
  - Secure storage and persistent preferences services.
  - Environment variable management for API keys and configurations.
- **UI/UX**
  - Common UI widget library and utility extensions.
  - Modern routing configuration with `go_router`.

### Fixed

- Synced UI state after editing collection data.
- Improved accuracy of collection item counts.
- Resolved dependency conflicts in CI (analyzer, dart_style, build_runner).
- Addressed Android build failures by pinning stable dependency versions.

### CI/CD

- Automated GitHub Workflows for analysis, testing, and CI builds.
- Dynamic environment file generation for CI environments.

### Documentation

- Added comprehensive project documentation (License, Contributing, Quick Start).

## [0.0.1+1] - 2026-01-24

### Added

- Initial project setup and workspace configuration.
- Basic database schema for collections and items.

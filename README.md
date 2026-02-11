# Collection Tracker

A beautiful, feature-rich Flutter application for organizing and managing your collections (books, games, movies, comics, music, and more).

![Flutter](https://img.shields.io/badge/Flutter-3.38.7-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.4-0175C2?logo=dart)
![License](https://img.shields.io/badge/license-MIT-green)
[![CI](https://github.com/mixin27/collection_tracker/actions/workflows/ci.yaml/badge.svg)](https://github.com/mixin27/collection_tracker/actions/workflows/ci.yaml)

## 📱 Features

### ✨ Core Features
- **Multiple Collection Types**: Books, Games, Movies, Comics, Music, Custom
- **Item Management**: Add, view, edit, and delete items in your collections
- **Rich Item Details**: Title, barcode, description, images, condition, quantity, location
- **Beautiful UI**: Material 3 design with dark mode support
- **Smooth Animations**: Delightful user experience with fluid transitions
- **Offline First**: All data stored locally with Drift database

### 🎯 Coming Soon
- 📷 Barcode scanning with camera
- 🖼️ Image upload for items
- 🔍 Advanced search and filtering
- ⭐ Favorites and wish lists
- ☁️ Cloud sync across devices
- 📊 Statistics and insights
- 📤 Backup and restore
- 🌐 Multi-language support

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **MVVM** pattern:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, ViewModels, Widgets, State)       │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          Domain Layer                    │
│  (Entities, Use Cases, Repositories)     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Data Layer                     │
│  (Models, Repository Impl, DataSources)  │
└──────────────────────────────────────────┘
```

### 📦 Tech Stack

- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management with code generation
- **Drift**: Type-safe local database
- **Go Router**: Declarative routing
- **Freezed**: Immutable data classes
- **fpdart**: Functional programming (Either type)

### 🗂️ Project Structure

```
collection_tracker/
├── apps/mobile/              # Flutter application
├── packages/
│   ├── core/
│   │   ├── domain/          # Business logic
│   │   └── data/            # Data layer
│   ├── common/
│   │   ├── ui/              # Shared widgets
│   │   └── utils/           # Utilities
│   └── integrations/
│       ├── database/        # Drift database
│       ├── barcode_scanner/ # Scanner integration
│       └── metadata_api/    # API clients
└── scripts/                 # Build scripts
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/mixin27/collection_tracker.git
cd collection_tracker
```

2. **Install dependencies**
```bash
dart pub get
```

3. **Generate code**
```bash
./scripts/build_all.sh
```

Or manually:
```bash
cd apps/mobile
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**
```bash
cd apps/mobile
flutter run
```

## 🛠️ Development

### Available Scripts

```bash
# Setup workspace
./scripts/setup.sh

# Run code generation
./scripts/build_all.sh

# Watch mode for code generation
./scripts/build_watch.sh

# Run tests
./scripts/test_all.sh

# Analyze code
./scripts/analyze_all.sh

# Format code
./scripts/format_all.sh

# Clean all packages
./scripts/clean_all.sh
```

### Using Makefile

```bash
make setup    # Initial setup
make build    # Generate code
make test     # Run tests
make analyze  # Analyze code
make run      # Run the app
make clean    # Clean everything
```

### Code Generation

When you modify models, providers, or use Riverpod/Freezed annotations:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## 🧪 Testing

Run all tests:
```bash
./scripts/test_all.sh
```

Run tests for specific package:
```bash
cd packages/core/domain
dart test
```

Generate coverage:
```bash
./scripts/coverage.sh
```

<!-- ## 🐳 Docker Support

Build with Docker:
```bash
# Build development image
make docker-build-dev

# Start development environment
make docker-dev

# Build APK
make docker-build-apk

# Run tests
make docker-test
``` -->

## 📱 Building for Release

### Android

```bash
cd apps/mobile
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk

# Or build App Bundle for Play Store
flutter build appbundle --release
```

### iOS

```bash
cd apps/mobile
flutter build ios --release
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Drift for type-safe database operations
- All open-source contributors

## 📞 Support

If you have any questions or issues:

- 📧 Email: kyawzayartun.contact@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/mixin27/collection_tracker/issues)

## 🗺️ Roadmap

- [x] Barcode scanning with camera
- [x] Image upload and gallery
- [x] Advanced search and filters
- [ ] Cloud synchronization
- [ ] Import/Export data (CSV, JSON)
- [ ] Price tracking and statistics
- [ ] Loan tracking (who borrowed what)
- [ ] Multiple user profiles
- [ ] Desktop app (Windows, macOS, Linux)
- [ ] Web app

---

Made with ❤️ using Flutter

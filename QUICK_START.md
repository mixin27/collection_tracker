# Collection Tracker - Quick Start Guide

Get your Collection Tracker app up and running in minutes!

## ⚡ Quick Setup (5 minutes)

### 1. Prerequisites Check

```bash
# Verify Flutter is installed
flutter doctor

# You should see:
# ✓ Flutter (Channel stable, 3.24.0 or higher)
# ✓ Dart (3.2.0 or higher)
```

### 2. Install Dependencies

```bash
# From workspace root
dart pub get
```

### 3. Generate Code

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run code generation
./scripts/build_all.sh
```

### 4. Run the App

```bash
cd apps/mobile
flutter run
```

That's it! 🎉 Your app should now be running.

## 📱 First Time Usage

### Create Your First Collection

1. Tap **"New Collection"** button
2. Enter collection name (e.g., "My Books")
3. Select collection type (Books, Games, Movies, etc.)
4. Optionally add a description
5. Tap **"Create Collection"**

### Add Your First Item

1. Tap on your collection
2. Tap **"Add Item"**
3. Enter item title (required)
4. Optionally add:
   - Barcode (ISBN, UPC, etc.)
   - Description
   - More details coming soon!
5. Tap **"Add Item"**

### View and Manage Items

1. From collection detail, tap **"View Items"**
2. See all your items in a beautiful list
3. Tap any item to view full details
4. Use the menu to edit or delete items

## 🛠️ Development Workflow

### Daily Development

```bash
# Terminal 1: Watch for code changes
cd apps/mobile
flutter pub run build_runner watch --delete-conflicting-outputs

# Terminal 2: Run the app
flutter run

# Press 'r' for hot reload
# Press 'R' for hot restart
```

### Making Changes

1. **Modify code** in your IDE
2. **Hot reload** automatically (or press 'r')
3. **If you modify models/providers**, code is auto-generated
4. **Test your changes** immediately

### Common Commands

```bash
# Using Makefile (recommended)
make build    # Generate code
make test     # Run tests
make analyze  # Check code quality
make format   # Format code
make run      # Run app

# Or using scripts directly
./scripts/build_all.sh
./scripts/test_all.sh
./scripts/analyze_all.sh
```

## 🔧 Troubleshooting

### "No such file or directory" for .g.dart files

**Solution:**
```bash
./scripts/build_all.sh
```

### "The getter 'xxx' isn't defined"

**Solution:**
```bash
cd apps/mobile
flutter pub run build_runner build --delete-conflicting-outputs
```

### Import errors

**Solution:**
```bash
dart pub get
flutter pub get
```

### App won't start

**Solution:**
```bash
# Clean and rebuild
./scripts/clean_all.sh
dart pub get
./scripts/build_all.sh
flutter run
```

### Database errors

**Solution:** Database is created automatically on first run. If you see errors:
```bash
# Uninstall app and reinstall
flutter clean
flutter run
```

## 📂 Project Structure

```
collection_tracker/
├── apps/mobile/              # Your Flutter app
│   └── lib/
│       ├── main.dart        # App entry point
│       ├── features/        # Features (collections, items, etc.)
│       └── core/            # Core app functionality
│
├── packages/                # Reusable packages
│   ├── core/
│   │   ├── domain/         # Business logic
│   │   └── data/           # Data layer
│   ├── common/
│   │   ├── ui/             # Shared widgets
│   │   └── utils/          # Utilities
│   └── integrations/       # Third-party integrations
│
└── scripts/                # Build scripts
```

## 🎯 What's Next?

### Explore Features

- ✅ Create multiple collections
- ✅ Add items with details
- ✅ View statistics
- ✅ Dark mode (automatic)
- ✅ Beautiful Material 3 UI

### Coming Soon

- 📷 Barcode scanning
- 🖼️ Photo upload
- 🔍 Search functionality
- ☁️ Cloud sync
- 📊 Advanced statistics

### Customize

- **Change theme**: Edit `packages/common/ui/lib/theme/app_theme.dart`
- **Add features**: Create new feature folders in `apps/mobile/lib/features/`
- **Modify database**: Edit tables in `packages/integrations/database/lib/tables/`

## 📚 Learn More

### Documentation

<!-- - [Full Setup Guide](BUILD_AND_RUN_GUIDE.md) - Detailed setup instructions -->
- [Architecture Guide](documentation/ARCHITECTURE.md) - Learn about the architecture
- [Contributing Guide](CONTRIBUTING.md) - How to contribute

### Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Drift Documentation](https://drift.simonbinder.eu)

## 💡 Pro Tips

1. **Use hot reload** - Press 'r' instead of restarting the app
2. **Keep build_runner watching** - Saves time during development
3. **Use the Makefile** - Easier than remembering script paths
4. **Check analysis** - Run `make analyze` before committing
5. **Format code** - Run `make format` to maintain consistency

## 🆘 Need Help?

- 📖 Check the [README.md](README.md)
- 🐛 Report issues on GitHub
- 💬 Ask questions in Discussions
- 📧 Email: kyawzayartun.contact@gmail.com

## ✅ Checklist

Before you start coding:

- [ ] Flutter doctor shows no issues
- [ ] Dependencies installed (`dart pub get`)
- [ ] Code generated (`./scripts/build_all.sh`)
- [ ] App runs successfully (`flutter run`)
- [ ] You can create a collection
- [ ] You can add an item

You're all set! Happy coding! 🚀

<!-- ---

**Need more details?** Check out the [full documentation](BUILD_AND_RUN_GUIDE.md). -->

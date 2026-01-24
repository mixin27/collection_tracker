#!/bin/bash
set -e

echo "🚀 Setting up Collection Tracker workspace..."
echo ""

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "❌ Dart SDK is not installed. Please install Dart first."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✓ Dart SDK found: $(dart --version 2>&1 | head -n 1)"
echo "✓ Flutter found: $(flutter --version 2>&1 | head -n 1)"
echo ""

# Get dependencies for workspace
echo "📦 Getting dependencies for all packages..."
dart pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to get dependencies"
    exit 1
fi

echo ""
echo "✓ Dependencies installed successfully"
echo ""

# Run code generation
echo "🔨 Running code generation..."
./scripts/build_all.sh

if [ $? -ne 0 ]; then
    echo "⚠️  Code generation had some issues, but continuing..."
fi

echo ""
echo "🎉 Workspace setup complete!"
echo ""
echo "Next steps:"
echo "  1. Open the workspace in your IDE"
echo "  2. Run 'make run' or 'cd apps/mobile && flutter run' to start the app"
echo "  3. Run 'make test' to run all tests"
echo ""

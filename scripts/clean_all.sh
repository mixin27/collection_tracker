#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workspace_packages.sh"

echo "🧹 Cleaning all packages..."
echo ""

# Function to clean a package
clean_package() {
    local package_path=$1
    local package_name=$2

    if [ -d "$package_path" ]; then
        echo "Cleaning $package_name..."
        cd "$package_path"

        # Remove generated files
        find . -name "*.g.dart" -type f -delete
        find . -name "*.freezed.dart" -type f -delete

        # Remove .dart_tool and build directories
        rm -rf .dart_tool
        rm -rf build
        rm -rf .packages

        if [[ "$package_path" == *"apps/mobile"* ]]; then
            flutter clean > /dev/null 2>&1
        fi

        echo "✓ Cleaned $package_name"
        cd - > /dev/null
    fi
}

# Get the workspace root directory
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKSPACE_ROOT"

# Clean all packages
for entry in "${WORKSPACE_PACKAGES_WITH_APP[@]}"; do
    package_path="${entry%%:*}"
    package_name="${entry#*:}"
    clean_package "$package_path" "$package_name"
done

# Clean workspace root
rm -rf .dart_tool

echo ""
echo "✅ All packages cleaned successfully!"
echo ""
echo "Run 'dart pub get' to restore dependencies"
echo "Run './scripts/build_all.sh' to regenerate code"

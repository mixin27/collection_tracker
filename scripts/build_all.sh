#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workspace_packages.sh"

echo "🔨 Running code generation for all packages..."
echo ""

BUILD_ERRORS=0

# Function to run build_runner for a package
run_build() {
    local package_path=$1
    local package_name=$2

    if [ -d "$package_path" ]; then
        echo "Building $package_name..."
        cd "$package_path"

        if [ -f "pubspec.yaml" ] && grep -q "build_runner" "pubspec.yaml"; then
            if [[ "$package_path" == *"apps/mobile"* ]]; then
                flutter pub run build_runner build --delete-conflicting-outputs
            else
                dart run build_runner build --delete-conflicting-outputs
            fi

            if [ $? -ne 0 ]; then
                echo "❌ Build failed for $package_name"
                BUILD_ERRORS=$((BUILD_ERRORS + 1))
            else
                echo "✓ Build completed for $package_name"
            fi
        else
            echo "⊘ No build_runner in $package_name, skipping..."
        fi

        cd - > /dev/null
        echo ""
    fi
}

# Get the workspace root directory
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKSPACE_ROOT"

# Build packages in order (dependencies first)
for entry in "${WORKSPACE_PACKAGES_WITH_APP[@]}"; do
    package_path="${entry%%:*}"
    package_name="${entry#*:}"
    run_build "$package_path" "$package_name"
done

if [ $BUILD_ERRORS -eq 0 ]; then
    echo "✅ All builds completed successfully!"
    exit 0
else
    echo "⚠️  $BUILD_ERRORS package(s) failed to build"
    exit 1
fi

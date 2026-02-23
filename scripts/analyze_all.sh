#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workspace_packages.sh"

echo "🔍 Analyzing all packages..."
echo ""

ANALYZE_ERRORS=0
TOTAL_PACKAGES=0

# Function to analyze a package
analyze_package() {
    local package_path=$1
    local package_name=$2

    if [ -d "$package_path" ]; then
        echo "Analyzing $package_name..."
        cd "$package_path"

        TOTAL_PACKAGES=$((TOTAL_PACKAGES + 1))

        if [[ "$package_path" == *"apps/mobile"* ]]; then
            flutter analyze
        else
            dart analyze
        fi

        if [ $? -ne 0 ]; then
            echo "❌ Analysis failed for $package_name"
            ANALYZE_ERRORS=$((ANALYZE_ERRORS + 1))
        else
            echo "✓ Analysis passed for $package_name"
        fi

        cd - > /dev/null
        echo ""
    fi
}

# Get the workspace root directory
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKSPACE_ROOT"

# Analyze all packages
for entry in "${WORKSPACE_PACKAGES_WITH_APP[@]}"; do
    package_path="${entry%%:*}"
    package_name="${entry#*:}"
    analyze_package "$package_path" "$package_name"
done

echo "════════════════════════════════════════"
if [ $ANALYZE_ERRORS -eq 0 ]; then
    echo "✅ All $TOTAL_PACKAGES package(s) analyzed successfully!"
    exit 0
else
    echo "❌ $ANALYZE_ERRORS out of $TOTAL_PACKAGES package(s) have analysis issues"
    exit 1
fi

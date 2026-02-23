#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workspace_packages.sh"

echo "📊 Generating consolidated test coverage report..."
echo ""

# Get the workspace root directory
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKSPACE_ROOT"

# Create a temporary directory for consolidated coverage data
ROOT_COVERAGE_DIR="$WORKSPACE_ROOT/coverage"
rm -rf "$ROOT_COVERAGE_DIR"
mkdir -p "$ROOT_COVERAGE_DIR"

# Accumulator for lcov arguments
LCOV_ARGS=""

# Function to run coverage for a package
run_coverage() {
    local package_path=$1
    local package_name=$2

    if [ -d "$package_path" ] && [ -d "$package_path/test" ]; then
        # Check if there are actually any *_test.dart files
        if find "$package_path/test" -name "*_test.dart" -print -quit | grep -q .; then
            echo "Processing $package_name..."
            cd "$package_path"

            # Remove old coverage data
            rm -rf coverage

            if grep -q "sdk: flutter" pubspec.yaml; then
                flutter test --coverage
            else
                dart test --coverage=coverage
                if dart pub global list | grep -q "coverage"; then
                    dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
                fi
            fi

            if [ -f "coverage/lcov.info" ]; then
                # Prefix the paths in lcov.info with the package path so they are correct from the root
                # This is important for merging
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "s|SF:lib/|SF:$package_path/lib/|g" coverage/lcov.info
                else
                    sed -i "s|SF:lib/|SF:$package_path/lib/|g" coverage/lcov.info
                fi

                LCOV_ARGS="$LCOV_ARGS -a $WORKSPACE_ROOT/$package_path/coverage/lcov.info"
                echo "✓ Coverage data collected for $package_name"
            else
                echo "⚠️ No coverage data produced for $package_name"
            fi

            cd - > /dev/null
            echo ""
        fi
    fi
}

# Process all relevant packages
for entry in "${WORKSPACE_PACKAGES_WITH_APP[@]}"; do
    package_path="${entry%%:*}"
    package_name="${entry#*:}"
    run_coverage "$package_path" "$package_name"
done

echo "════════════════════════════════════════"

if [ -n "$LCOV_ARGS" ]; then
    echo "📦 Merging coverage reports..."
    lcov $LCOV_ARGS -o "$ROOT_COVERAGE_DIR/lcov.info"

    if command -v genhtml &> /dev/null; then
        echo "🎨 Generating HTML report..."
        genhtml "$ROOT_COVERAGE_DIR/lcov.info" -o "$ROOT_COVERAGE_DIR/html"
        echo ""
        echo "✅ Consolidated coverage report generated at: $ROOT_COVERAGE_DIR/html/index.html"
    else
        echo "✅ Consolidated lcov.info generated at: $ROOT_COVERAGE_DIR/lcov.info"
        echo "💡 Install lcov (brew install lcov) to generate HTML reports."
    fi
else
    echo "❌ No coverage data collected."
fi

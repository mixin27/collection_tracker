#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workspace_packages.sh"

echo "🧪 Running tests for all packages..."
echo ""

TEST_ERRORS=0
TOTAL_TESTS=0

# Function to run tests for a package
run_tests() {
    local package_path=$1
    local package_name=$2

    if [ -d "$package_path" ]; then
        if [ -d "$package_path/test" ]; then
            # Check if there are actually any *_test.dart files
            if find "$package_path/test" -name "*_test.dart" -print -quit | grep -q .; then
                echo "Testing $package_name..."
                cd "$package_path"

                TOTAL_TESTS=$((TOTAL_TESTS + 1))

                if grep -q "sdk: flutter" pubspec.yaml; then
                    flutter test
                else
                    dart test
                fi
            else
                echo "⊘ No test files found in $package_name/test, skipping..."
                 # Don't increment TOTAL_TESTS because we didn't run anything
                 # Treat as success (or at least not failure)
            fi

            if [ $? -ne 0 ]; then
                echo "❌ Tests failed for $package_name"
                TEST_ERRORS=$((TEST_ERRORS + 1))
            else
                echo "✓ Tests passed for $package_name"
            fi

            cd - > /dev/null
            echo ""
        else
            echo "⊘ No tests found for $package_name, skipping..."
            echo ""
        fi
    fi
}

# Get the workspace root directory
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKSPACE_ROOT"

# Run tests for all packages
for entry in "${WORKSPACE_PACKAGES_WITH_APP[@]}"; do
    package_path="${entry%%:*}"
    package_name="${entry#*:}"
    run_tests "$package_path" "$package_name"
done

echo "════════════════════════════════════════"
if [ $TEST_ERRORS -eq 0 ]; then
    echo "✅ All $TOTAL_TESTS test suite(s) passed!"
    exit 0
else
    echo "❌ $TEST_ERRORS out of $TOTAL_TESTS test suite(s) failed"
    exit 1
fi

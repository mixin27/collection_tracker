#!/bin/bash
set -e

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
analyze_package "packages/core/domain" "core_domain"
analyze_package "packages/core/data" "core_data"
analyze_package "packages/common/ui" "common_ui"
analyze_package "packages/common/utils" "common_utils"
analyze_package "packages/integrations/database" "integration_database"
analyze_package "packages/integrations/barcode_scanner" "integration_barcode_scanner"
analyze_package "packages/integrations/metadata_api" "integration_metadata_api"
analyze_package "packages/integrations/analytics" "integration_analytics"
analyze_package "packages/integrations/logging" "integration_logging"
analyze_package "packages/integrations/storage" "integration_storage"
analyze_package "packages/integrations/payment" "integration_payment"
analyze_package "apps/mobile" "mobile_app"

echo "════════════════════════════════════════"
if [ $ANALYZE_ERRORS -eq 0 ]; then
    echo "✅ All $TOTAL_PACKAGES package(s) analyzed successfully!"
    exit 0
else
    echo "❌ $ANALYZE_ERRORS out of $TOTAL_PACKAGES package(s) have analysis issues"
    exit 1
fi

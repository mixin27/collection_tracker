#!/bin/bash
set -e

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
clean_package "packages/core/domain" "core_domain"
clean_package "packages/core/data" "core_data"
clean_package "packages/common/env" "common_env"
clean_package "packages/common/ui" "common_ui"
clean_package "packages/common/utils" "common_utils"
clean_package "packages/integrations/database" "integration_database"
clean_package "packages/integrations/barcode_scanner" "integration_barcode_scanner"
clean_package "packages/integrations/metadata_api" "integration_metadata_api"
clean_package "packages/integrations/analytics" "integration_analytics"
clean_package "packages/integrations/logger" "integration_logging"
clean_package "packages/integrations/storage" "integration_storage"
clean_package "packages/integrations/payment" "integration_payment"
clean_package "apps/mobile" "mobile_app"

# Clean workspace root
rm -rf .dart_tool

echo ""
echo "✅ All packages cleaned successfully!"
echo ""
echo "Run 'dart pub get' to restore dependencies"
echo "Run './scripts/build_all.sh' to regenerate code"

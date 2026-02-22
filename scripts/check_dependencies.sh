#!/bin/bash

echo "🔍 Checking for outdated dependencies..."
echo ""

# Function to check dependencies for a package
check_deps() {
    local package_path=$1
    local package_name=$2

    if [ -d "$package_path" ]; then
        echo "Checking $package_name..."
        cd "$package_path"

        if [[ "$package_path" == *"apps/mobile"* ]]; then
            flutter pub outdated
        else
            dart pub outdated
        fi

        cd - > /dev/null
        echo ""
    fi
}

# Get the workspace root directory
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKSPACE_ROOT"

check_deps "apps/mobile" "mobile_app"
check_deps "packages/core/domain" "core_domain"
check_deps "packages/core/data" "core_data"
check_deps "packages/common/env" "common_env"
check_deps "packages/common/ui" "common_ui"
check_deps "packages/common/utils" "common_utils"
check_deps "packages/integrations/analytics" "integration_analytics"
check_deps "packages/integrations/auth_session" "integration_auth_session"
check_deps "packages/integrations/backend_api" "integration_backend_api"
check_deps "packages/integrations/barcode_scanner" "integration_barcode_scanner"
check_deps "packages/integrations/database" "integration_database"
check_deps "packages/integrations/firebase_services" "integration_firebase_services"
check_deps "packages/integrations/logger" "integration_logging"
check_deps "packages/integrations/metadata_api" "integration_metadata_api"
check_deps "packages/integrations/payment" "integration_payment"
check_deps "packages/integrations/storage" "integration_storage"
check_deps "packages/integrations/sync_api" "integration_sync_api"

echo "✓ Dependency check complete"

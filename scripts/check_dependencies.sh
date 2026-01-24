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

echo "✓ Dependency check complete"

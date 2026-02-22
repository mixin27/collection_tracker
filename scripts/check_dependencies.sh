#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workspace_packages.sh"

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

for entry in "${WORKSPACE_PACKAGES_APP_FIRST[@]}"; do
    package_path="${entry%%:*}"
    package_name="${entry#*:}"
    check_deps "$package_path" "$package_name"
done

echo "✓ Dependency check complete"

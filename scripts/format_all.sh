#!/bin/bash
set -e

echo "✨ Formatting all Dart code..."
echo ""

# Get the workspace root directory
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKSPACE_ROOT"

# Format all Dart files
dart format .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All code formatted successfully!"
else
    echo ""
    echo "❌ Formatting failed"
    exit 1
fi

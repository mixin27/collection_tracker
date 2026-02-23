#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/apps/mobile"

mkdir -p /tmp/clang_module_cache

echo "Generating icon and Play Store assets..."
CLANG_MODULE_CACHE_PATH=/tmp/clang_module_cache \
  swift "$APP_DIR/tool/generate_brand_assets.swift"

echo "Updating launcher icons for Android and iOS..."
(
  cd "$APP_DIR"
  flutter pub run flutter_launcher_icons -f flutter_launcher_icons.yaml
)

echo "Brand assets updated."

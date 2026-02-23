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

echo "Syncing Android adaptive foreground densities from source asset..."
FOREGROUND_SRC="$APP_DIR/assets/icons/logo_foreground.png"
for entry in "mdpi:108" "hdpi:162" "xhdpi:216" "xxhdpi:324" "xxxhdpi:432"; do
  density="${entry%%:*}"
  size="${entry##*:}"
  target="$APP_DIR/android/app/src/main/res/drawable-${density}/ic_launcher_foreground.png"
  sips -s format png -z "$size" "$size" "$FOREGROUND_SRC" --out "$target" >/dev/null
done

echo "Brand assets updated."

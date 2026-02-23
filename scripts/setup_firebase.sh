#!/bin/bash
set -euo pipefail

# Materialize Firebase config files from environment variables.
# Supports both raw and base64 values for each target file.
#
# Supported environment variables:
# - FIREBASE_OPTIONS_DART or FIREBASE_OPTIONS_DART_BASE64
# - FIREBASE_ANDROID_GOOGLE_SERVICES_JSON or FIREBASE_ANDROID_GOOGLE_SERVICES_JSON_BASE64
# - FIREBASE_IOS_GOOGLE_SERVICE_INFO_PLIST or FIREBASE_IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64
# - FIREBASE_MACOS_GOOGLE_SERVICE_INFO_PLIST or FIREBASE_MACOS_GOOGLE_SERVICE_INFO_PLIST_BASE64
#
# Optional flags:
# - --require <target>  where target in: dart, android, ios, macos

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$WORKSPACE_ROOT/apps/mobile"

declare -a REQUIRED_TARGETS=()

usage() {
  cat <<EOF
Usage: ./scripts/setup_firebase.sh [--require dart|android|ios|macos]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --require)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --require" >&2
        usage
        exit 1
      fi
      REQUIRED_TARGETS+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

for target in "${REQUIRED_TARGETS[@]-}"; do
  if [[ -z "$target" ]]; then
    continue
  fi
  case "$target" in
    dart|android|ios|macos)
      ;;
    *)
      echo "Unknown required target: $target" >&2
      usage
      exit 1
      ;;
  esac
done

is_required() {
  local target="$1"
  for required in "${REQUIRED_TARGETS[@]-}"; do
    if [[ -z "$required" ]]; then
      continue
    fi
    if [[ "$required" == "$target" ]]; then
      return 0
    fi
  done
  return 1
}

decode_base64_to_file() {
  local encoded="$1"
  local out_file="$2"

  if printf '%s' "$encoded" | base64 --decode > "$out_file" 2>/dev/null; then
    return 0
  fi

  printf '%s' "$encoded" | base64 -D > "$out_file"
}

validate_target_config() {
  local target="$1"
  local out_file="$2"
  local source_label="$3"

  if [[ ! -s "$out_file" ]]; then
    echo "[error] '$target' config is empty from $source_label." >&2
    return 1
  fi

  case "$target" in
    dart)
      if ! grep -q "class DefaultFirebaseOptions" "$out_file"; then
        echo "[error] '$out_file' does not look like FlutterFire Dart config." >&2
        echo "        Check FIREBASE_OPTIONS_DART / FIREBASE_OPTIONS_DART_BASE64." >&2
        echo "        Source used: $source_label" >&2
        return 1
      fi
      ;;
    android)
      if ! grep -q '"project_info"' "$out_file"; then
        echo "[error] '$out_file' does not look like Android google-services.json." >&2
        echo "        Check FIREBASE_ANDROID_GOOGLE_SERVICES_JSON / _BASE64." >&2
        echo "        Source used: $source_label" >&2
        return 1
      fi
      ;;
    ios|macos)
      if ! grep -q "<plist" "$out_file"; then
        echo "[error] '$out_file' does not look like Apple GoogleService-Info.plist." >&2
        echo "        Check FIREBASE_${target^^}_GOOGLE_SERVICE_INFO_PLIST / _BASE64." >&2
        echo "        Source used: $source_label" >&2
        return 1
      fi
      ;;
  esac

  return 0
}

write_secret_file() {
  local target="$1"
  local out_file="$2"
  local raw_var_name="$3"
  local b64_var_name="$4"

  local raw_value="${!raw_var_name:-}"
  local b64_value="${!b64_var_name:-}"
  local source_label=""

  mkdir -p "$(dirname "$out_file")"

  if [[ -n "$b64_value" ]]; then
    decode_base64_to_file "$b64_value" "$out_file"
    source_label="$b64_var_name"
    if validate_target_config "$target" "$out_file" "$source_label"; then
      echo "[ok] Wrote $target config: $out_file (source: $source_label)"
      return 0
    fi

    if [[ -n "$raw_value" ]]; then
      echo "[warn] Falling back to $raw_var_name for '$target'..." >&2
      printf '%s' "$raw_value" > "$out_file"
      source_label="$raw_var_name"
      if validate_target_config "$target" "$out_file" "$source_label"; then
        echo "[ok] Wrote $target config: $out_file (source: $source_label)"
        return 0
      fi
    fi

    return 1
  fi

  if [[ -n "$raw_value" ]]; then
    printf '%s' "$raw_value" > "$out_file"
    source_label="$raw_var_name"
    if validate_target_config "$target" "$out_file" "$source_label"; then
      echo "[ok] Wrote $target config: $out_file (source: $source_label)"
      return 0
    fi
    return 1
  fi

  if is_required "$target"; then
    echo "[error] Missing required Firebase config for '$target'." >&2
    echo "  Expected $raw_var_name or $b64_var_name." >&2
    return 1
  fi

  echo "[skip] No Firebase config provided for '$target', skipping."
  return 0
}

FAILURES=0

write_secret_file \
  "dart" \
  "$APP_DIR/lib/firebase_options.dart" \
  "FIREBASE_OPTIONS_DART" \
  "FIREBASE_OPTIONS_DART_BASE64" || FAILURES=$((FAILURES + 1))

write_secret_file \
  "android" \
  "$APP_DIR/android/app/google-services.json" \
  "FIREBASE_ANDROID_GOOGLE_SERVICES_JSON" \
  "FIREBASE_ANDROID_GOOGLE_SERVICES_JSON_BASE64" || FAILURES=$((FAILURES + 1))

write_secret_file \
  "ios" \
  "$APP_DIR/ios/Runner/GoogleService-Info.plist" \
  "FIREBASE_IOS_GOOGLE_SERVICE_INFO_PLIST" \
  "FIREBASE_IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64" || FAILURES=$((FAILURES + 1))

write_secret_file \
  "macos" \
  "$APP_DIR/macos/Runner/GoogleService-Info.plist" \
  "FIREBASE_MACOS_GOOGLE_SERVICE_INFO_PLIST" \
  "FIREBASE_MACOS_GOOGLE_SERVICE_INFO_PLIST_BASE64" || FAILURES=$((FAILURES + 1))

if [[ $FAILURES -gt 0 ]]; then
  echo "Firebase setup failed with $FAILURES missing required target(s)." >&2
  exit 1
fi

echo "Firebase setup completed."

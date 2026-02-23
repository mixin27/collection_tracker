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

  if printf '%s' "$encoded" | base64 -D > "$out_file" 2>/dev/null; then
    return 0
  fi

  return 1
}

write_plain_to_file() {
  local value="$1"
  local out_file="$2"
  printf '%s' "$value" > "$out_file"
}

validate_target_config() {
  local target="$1"
  local out_file="$2"
  local source_label="$3"
  local quiet="${4:-0}"

  if [[ ! -s "$out_file" ]]; then
    if [[ "$quiet" != "1" ]]; then
      echo "[error] '$target' config is empty from $source_label." >&2
    fi
    return 1
  fi

  case "$target" in
    dart)
      if ! grep -q "class DefaultFirebaseOptions" "$out_file"; then
        if [[ "$quiet" != "1" ]]; then
          echo "[error] '$out_file' does not look like FlutterFire Dart config." >&2
          echo "        Check FIREBASE_OPTIONS_DART / FIREBASE_OPTIONS_DART_BASE64." >&2
          echo "        Source used: $source_label" >&2
        fi
        return 1
      fi
      ;;
    android)
      if ! grep -q '"project_info"' "$out_file"; then
        if [[ "$quiet" != "1" ]]; then
          echo "[error] '$out_file' does not look like Android google-services.json." >&2
          echo "        Check FIREBASE_ANDROID_GOOGLE_SERVICES_JSON / _BASE64." >&2
          echo "        Source used: $source_label" >&2
        fi
        return 1
      fi
      ;;
    ios|macos)
      if ! grep -q "<plist" "$out_file"; then
        if [[ "$quiet" != "1" ]]; then
          local target_upper
          target_upper="$(printf '%s' "$target" | tr '[:lower:]' '[:upper:]')"
          echo "[error] '$out_file' does not look like Apple GoogleService-Info.plist." >&2
          echo "        Check FIREBASE_${target_upper}_GOOGLE_SERVICE_INFO_PLIST / _BASE64." >&2
          echo "        Source used: $source_label" >&2
        fi
        return 1
      fi
      ;;
  esac

  return 0
}

emit_invalid_target_error() {
  local target="$1"
  local out_file="$2"
  local source_label="$3"

  case "$target" in
    dart)
      echo "[error] '$out_file' does not look like FlutterFire Dart config." >&2
      echo "        Check FIREBASE_OPTIONS_DART / FIREBASE_OPTIONS_DART_BASE64." >&2
      echo "        Source used: $source_label" >&2
      ;;
    android)
      echo "[error] '$out_file' does not look like Android google-services.json." >&2
      echo "        Check FIREBASE_ANDROID_GOOGLE_SERVICES_JSON / _BASE64." >&2
      echo "        Source used: $source_label" >&2
      ;;
    ios|macos)
      local target_upper
      target_upper="$(printf '%s' "$target" | tr '[:lower:]' '[:upper:]')"
      echo "[error] '$out_file' does not look like Apple GoogleService-Info.plist." >&2
      echo "        Check FIREBASE_${target_upper}_GOOGLE_SERVICE_INFO_PLIST / _BASE64." >&2
      echo "        Source used: $source_label" >&2
      ;;
  esac
}

strip_surrounding_quotes() {
  local value="$1"
  if [[ ${#value} -ge 2 ]]; then
    local first="${value:0:1}"
    local last="${value: -1}"
    if [[ "$first" == "$last" && ( "$first" == "\"" || "$first" == "'" ) ]]; then
      printf '%s' "${value:1:${#value}-2}"
      return 0
    fi
  fi
  printf '%s' "$value"
}

looks_like_file_path_secret() {
  local value="$1"
  if [[ "$value" == /* && "$value" != *$'\n'* ]]; then
    return 0
  fi
  if [[ "$value" =~ ^[[:alnum:]_.-]+(\.[[:alnum:]]+)$ && "$value" != *$'\n'* ]]; then
    return 0
  fi
  return 1
}

try_write_plain_candidate() {
  local target="$1"
  local out_file="$2"
  local source_label="$3"
  local candidate="$4"

  write_plain_to_file "$candidate" "$out_file"
  validate_target_config "$target" "$out_file" "$source_label" "1"
}

try_write_base64_candidate() {
  local target="$1"
  local out_file="$2"
  local source_label="$3"
  local candidate="$4"

  if ! decode_base64_to_file "$candidate" "$out_file"; then
    return 1
  fi

  validate_target_config "$target" "$out_file" "$source_label" "1"
}

try_value_variants_as_plain() {
  local target="$1"
  local out_file="$2"
  local source_label="$3"
  local value="$4"

  local candidate="$value"
  if try_write_plain_candidate "$target" "$out_file" "$source_label" "$candidate"; then
    return 0
  fi

  candidate="${value//$'\r'/}"
  if [[ "$candidate" != "$value" ]]; then
    if try_write_plain_candidate "$target" "$out_file" "$source_label" "$candidate"; then
      return 0
    fi
  fi

  local unquoted
  unquoted="$(strip_surrounding_quotes "$value")"
  if [[ "$unquoted" != "$value" ]]; then
    if try_write_plain_candidate "$target" "$out_file" "$source_label" "$unquoted"; then
      return 0
    fi
  fi

  local unquoted_no_cr="${unquoted//$'\r'/}"
  if [[ "$unquoted_no_cr" != "$unquoted" ]]; then
    if try_write_plain_candidate "$target" "$out_file" "$source_label" "$unquoted_no_cr"; then
      return 0
    fi
  fi

  # Handle secrets pasted as escaped text (e.g. with '\n' sequences).
  if [[ "$value" == *"\\n"* && "$value" != *$'\n'* ]]; then
    local escaped
    escaped="$(printf '%b' "$value")"
    if try_write_plain_candidate "$target" "$out_file" "$source_label" "$escaped"; then
      return 0
    fi
  fi
  if [[ "$unquoted_no_cr" == *"\\n"* && "$unquoted_no_cr" != *$'\n'* ]]; then
    local unquoted_escaped
    unquoted_escaped="$(printf '%b' "$unquoted_no_cr")"
    if try_write_plain_candidate \
      "$target" \
      "$out_file" \
      "$source_label" \
      "$unquoted_escaped"; then
      return 0
    fi
  fi

  return 1
}

try_value_variants_as_base64() {
  local target="$1"
  local out_file="$2"
  local source_label="$3"
  local value="$4"

  local candidate="$value"
  if try_write_base64_candidate "$target" "$out_file" "$source_label" "$candidate"; then
    return 0
  fi

  candidate="${value//$'\r'/}"
  if [[ "$candidate" != "$value" ]]; then
    if try_write_base64_candidate "$target" "$out_file" "$source_label" "$candidate"; then
      return 0
    fi
  fi

  local unquoted
  unquoted="$(strip_surrounding_quotes "$value")"
  if [[ "$unquoted" != "$value" ]]; then
    if try_write_base64_candidate "$target" "$out_file" "$source_label" "$unquoted"; then
      return 0
    fi
  fi

  local unquoted_no_cr="${unquoted//$'\r'/}"
  if [[ "$unquoted_no_cr" != "$unquoted" ]]; then
    if try_write_base64_candidate \
      "$target" \
      "$out_file" \
      "$source_label" \
      "$unquoted_no_cr"; then
      return 0
    fi
  fi

  if [[ "$value" == *"\\n"* && "$value" != *$'\n'* ]]; then
    local escaped
    escaped="$(printf '%b' "$value")"
    if try_write_base64_candidate "$target" "$out_file" "$source_label" "$escaped"; then
      return 0
    fi
  fi

  if [[ "$unquoted_no_cr" == *"\\n"* && "$unquoted_no_cr" != *$'\n'* ]]; then
    local unquoted_escaped
    unquoted_escaped="$(printf '%b' "$unquoted_no_cr")"
    if try_write_base64_candidate \
      "$target" \
      "$out_file" \
      "$source_label" \
      "$unquoted_escaped"; then
      return 0
    fi
  fi

  return 1
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
    source_label="$b64_var_name"
    if try_value_variants_as_base64 \
      "$target" \
      "$out_file" \
      "$source_label" \
      "$b64_value"; then
      echo "[ok] Wrote $target config: $out_file (source: $source_label)"
      return 0
    fi

    # Tolerate mistakenly pasted raw file content in *_BASE64 variables.
    if try_value_variants_as_plain \
      "$target" \
      "$out_file" \
      "$source_label" \
      "$b64_value"; then
      echo "[ok] Wrote $target config: $out_file (source: $source_label)"
      return 0
    fi

    if [[ -n "$raw_value" ]]; then
      echo "[warn] Falling back to $raw_var_name for '$target'..." >&2
    fi
  fi

  if [[ -n "$raw_value" ]]; then
    source_label="$raw_var_name"

    if try_value_variants_as_plain \
      "$target" \
      "$out_file" \
      "$source_label" \
      "$raw_value"; then
      echo "[ok] Wrote $target config: $out_file (source: $source_label)"
      return 0
    fi

    # Tolerate mistakenly pasted base64 in raw variables.
    if try_value_variants_as_base64 \
      "$target" \
      "$out_file" \
      "$source_label" \
      "$raw_value"; then
      echo "[ok] Wrote $target config: $out_file (source: $source_label)"
      return 0
    fi

    if looks_like_file_path_secret "$raw_value"; then
      echo "[error] '$source_label' appears to contain a path or filename, not file content." >&2
      echo "        Paste full file contents or use the *_BASE64 secret variable." >&2
    fi

    emit_invalid_target_error "$target" "$out_file" "$source_label"
    rm -f "$out_file"
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

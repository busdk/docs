#!/usr/bin/env bash
# Verify Chrome DevTools automatic-workspace well-known file:
# - dev: file is present and valid at the given base URL.
# - prod: file is absent from the built site (never published).
set -e

MODE="${1:?Usage: $0 dev [BASE_URL]|prod BUILD_DIR}"
REL_PATH=".well-known/appspecific/com.chrome.devtools.json"

case "$MODE" in
  dev)
    BASE_URL="${2:-http://localhost:4000}"
    URL="${BASE_URL%/}/${REL_PATH}"
    if ! JSON=$(curl -sSf --max-time 5 "$URL" 2>/dev/null); then
      echo "FAIL: $REL_PATH not reachable at $URL" >&2
      exit 1
    fi
    if ! echo "$JSON" | grep -q '"workspace"'; then
      echo "FAIL: $REL_PATH at $URL does not contain workspace" >&2
      exit 1
    fi
    echo "OK: Chrome DevTools workspace well-known present at $URL"
    ;;
  prod)
    BUILD_DIR="${2:?Usage: $0 prod BUILD_DIR}"
    FILE="${BUILD_DIR%/}/${REL_PATH}"
    if [ -e "$FILE" ]; then
      echo "FAIL: $REL_PATH must not be present in production build: $FILE" >&2
      exit 1
    fi
    echo "OK: Chrome DevTools workspace well-known not in production build"
    ;;
  *)
    echo "Usage: $0 dev [BASE_URL] | prod BUILD_DIR" >&2
    exit 2
    ;;
esac

#!/usr/bin/env bash
set -euo pipefail
payload="$(cat)"
if command -v jq >/dev/null 2>&1; then
  file="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')"
else
  file="$(printf '%s' "$payload" | grep -oE '"file_path"[^"]*"[^"]*"' | head -1 | sed -E 's/.*"file_path"[^"]*"([^"]*)"/\1/')"
fi
[ -z "${file:-}" ] && exit 0
[ -f "$file" ] || exit 0
case "$file" in
  *.yaml|*.yml)
    if grep -nE '^\s*stringData:' "$file" >/dev/null 2>&1; then
      echo "WARNING: stringData found in $file — secrets must be sealed/encrypted." >&2
    fi
    command -v kubeconform >/dev/null 2>&1 && kubeconform -strict -ignore-missing-schemas "$file" || true
    command -v yamllint   >/dev/null 2>&1 && yamllint -d relaxed "$file" || true
    ;;
esac
exit 0

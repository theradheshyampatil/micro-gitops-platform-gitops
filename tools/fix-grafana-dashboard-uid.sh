#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <dashboard-json-file> <uid>"
  exit 1
fi

FILE="$1"
UID="$2"

if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

TMP_FILE="$(mktemp)"

echo "🔧 Setting UID='$UID' in $FILE"

jq --arg uid "$UID" '
  .uid = $uid
  | .id = null
' "$FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$FILE"

echo "✅ Done: $FILE updated safely"

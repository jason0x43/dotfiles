#!/usr/bin/env bash
set -euo pipefail

CAMERA_HOST="${CAMERA_HOST:-}"
CAMERA_USER="${CAMERA_USER:-}"
CAMERA_PASS="${CAMERA_PASS:-}"
CHANNEL="${CHANNEL:-1}"
TYPE="${TYPE:-0}"

usage() {
  cat <<EOF
Usage:
  CAMERA_USER=... CAMERA_PASS=... $0 [output.jpg]

Optional env:
  CAMERA_HOST   Camera IP or hostname
  CHANNEL       Video channel (default: 1)
  TYPE          Snapshot type (default: 0)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

OUTPUT="${1:-snapshot-$(date +%Y%m%d-%H%M%S).jpg}"

is_uint() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

curl_auth() {
  curl --fail --silent --show-error --digest \
    --connect-timeout 5 --max-time 30 \
    --config <(printf 'user = "%s:%s"\n' "$CAMERA_USER" "$CAMERA_PASS") \
    "$@"
}

if ! is_uint "$CHANNEL"; then
  echo "Error: CHANNEL must be an unsigned integer." >&2
  exit 1
fi

if ! is_uint "$TYPE"; then
  echo "Error: TYPE must be an unsigned integer." >&2
  exit 1
fi

if [[ -z "$CAMERA_USER" || -z "$CAMERA_PASS" ]]; then
  echo "Error: set CAMERA_USER and CAMERA_PASS in the environment." >&2
  usage >&2
  exit 1
fi

curl_auth \
  -o "$OUTPUT" \
  "http://$CAMERA_HOST/cgi-bin/snapshot.cgi?channel=$CHANNEL&type=$TYPE"

echo "$OUTPUT"

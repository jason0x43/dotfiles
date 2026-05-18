#!/usr/bin/env bash
set -euo pipefail

CAMERA_HOST="${CAMERA_HOST:-}"
CAMERA_USER="${CAMERA_USER:-}"
CAMERA_PASS="${CAMERA_PASS:-}"

usage() {
  cat <<EOF
Usage:
  CAMERA_USER=... CAMERA_PASS=... $0

Optional env:
  CAMERA_HOST   Camera IP or hostname
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

curl_auth() {
  curl --fail --silent --show-error --digest \
    --connect-timeout 5 --max-time 30 \
    --config <(printf 'user = "%s:%s"\n' "$CAMERA_USER" "$CAMERA_PASS") \
    "$@"
}

if [[ -z "$CAMERA_USER" || -z "$CAMERA_PASS" ]]; then
  echo "Error: set CAMERA_USER and CAMERA_PASS in the environment." >&2
  usage >&2
  exit 1
fi

request() {
  local path="$1"
  echo "==> $path" >&2
  if ! curl_auth "http://$CAMERA_HOST$path"; then
    echo "[request failed] $path" >&2
  fi
  echo
  echo
}

request '/cgi-bin/magicBox.cgi?action=getDeviceType'
request '/cgi-bin/magicBox.cgi?action=getMachineName'
request '/cgi-bin/magicBox.cgi?action=getSerialNo'
request '/cgi-bin/magicBox.cgi?action=getHardwareVersion'
request '/cgi-bin/magicBox.cgi?action=getSystemInfoNew'
request '/cgi-bin/global.cgi?action=getCurrentTime'

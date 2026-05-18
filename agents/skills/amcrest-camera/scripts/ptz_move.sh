#!/usr/bin/env bash
set -euo pipefail

CAMERA_HOST="${CAMERA_HOST:-}"
CAMERA_USER="${CAMERA_USER:-}"
CAMERA_PASS="${CAMERA_PASS:-}"
CHANNEL="${CHANNEL:-1}"
BASE_URL="http://$CAMERA_HOST/cgi-bin/ptz.cgi"

usage() {
  cat <<EOF
Usage:
  CAMERA_USER=... CAMERA_PASS=... $0 status
  CAMERA_USER=... CAMERA_PASS=... $0 start <Up|Down|Left|Right|LeftUp|RightUp|LeftDown|RightDown|ZoomTele|ZoomWide|FocusNear|FocusFar> [arg1] [arg2] [arg3]
  CAMERA_USER=... CAMERA_PASS=... $0 stop <code>
  CAMERA_USER=... CAMERA_PASS=... $0 relative <x> <y> <zoom>
  CAMERA_USER=... CAMERA_PASS=... $0 absolute <x> <y> <zoom>

Optional env:
  CAMERA_HOST   Camera IP or hostname
  CHANNEL       PTZ channel (default: 1)

Notes:
  - PTZ support depends on the camera model.
  - relative/absolute x,y,zoom values are typically normalized to [-1, 1].
EOF
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 1
fi

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ -z "$CAMERA_USER" || -z "$CAMERA_PASS" ]]; then
  echo "Error: set CAMERA_USER and CAMERA_PASS in the environment." >&2
  usage >&2
  exit 1
fi

is_uint() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

is_number() {
  [[ "$1" =~ ^-?[0-9]+([.][0-9]+)?$ ]]
}

is_code() {
  [[ "$1" =~ ^[A-Za-z]+$ ]]
}

curl_auth() {
  curl --fail --silent --show-error --digest \
    --connect-timeout 5 --max-time 30 \
    --config <(printf 'user = "%s:%s"\n' "$CAMERA_USER" "$CAMERA_PASS") \
    "$@"
}

request() {
  local url="$1"
  curl_auth "$url"
  echo
}

if ! is_uint "$CHANNEL"; then
  echo "Error: CHANNEL must be an unsigned integer." >&2
  exit 1
fi

cmd="$1"
shift

case "$cmd" in
  status)
    request "$BASE_URL?action=getStatus&channel=$CHANNEL"
    ;;
  start)
    [[ $# -ge 1 ]] || { usage >&2; exit 1; }
    code="$1"
    arg1="${2:-0}"
    arg2="${3:-1}"
    arg3="${4:-0}"
    is_code "$code" || { echo "Error: invalid PTZ code: $code" >&2; exit 1; }
    is_number "$arg1" || { echo "Error: invalid arg1: $arg1" >&2; exit 1; }
    is_number "$arg2" || { echo "Error: invalid arg2: $arg2" >&2; exit 1; }
    is_number "$arg3" || { echo "Error: invalid arg3: $arg3" >&2; exit 1; }
    request "$BASE_URL?action=start&channel=$CHANNEL&code=$code&arg1=$arg1&arg2=$arg2&arg3=$arg3"
    ;;
  stop)
    [[ $# -ge 1 ]] || { usage >&2; exit 1; }
    code="$1"
    arg1="${2:-0}"
    arg2="${3:-0}"
    arg3="${4:-0}"
    is_code "$code" || { echo "Error: invalid PTZ code: $code" >&2; exit 1; }
    is_number "$arg1" || { echo "Error: invalid arg1: $arg1" >&2; exit 1; }
    is_number "$arg2" || { echo "Error: invalid arg2: $arg2" >&2; exit 1; }
    is_number "$arg3" || { echo "Error: invalid arg3: $arg3" >&2; exit 1; }
    request "$BASE_URL?action=stop&channel=$CHANNEL&code=$code&arg1=$arg1&arg2=$arg2&arg3=$arg3"
    ;;
  relative)
    [[ $# -eq 3 ]] || { usage >&2; exit 1; }
    is_number "$1" || { echo "Error: invalid x: $1" >&2; exit 1; }
    is_number "$2" || { echo "Error: invalid y: $2" >&2; exit 1; }
    is_number "$3" || { echo "Error: invalid zoom: $3" >&2; exit 1; }
    request "$BASE_URL?action=moveRelatively&channel=$CHANNEL&arg1=$1&arg2=$2&arg3=$3"
    ;;
  absolute)
    [[ $# -eq 3 ]] || { usage >&2; exit 1; }
    is_number "$1" || { echo "Error: invalid x: $1" >&2; exit 1; }
    is_number "$2" || { echo "Error: invalid y: $2" >&2; exit 1; }
    is_number "$3" || { echo "Error: invalid zoom: $3" >&2; exit 1; }
    request "$BASE_URL?action=moveAbsolutely&channel=$CHANNEL&arg1=$1&arg2=$2&arg3=$3"
    ;;
  *)
    echo "Error: unknown command: $cmd" >&2
    usage >&2
    exit 1
    ;;
esac

#!/usr/bin/env bash

set -euo pipefail

# TODO - find a way to only upload the changed files
# Upload the contents of the local dist directory to an FTP server.
#
# Defaults:
# - Host: asyncadventures.com (override with FTP_HOST env or --host)
# - User: john@asyncadventures.com (override with FTP_USER env or --user)
# - Remote dir: /public_html (override with FTP_REMOTE_DIR env or --remote-dir)
# - Local dir: dist (override with --local-dir)
#
# The script will prompt for FTP_PASSWORD if not provided via env var.

usage() {
  echo "Usage: $0 [--host HOST] [--user USER] [--remote-dir DIR] [--local-dir DIR]" >&2
  echo "Env overrides: FTP_HOST, FTP_USER, FTP_PASSWORD, FTP_REMOTE_DIR" >&2
}

# Globals with defaults (overridden by args/env)
HOST=${FTP_HOST:-"asyncadventures.com"}
USER=${FTP_USER:-"john@asyncadventures.com"}
REMOTE_DIR=${FTP_REMOTE_DIR:-"/public_html"}
LOCAL_DIR="dist"
PASSWORD=${FTP_PASSWORD:-}
# Resolve repository root as parent of this script's directory and absolute local path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCAL_PATH="$REPO_ROOT/$LOCAL_DIR"
PROGRESS=1
INSECURE=0
PLAIN=0
CREATE_REMOTE_DIR=0

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --host)
        HOST="$2"; shift 2 ;;
      --user)
        USER="$2"; shift 2 ;;
      --remote-dir)
        REMOTE_DIR="$2"; shift 2 ;;
      --local-dir)
        LOCAL_DIR="$2"; shift 2 ;;
      --no-progress)
        PROGRESS=0; shift 1 ;;
      --insecure)
        INSECURE=1; shift 1 ;;
      --plain)
        PLAIN=1; shift 1 ;;
      --create-remote-dir)
        CREATE_REMOTE_DIR=1; shift 1 ;;
      -h|--help)
        usage; exit 0 ;;
      *)
        echo "Unknown argument: $1" >&2
        usage; exit 1 ;;
    esac
  done
}

prompt_password() {
  if [[ -z "${PASSWORD}" ]]; then
    read -r -s -p "Enter FTP password for ${USER}@${HOST}: " PASSWORD
    echo ""
  fi
}

run_build() {
  echo "Running site build (npm run build) in $REPO_ROOT ..."
  (cd "$REPO_ROOT" && npm run build)
}

ensure_local_dir() {
  if [[ ! -d "$LOCAL_PATH" ]]; then
    echo "Local directory '$LOCAL_PATH' does not exist. Did the build complete?" >&2
    exit 1
  fi
}

print_summary() {
  local num_files total_bytes human_size
  num_files=$(find "$LOCAL_PATH" -type f | wc -l | tr -d ' ')
  # Use POSIX-compatible size calc; macOS du -sk gives KiB
  total_bytes=$(( $(du -sk "$LOCAL_PATH" | awk '{print $1}') * 1024 ))
  # Human readable approximation
  if [[ $total_bytes -ge 1073741824 ]]; then
    human_size=$(printf "%.2f GiB" "$(echo "$total_bytes / 1073741824" | bc -l)")
  elif [[ $total_bytes -ge 1048576 ]]; then
    human_size=$(printf "%.2f MiB" "$(echo "$total_bytes / 1048576" | bc -l)")
  else
    human_size=$(printf "%.2f KiB" "$(echo "$total_bytes / 1024" | bc -l)")
  fi
  echo "Preparing to upload $num_files files (~$human_size) from '$LOCAL_PATH' to '${HOST}${REMOTE_DIR}'."
}

upload_with_lftp() {
  echo "Using lftp for fast recursive upload..."
  # shellcheck disable=SC2016
  lftp -u "$USER","$PASSWORD" "$HOST" <<LFTP_CMDS
    set ftp:passive-mode true
    set net:max-retries 2
    set net:timeout 20
    set net:persist-retries 1
$( [[ "$PLAIN" -eq 1 ]] && echo "set ftp:ssl-allow false" )
$( [[ "$INSECURE" -eq 1 ]] && echo "set ssl:verify-certificate no" )
 $( [[ "$CREATE_REMOTE_DIR" -eq 1 ]] && echo "mkdir -p \"$REMOTE_DIR\"" )
    cd "$REMOTE_DIR"
mirror -R --only-newer --ignore-time --parallel=4 --verbose=1 --exclude-glob ".DS_Store" "$LOCAL_PATH" .
    bye
LFTP_CMDS
}

upload_with_curl() {
  echo "lftp not found; falling back to curl-based upload. This may be slower."
  case "$REMOTE_DIR" in
    /*) : ;;
    *) REMOTE_DIR="/$REMOTE_DIR" ;;
  esac
  IFS=$'\n'
  export LC_ALL=C
  local curl_progress
  if [[ $PROGRESS -eq 1 ]]; then
    # Show progress bar only when stdout is a TTY
    if [ -t 1 ]; then
      curl_progress=(--progress-bar)
    else
      curl_progress=(--silent)
    fi
  else
    curl_progress=(--silent)
  fi
  while IFS= read -r -d '' file; do
    local rel_path
    rel_path="${file#${LOCAL_PATH}/}"
    local remote_url
    remote_url="ftp://$HOST${REMOTE_DIR%/}/$rel_path"
    echo "Uploading: $rel_path"
    if [[ $CREATE_REMOTE_DIR -eq 1 ]]; then
      curl "${curl_progress[@]}" --show-error --ftp-create-dirs --fail -T "$file" "$remote_url" --user "$USER:$PASSWORD"
    else
      curl "${curl_progress[@]}" --show-error --fail -T "$file" "$remote_url" --user "$USER:$PASSWORD"
    fi
  done < <(find "$LOCAL_PATH" -type f -print0)
}

perform_upload() {
  echo "Uploading '${LOCAL_PATH}' to ftp://${HOST}${REMOTE_DIR} as ${USER}"
  print_summary
  if command -v lftp >/dev/null 2>&1; then
    upload_with_lftp
  else
    upload_with_curl
  fi
  echo "Upload complete."
}

main() {
  parse_args "$@"
  prompt_password
  run_build
  ensure_local_dir
  perform_upload
}

main "$@"

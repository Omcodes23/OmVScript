#!/usr/bin/env bash
set -euo pipefail
# OmScript: bootstrap installer
# Usage:
#  curl -fsSL https://raw.githubusercontent.com/Omcodes23/OmScript/main/install.sh -o /tmp/omscript-install.sh
#  sudo bash /tmp/omscript-install.sh

REPO_RAW_BASE="https://raw.githubusercontent.com/Omcodes23/OmScript/main"
LOGFILE="/var/log/omscript.log"
TMPDIR="$(mktemp -d /tmp/omscript.XXXX)"

log() { echo "$(date --iso-8601=seconds) $*" | tee -a "$LOGFILE"; }
ensure_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root (sudo)." >&2
    exit 1
  fi
}

detect_pkg_manager() {
  if command -v apt-get >/dev/null 2>&1; then echo "apt"; return; fi
  if command -v dnf >/dev/null 2>&1; then echo "dnf"; return; fi
  if command -v pacman >/dev/null 2>&1; then echo "pacman"; return; fi
  echo "unknown"
}

fetch_module() {
  local path="$1"
  local url="${REPO_RAW_BASE}/${path}"
  local out="${TMPDIR}/$(basename "$path")"
  log "Downloading module: $url"
  if ! curl -fsSL "$url" -o "$out"; then
    log "ERROR: failed download $url"
    return 1
  fi
  chmod +x "$out"
  echo "$out"
}

run_module() {
  local module_path="$1"
  log "----- MODULE: $(basename "$module_path") -----"
  head -n 50 "$module_path" >> "$LOGFILE" || true
  ( bash "$module_path" ) 2>&1 | tee -a "$LOGFILE"
  return ${PIPESTATUS[0]:-0}
}

choose_with_whiptail() {
  if command -v whiptail >/dev/null 2>&1; then
    whiptail "$@"
    return $?
  fi
  return 1
}

ensure_root

# Interactive menu
if command -v whiptail >/dev/null 2>&1; then
  choice=$(whiptail --title "OmScript" --menu "Choose action" 20 80 10 \
    "1" "Ensure Docker is installed (recommended)" \
    "2" "Install Developer Environment (VS Code, Python, nvm, JDK)" \
    "3" "Install Server Role (CasaOS, Cosmos - choose next)" \
    "4" "Install NAS (OpenMediaVault)" \
    "5" "Exit" 3>&1 1>&2 2>&3) || exit 0
else
  echo "OmScript - choose one:"
  echo "1) Ensure Docker"
  echo "2) Developer Environment"
  echo "3) Server Role"
  echo "4) NAS"
  echo "5) Exit"
  read -rp "Enter choice: " choice
fi

case "$choice" in
  1)
    m=$(fetch_module "modules/docker-check.sh") || exit 1
    run_module "$m"
    ;;
  2)
    m=$(fetch_module "modules/developer/install-dev-env.sh") || exit 1
    run_module "$m"
    ;;
  3)
    if command -v whiptail >/dev/null 2>&1; then
      srv=$(whiptail --title "Server options" --menu "Choose server to install/convert to" 18 80 8 \
        "casaos" "CasaOS (home server GUI over Docker)" \
        "cosmos" "Cosmos (custom server flow)" \
        "cancel" "Cancel" 3>&1 1>&2 2>&3) || exit 0
    else
      echo "Options: casaos cosmos"
      read -rp "Which: " srv
    fi

    case "$srv" in
      casaos)
        m=$(fetch_module "modules/server/casaos.sh") || exit 1
        run_module "$m"
        ;;
      cosmos)
        m=$(fetch_module "modules/server/cosmos.sh") || exit 1
        run_module "$m"
        ;;
      *)
        log "Server choice cancelled"
        ;;
    esac
    ;;
  4)
    m=$(fetch_module "modules/nas/openmediavault.sh") || exit 1
    run_module "$m"
    ;;
  5)
    log "Exit chosen"
    ;;
  *)
    log "Unknown choice"
    ;;
esac

rm -rf "$TMPDIR"
log "OmScript finished."
exit 0

#!/usr/bin/env bash
set -euo pipefail
log(){ echo "$(date --iso-8601=seconds) $*"; }

if command -v docker >/dev/null 2>&1; then
  log "Docker already installed: $(docker --version)"
  exit 0
fi

PKG=""
if command -v apt-get >/dev/null 2>&1; then PKG="apt"; fi
if command -v dnf >/dev/null 2>&1; then PKG="dnf"; fi
if command -v pacman >/dev/null 2>&1; then PKG="pacman"; fi

log "Installing Docker (pkg manager: ${PKG:-unknown})"

case "$PKG" in
  apt)
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg" \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
    systemctl enable --now docker
    ;;
  dnf)
    dnf -y install dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    dnf -y install docker-ce docker-ce-cli containerd.io
    systemctl enable --now docker
    ;;
  pacman)
    pacman -Sy --noconfirm docker
    systemctl enable --now docker
    ;;
  *)
    log "Unsupported package manager. Please install Docker manually."
    exit 2
    ;;
esac

if [ -n "${SUDO_USER:-}" ]; then
  usermod -aG docker "$SUDO_USER" || true
  log "Added user $SUDO_USER to docker group (re-login required)."
fi

log "Docker installation complete."
exit 0

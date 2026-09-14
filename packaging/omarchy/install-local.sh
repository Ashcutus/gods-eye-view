#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
INSTALL_ROOT="${GEV_INSTALL_ROOT:-$DATA_HOME/gods-eye-view}"
BIN_DIR="${HOME}/.local/bin"
APPLICATION_DIR="${DATA_HOME}/applications"
ICON_DIR="${DATA_HOME}/icons/hicolor/scalable/apps"

validate_install_root() {
  local canonical
  if [[ "$DATA_HOME" != /* || "$INSTALL_ROOT" != /* ]]; then
    echo "XDG_DATA_HOME and GEV_INSTALL_ROOT must be absolute paths." >&2
    exit 1
  fi
  canonical="$(readlink -m "$INSTALL_ROOT")"
  if [[ "$canonical" == "/" || "$canonical" == "$HOME" || "$canonical" == "$DATA_HOME" ]]; then
    echo "Refusing unsafe install destination: $INSTALL_ROOT" >&2
    exit 1
  fi
  if [[ "$(basename "$canonical")" != "gods-eye-view" ]]; then
    echo "Install destination must end in /gods-eye-view: $INSTALL_ROOT" >&2
    exit 1
  fi
}

if ! command -v rsync >/dev/null 2>&1; then
  echo "rsync is required to install the local app copy." >&2
  exit 1
fi
if ! command -v npm >/dev/null 2>&1; then
  echo "npm is not on PATH. On Omarchy, install it with: omarchy install dev-env node" >&2
  exit 1
fi

validate_install_root
mkdir -p -- "$INSTALL_ROOT" "$BIN_DIR" "$APPLICATION_DIR" "$ICON_DIR"

if [[ "$(readlink -m "$REPO_ROOT")" != "$(readlink -m "$INSTALL_ROOT")" ]]; then
  rsync -a \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='dist' \
    --exclude='.env' \
    --exclude='.env.*' \
    "$REPO_ROOT/" "$INSTALL_ROOT/"
fi

(
  cd "$INSTALL_ROOT"
  PUPPETEER_SKIP_DOWNLOAD=1 npm ci
  npm run doctor
)

install -Dm755 \
  "$INSTALL_ROOT/packaging/omarchy/gods-eye-view-launch" \
  "$BIN_DIR/gods-eye-view-launch"
install -Dm644 \
  "$INSTALL_ROOT/packaging/omarchy/com.bilawal.GodsEyeView.desktop" \
  "$APPLICATION_DIR/com.bilawal.GodsEyeView.desktop"
install -Dm644 \
  "$INSTALL_ROOT/public/logo.svg" \
  "$ICON_DIR/com.bilawal.GodsEyeView.svg"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APPLICATION_DIR" >/dev/null 2>&1 || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache "$DATA_HOME/icons/hicolor" >/dev/null 2>&1 || true
fi

echo "Installed God's Eye View for Omarchy."
echo "Launch it from Walker or with: gods-eye-view-launch"
echo "Installed app copy: $INSTALL_ROOT"

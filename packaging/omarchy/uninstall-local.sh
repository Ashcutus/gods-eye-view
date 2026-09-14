#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
INSTALL_ROOT="${GEV_INSTALL_ROOT:-$DATA_HOME/gods-eye-view}"

validate_install_root() {
  local canonical
  if [[ "$DATA_HOME" != /* || "$INSTALL_ROOT" != /* ]]; then
    echo "XDG_DATA_HOME and GEV_INSTALL_ROOT must be absolute paths." >&2
    exit 1
  fi
  canonical="$(readlink -m "$INSTALL_ROOT")"
  if [[ "$canonical" == "/" || "$canonical" == "$HOME" || "$canonical" == "$DATA_HOME" ]]; then
    echo "Refusing unsafe uninstall destination: $INSTALL_ROOT" >&2
    exit 1
  fi
  if [[ "$(basename "$canonical")" != "gods-eye-view" ]]; then
    echo "Uninstall destination must end in /gods-eye-view: $INSTALL_ROOT" >&2
    exit 1
  fi
}

validate_install_root
if [[ "$(readlink -m "$REPO_ROOT")" == "$(readlink -m "$INSTALL_ROOT")" ]]; then
  echo "Refusing to remove the checkout itself: $REPO_ROOT" >&2
  exit 1
fi

GEV_APP_ROOT="$INSTALL_ROOT" \
  "$REPO_ROOT/packaging/omarchy/gods-eye-view-launch" --stop 2>/dev/null || true
rm -f -- \
  "$HOME/.local/bin/gods-eye-view-launch" \
  "$DATA_HOME/applications/com.bilawal.GodsEyeView.desktop" \
  "$DATA_HOME/icons/hicolor/scalable/apps/com.bilawal.GodsEyeView.svg"
rm -rf -- "$INSTALL_ROOT"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DATA_HOME/applications" >/dev/null 2>&1 || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache "$DATA_HOME/icons/hicolor" >/dev/null 2>&1 || true
fi

echo "Removed God's Eye View's Omarchy launcher and local app copy."

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)"

bash -n \
  "$SCRIPT_DIR/gods-eye-view-launch" \
  "$SCRIPT_DIR/install-local.sh" \
  "$SCRIPT_DIR/uninstall-local.sh"

if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$SCRIPT_DIR/com.bilawal.GodsEyeView.desktop"
fi

test -s "$REPO_ROOT/public/logo.svg"
grep --fixed-strings --quiet 'HOST=127.0.0.1' "$SCRIPT_DIR/gods-eye-view-launch"
grep --fixed-strings --quiet 'omarchy-launch-or-focus-webapp' "$SCRIPT_DIR/gods-eye-view-launch"
grep --fixed-strings --quiet -- "--exclude='.env'" "$SCRIPT_DIR/install-local.sh"
grep --fixed-strings --quiet -- "--exclude='.env.*'" "$SCRIPT_DIR/install-local.sh"
grep --fixed-strings --quiet 'GEV_APP_ROOT="$INSTALL_ROOT"' "$SCRIPT_DIR/uninstall-local.sh"
grep --fixed-strings --quiet 'Exec=gods-eye-view-launch' \
  "$SCRIPT_DIR/com.bilawal.GodsEyeView.desktop"

echo "Omarchy packaging checks passed."

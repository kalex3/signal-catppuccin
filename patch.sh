#!/bin/sh
set -eu
command -v asar >/dev/null 2>&1 || { echo "Error: 'asar' not installed or not in \$PATH" >&2; exit 1; }
command -v sudo >/dev/null 2>&1 || { echo "Error: 'sudo' not installed" >&2; exit 1; }
FLAVOR="${1:-mocha}"
THEME="$(dirname "$0")/themes/catppuccin-$FLAVOR.css"
ASAR="${2:-/usr/lib/signal-desktop/resources/app.asar}"
TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT HUP INT TERM
[ -f "$ASAR" ] || { echo "Error: '$ASAR' not found" >&2; exit 1; }
[ -f "$THEME" ] || { echo "Error: '$THEME' not found" >&2; exit 1; }
asar e "$ASAR" "$TEMP"
cp "$THEME" "$TEMP/stylesheets/catppuccin-$FLAVOR.css"
sed -i "1i @import \"catppuccin-$FLAVOR.css\";" "$TEMP/stylesheets/manifest.css"
sudo asar p "$TEMP" "$ASAR"
echo "Successfully patched '$ASAR' with flavor '$FLAVOR'"

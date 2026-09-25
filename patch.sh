#!/bin/sh

set -eu
FLAVOR="${1:-mocha}" ASAR="${2:-/usr/lib/signal-desktop/resources/app.asar}" TEMP="$(mktemp -d)"
asar e "$ASAR" "$TEMP"
cp "$(dirname $0)/themes/catppuccin-$FLAVOR.css" "$TEMP/stylesheets/catppuccin-$FLAVOR.css"
sed -i "1i @import \"catppuccin-$FLAVOR.css\";" "$TEMP/stylesheets/manifest.css"
sudo asar p "$TEMP" "$ASAR"
echo "Successfully patched '$ASAR' with flavor '$FLAVOR'"
rm -rf "$TEMP"

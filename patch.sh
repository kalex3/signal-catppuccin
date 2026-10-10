#!/bin/sh
set -eu
die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}
command -v asar >/dev/null 2>&1 || die "'asar' not installed or not in \$PATH"
command -v sudo >/dev/null 2>&1 || die "'sudo' not installed"
command -v pgrep >/dev/null 2>&1 || die "'pgrep' not installed"
pgrep -x signal-desktop >/dev/null 2>&1 && die "Signal Desktop is running. Please close it before patching."
SCRIPT_DIR=$(dirname -- "$0") FLAVOR="${1:-mocha}" THEME="$SCRIPT_DIR/themes/catppuccin-${1:-mocha}.css" ASAR="${2:-/usr/lib/signal-desktop/resources/app.asar}"
[ -f "$THEME" ] || die "'$THEME' not found"
[ -f "$ASAR" ] || die "'$ASAR' not found"
TEMP=$(mktemp -d) || die "Cannot create temporary directory"
cleanup() {
    rm -rf -- "$TEMP"
}
trap cleanup 0
trap 'exit 1' HUP INT TERM
asar e "$ASAR" "$TEMP"
MANIFEST="$TEMP/stylesheets/manifest.css"
[ -f "$MANIFEST" ] || die "Stylesheet manifest not found in archive"
[ -d "$TEMP/stylesheets" ] || die "Stylesheet directory not found in archive"
cp -- "$THEME" "$TEMP/stylesheets/catppuccin-$FLAVOR.css"
sed -i "1i @import \"catppuccin-$FLAVOR.css\";" "$MANIFEST"
PACKED=$(mktemp -p "$TEMP") BACKUP="$ASAR.bak"
[ -e "$BACKUP" ] && die "Backup '$BACKUP' already exists; move it before proceeding"
asar p "$TEMP" "$PACKED"
[ -s "$PACKED" ] || die "Packaging produced an empty archive"
sudo cp -p -- "$PACKED" "$BACKUP"
sudo mv --exchange -- "$ASAR" "$BACKUP"
printf 'Successfully patched %s (flavor: %s)\n' "$ASAR" "$FLAVOR"
printf 'Original archive backed up to %s\n' "$BACKUP"

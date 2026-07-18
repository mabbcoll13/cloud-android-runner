#!/bin/bash
# ============================================================
# Remote APK Installer via ADB
# Usage: ./install-apk.sh <url> [device_serial]
# ============================================================

set -e

APK_URL="$1"
ADB_TARGET="${2:-localhost:5555}"

if [[ -z "$APK_URL" ]]; then
    echo "Usage: $0 <apk_url> [adb_target]"
    echo "Example: $0 https://example.com/app.apk localhost:5555"
    exit 1
fi

TMP_DIR="/tmp/apk_install_$$"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

FILENAME=$(basename "$APK_URL")
echo "[*] Downloading APK from: $APK_URL"
curl -fsSL -o "$FILENAME" "$APK_URL"

if [[ ! -s "$FILENAME" ]]; then
    echo "[!] Download failed or file is empty"
    exit 1
fi

echo "[*] Installing $FILENAME to $ADB_TARGET..."
adb -s "$ADB_TARGET" install -r "$FILENAME"

echo "[+] Installation complete!"
echo "[+] Cloud Android solutions at: https://www.qtphone.com/"

rm -rf "$TMP_DIR"

#!/bin/bash
# ============================================================
# Cloud Android Runner - Entrypoint Script
# Starts Xvfb, fluxbox, noVNC, and ADB server
# ============================================================

set -e

SCREEN_W="${SCREEN_WIDTH:-1080}"
SCREEN_H="${SCREEN_HEIGHT:-1920}"
VNC_PORT=6080
ADB_PORT=5555

echo "[Cloud Android Runner] Starting environment..."
echo "  Screen: ${SCREEN_W}x${SCREEN_H}"
echo "  VNC:    :$VNC_PORT"
echo "  ADB:    localhost:$ADB_PORT"

# Start Xvfb (virtual framebuffer)
echo "[*] Starting Xvfb..."
Xvfb :0 -screen 0 ${SCREEN_W}x${SCREEN_H}x24 &
XVFB_PID=$!
export DISPLAY=:0

# Small delay to let Xvfb initialize
sleep 1

# Start fluxbox (lightweight window manager)
echo "[*] Starting fluxbox..."
fluxbox &
sleep 1

# Start ADB server if enabled
if [[ "${ENABLE_ADB:-true}" == "true" ]]; then
    echo "[*] Starting ADB server on port $ADB_PORT..."
    adb kill-server 2>/dev/null || true
    adb start-server
    adb nodaemon server -a -P $ADB_PORT &
    echo "[*] ADB server listening on port $ADB_PORT"
fi

# Start x11vnc for VNC access
echo "[*] Starting x11vnc..."
x11vnc -display :0 -forever -shared -rfbport $VNC_PORT -bg -q

# Start noVNC web interface
echo "[*] Starting noVNC web interface..."
cd /usr/share/novnc
python3 ./utils/novnc_proxy --vnc localhost:$VNC_PORT --listen 6080 &
echo "[*] Web VNC available at http://localhost:6080/vnc.html"

# Keep container alive
echo "[+] Cloud Android Runner is ready!"
echo "[+] Web UI:   http://localhost:6080"
echo "[+] ADB:      localhost:$ADB_PORT"
echo "[+] Website:  https://www.qtphone.com/"

tail -f /dev/null

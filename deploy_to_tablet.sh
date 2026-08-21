#!/usr/bin/env bash
set -e

TARGET="${1:-user@192.168.1.14}"
if [[ "$TARGET" != *"@"* ]]; then
    TABLET_HOST="user@${TARGET}"
else
    TABLET_HOST="${TARGET}"
fi

REMOTE_DIR="~/plasma-keyboard"
SSH_OPTS="-F /dev/null -o StrictHostKeyChecking=no"

echo "🚀 [1/4] Syncing sources to tablet at ${TABLET_HOST}..."
rsync -avz -e "ssh ${SSH_OPTS}" --exclude="build" --exclude=".git" ./ "${TABLET_HOST}:${REMOTE_DIR}/"

echo "⚙️ [2/4] Registering KDE Plasma 6 Virtual Keyboard service and tastiera CLI alias..."
ssh ${SSH_OPTS} "${TABLET_HOST}" "mkdir -p ~/.local/share/applications ~/.local/bin && cp ${REMOTE_DIR}/org.kde.plasma-keyboard.desktop ~/.local/share/applications/ && ln -sf ${REMOTE_DIR}/build/plasma-keyboard ~/.local/bin/tastiera && ln -sf ${REMOTE_DIR}/build/plasma-keyboard ~/.local/bin/plasma-keyboard && kbuildsycoca6 2>/dev/null || true"

echo "🛠️ [3/4] Compiling plasma-keyboard on tablet..."
ssh ${SSH_OPTS} "${TABLET_HOST}" "cd ${REMOTE_DIR} && find . -type f -exec touch {} + && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j\$(nproc)"

echo "🛑 [4/4] Terminating previous instance(s) and launching detached..."
ssh ${SSH_OPTS} "${TABLET_HOST}" "pkill -f plasma-keyboard || true; sleep 0.5"
ssh ${SSH_OPTS} "${TABLET_HOST}" "rm -f /tmp/plasma-keyboard-single-instance 2>/dev/null; rm -f \$(echo /run/user/\$(id -u)/plasma-keyboard-single-instance) 2>/dev/null || true"
ssh ${SSH_OPTS} "${TABLET_HOST}" "export XDG_RUNTIME_DIR=/run/user/\$(id -u); export WAYLAND_DISPLAY=wayland-0; export QT_QPA_PLATFORM=wayland; export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/\$(id -u)/bus; systemd-run --user ${REMOTE_DIR}/build/plasma-keyboard 2>/dev/null || (nohup ${REMOTE_DIR}/build/plasma-keyboard </dev/null >/tmp/plasma-keyboard.log 2>&1 &)"

echo "✅ Deploy complete! Keyboard is now running and registered in KDE Plasma System Settings."

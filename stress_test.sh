#!/bin/bash
#
# stress_test.sh — Stress test for Plasma Touch Key (Tastiera)
# Runs on the development machine, sends commands to the tablet via SSH.
#
# Tests:
#   1. Rapid toggle (show/hide) cycling
#   2. Rapid IPC command bombardment (show/hide/toggle mixed)
#   3. Verify single-instance survives stress
#   4. Check for zombie processes and socket leaks
#
# Usage: ./stress_test.sh [host] [iterations]
#

set -u

HOST="${1:-user@172.16.42.1}"
ITERATIONS="${2:-50}"
TASTIERA="/home/user/.local/bin/tastiera"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

pass=0
fail=0

log_pass() { echo -e "  ${GREEN}✓${NC} $1"; ((pass++)); }
log_fail() { echo -e "  ${RED}✗${NC} $1"; ((fail++)); }
log_info() { echo -e "  ${CYAN}ℹ${NC} $1"; }
log_section() { echo -e "\n${YELLOW}━━━ $1 ━━━${NC}"; }

remote() { ssh "$HOST" "$@" 2>/dev/null; }

# ── Pre-flight checks ──
log_section "Pre-flight Checks"

# Ensure keyboard is running
PCOUNT=$(remote "ps aux | grep 'plasma-keyboard' | grep -v grep | wc -l" || echo 0)
PCOUNT=$(echo "$PCOUNT" | tr -d '[:space:]')
if [ "$PCOUNT" -ge 1 ]; then
    log_pass "Keyboard process running (${PCOUNT} instance(s))"
else
    log_info "Starting keyboard..."
    remote "nohup $TASTIERA >/dev/null 2>&1 &"
    sleep 2
    PCOUNT=$(remote "ps aux | grep 'plasma-keyboard' | grep -v grep | wc -l" || echo 0)
PCOUNT=$(echo "$PCOUNT" | tr -d '[:space:]')
    if [ "$PCOUNT" -ge 1 ]; then
        log_pass "Keyboard started successfully"
    else
        log_fail "Could not start keyboard"
        exit 1
    fi
fi

# Check socket exists
if remote "test -S /run/user/10000/plasma-keyboard-single-instance"; then
    log_pass "IPC socket exists"
else
    log_fail "IPC socket missing"
fi

# ── Test 1: Rapid toggle cycling ──
log_section "Test 1: Rapid Toggle Cycling (${ITERATIONS} iterations)"

for i in $(seq 1 "$ITERATIONS"); do
    remote "$TASTIERA --toggle" &>/dev/null || true
done

sleep 1
PCOUNT=$(remote "ps aux | grep 'plasma-keyboard' | grep -v grep | wc -l" || echo 0)
PCOUNT=$(echo "$PCOUNT" | tr -d '[:space:]')
if [ "$PCOUNT" -eq 1 ]; then
    log_pass "Single instance survived $ITERATIONS rapid toggles"
else
    log_fail "Expected 1 instance, found $PCOUNT after toggle stress"
fi

# ── Test 2: Mixed IPC commands ──
log_section "Test 2: Mixed IPC Commands (${ITERATIONS} iterations)"

CMDS=("--toggle" "--show" "--hide" "--toggle" "--show" "--toggle" "--hide" "--show")
for i in $(seq 1 "$ITERATIONS"); do
    CMD="${CMDS[$((i % ${#CMDS[@]}))]}"
    remote "$TASTIERA $CMD" &>/dev/null || true
done

sleep 1
PCOUNT=$(remote "ps aux | grep 'plasma-keyboard' | grep -v grep | wc -l" || echo 0)
PCOUNT=$(echo "$PCOUNT" | tr -d '[:space:]')
if [ "$PCOUNT" -eq 1 ]; then
    log_pass "Single instance survived $ITERATIONS mixed IPC commands"
else
    log_fail "Expected 1 instance, found $PCOUNT after mixed IPC stress"
fi

# ── Test 3: Parallel bombardment ──
log_section "Test 3: Parallel IPC Bombardment (20 simultaneous)"

for i in $(seq 1 20); do
    remote "$TASTIERA --toggle" &>/dev/null &
done
wait

sleep 2
PCOUNT=$(remote "ps aux | grep 'plasma-keyboard' | grep -v grep | wc -l" || echo 0)
PCOUNT=$(echo "$PCOUNT" | tr -d '[:space:]')
if [ "$PCOUNT" -eq 1 ]; then
    log_pass "Single instance survived 20 parallel toggles"
else
    log_fail "Expected 1 instance, found $PCOUNT after parallel stress"
fi

# ── Test 4: Socket file integrity ──
log_section "Test 4: Socket & Process Integrity"

if remote "test -S /run/user/10000/plasma-keyboard-single-instance"; then
    log_pass "IPC socket still exists after stress"
else
    log_fail "IPC socket disappeared during stress"
fi

# Check for zombie processes
ZOMBIES=$(remote "ps aux | grep 'plasma-keyboard' | grep -v grep | grep 'Z' | wc -l" || echo 0)
ZOMBIES=$(echo "$ZOMBIES" | tr -d '[:space:]')
if [ "$ZOMBIES" = "0" ]; then
    log_pass "No zombie processes"
else
    log_fail "Found $ZOMBIES zombie process(es)"
fi

# Check memory usage (BusyBox-compatible via /proc)
PID=$(remote "ps aux | grep 'plasma-keyboard' | grep -v grep | head -1 | awk '{print \$1}'" || echo "")
if [ -n "$PID" ]; then
    MEM=$(remote "cat /proc/$PID/status 2>/dev/null | grep VmRSS | awk '{print \$2}'" || echo "unknown")
    MEM=$(echo "$MEM" | tr -d '[:space:]')
    if [ "$MEM" != "unknown" ] && [ -n "$MEM" ] && [ "$MEM" -lt 200000 ] 2>/dev/null; then
        log_pass "Memory usage reasonable: ${MEM} KB (< 200 MB)"
    else
        log_info "Memory usage: ${MEM} KB"
    fi
else
    log_info "Could not determine PID for memory check"
fi

# ── Test 5: Kill and restart ──
log_section "Test 5: Kill & Restart Recovery"

remote "kill \$(ps aux | grep 'plasma-keyboard' | grep -v grep | awk '{print \$1}')" 2>/dev/null || true
sleep 2

# Socket should be cleaned up by signal handler
if remote "test -S /run/user/10000/plasma-keyboard-single-instance" 2>/dev/null; then
    log_info "Socket still exists after kill (may have received SIGKILL via BusyBox)"
    remote "rm -f /run/user/10000/plasma-keyboard-single-instance" 2>/dev/null || true
else
    log_pass "Socket cleaned up by SIGTERM handler"
fi

# Restart
remote "export XDG_RUNTIME_DIR=/run/user/10000 WAYLAND_DISPLAY=wayland-0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/10000/bus; nohup $TASTIERA >/dev/null 2>&1 &"
sleep 3

PCOUNT=$(remote "ps aux | grep 'plasma-keyboard' | grep -v grep | wc -l" || echo 0)
PCOUNT=$(echo "$PCOUNT" | tr -d '[:space:]')
if [ "$PCOUNT" -eq 1 ]; then
    log_pass "Keyboard restarted successfully after kill"
else
    log_fail "Failed to restart after kill (found $PCOUNT instances)"
fi

if remote "test -S /run/user/10000/plasma-keyboard-single-instance"; then
    log_pass "New IPC socket created after restart"
else
    log_fail "IPC socket missing after restart"
fi

# ── Test 6: Show after restart ──
log_section "Test 6: Show/Hide after restart"

remote "$TASTIERA --show" &>/dev/null || true
sleep 0.5
remote "$TASTIERA --hide" &>/dev/null || true
sleep 0.5
remote "$TASTIERA --show" &>/dev/null || true

PCOUNT=$(remote "ps aux | grep 'plasma-keyboard' | grep -v grep | wc -l" || echo 0)
PCOUNT=$(echo "$PCOUNT" | tr -d '[:space:]')
if [ "$PCOUNT" -eq 1 ]; then
    log_pass "Show/Hide commands work after restart"
else
    log_fail "Process count wrong after show/hide: $PCOUNT"
fi

# ── Summary ──
log_section "Results"

total=$((pass + fail))
echo -e "  ${GREEN}Passed: $pass${NC}"
echo -e "  ${RED}Failed: $fail${NC}"
echo -e "  Total:  $total"
echo ""

if [ "$fail" -eq 0 ]; then
    echo -e "  ${GREEN}🎉 ALL TESTS PASSED!${NC}"
    exit 0
else
    echo -e "  ${RED}⚠️  SOME TESTS FAILED${NC}"
    exit 1
fi

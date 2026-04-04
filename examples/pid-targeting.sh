#!/bin/bash
# PID targeting example with systemd masquerade
# Targets a specific PID in the low system service range

CONDUIT="${CONDUIT:-./socat-repo/conduit}"
TARGET_PID="${TARGET_PID:-500}"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: PID targeting requires root privileges"
    echo "Usage: sudo TARGET_PID=500 $0"
    exit 1
fi

echo "PID Targeting Example"
echo "Target PID: $TARGET_PID"
echo "Masquerading as: systemd-logind"
echo "Starting port forward: localhost:8080 -> target.internal:80"
echo ""
echo "Note: The process will fork, and the child will attempt to get PID $TARGET_PID"
echo "      Parent will restore ns_last_pid and exit"
echo ""

"$CONDUIT" -Ms -Mp "$TARGET_PID" \
    TCP-LISTEN:8080,fork,reuseaddr \
    TCP:target.internal:80

# Usage:
# 1. Must run as root or with CAP_SYS_ADMIN
# 2. Set TARGET_PID to desired PID (optional, default 500)
# 3. Run: sudo TARGET_PID=350 ./pid-targeting.sh
# 4. Child process will attempt to get the target PID
#
# Useful for:
# - Blending into low PID ranges (system services typically 100-1000)
# - Mimicking service restart behavior (known PID patterns)
# - Avoiding suspiciously high PIDs

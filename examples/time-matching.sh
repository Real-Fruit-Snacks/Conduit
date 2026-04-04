#!/bin/bash
# Time namespace matching example
# Match a target process's start time for perfect impersonation

CONDUIT="${CONDUIT:-./socat-repo/conduit}"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Time namespace manipulation requires root privileges"
    echo "Usage: sudo $0"
    exit 1
fi

# Find a long-running system service to mimic
TARGET_PID=$(pgrep -f systemd-logind | head -1)

if [ -z "$TARGET_PID" ]; then
    echo "ERROR: Could not find systemd-logind process"
    echo "Trying alternative: systemd-resolved"
    TARGET_PID=$(pgrep -f systemd-resolved | head -1)
fi

if [ -z "$TARGET_PID" ]; then
    echo "ERROR: Could not find a suitable system process to mimic"
    exit 1
fi

# Get target process info
TARGET_NAME=$(ps -p "$TARGET_PID" -o comm= | head -1)
TARGET_START=$(ps -p "$TARGET_PID" -o lstart= | head -1)

echo "Time Namespace Matching"
echo "======================="
echo "Target PID:    $TARGET_PID"
echo "Target name:   $TARGET_NAME"
echo "Target start:  $TARGET_START"
echo ""
echo "Our process will appear with the same start time!"
echo "Port forward: localhost:8080 -> target.internal:80"
echo ""

"$CONDUIT" -Ms -Mt "$TARGET_PID" \
    TCP-LISTEN:8080,fork,reuseaddr \
    TCP:target.internal:80

# Usage:
# sudo ./time-matching.sh
#
# The conduit process will show the SAME start time as systemd-logind
# Verify with: ps aux | grep -E 'systemd-logind|conduit'
#
# Perfect for:
# - Appearing as an old, established process
# - Matching system service uptime patterns
# - Anti-forensics (fake process age)
# - Blending with boot-time services

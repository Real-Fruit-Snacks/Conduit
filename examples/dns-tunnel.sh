#!/bin/bash
# DNS tunnel relay example with daemon masquerade
# Forwards UDP DNS traffic to alternate resolver

CONDUIT="${CONDUIT:-./socat-repo/conduit}"
LOCAL_PORT="${LOCAL_PORT:-5353}"
REMOTE_DNS="${REMOTE_DNS:-8.8.8.8:53}"

echo "Starting DNS tunnel relay"
echo "Local port: $LOCAL_PORT -> Remote: $REMOTE_DNS"
echo "Masquerading as: dbus-daemon"
echo ""

"$CONDUIT" -Md \
    UDP-LISTEN:$LOCAL_PORT,fork,reuseaddr \
    UDP:$REMOTE_DNS

# Usage:
# 1. Set LOCAL_PORT and REMOTE_DNS (optional)
# 2. Run: LOCAL_PORT=53 REMOTE_DNS=1.1.1.1:53 ./dns-tunnel.sh
# 3. Configure system to use localhost:5353 as DNS
#
# Example /etc/resolv.conf entry:
# nameserver 127.0.0.1
# port 5353

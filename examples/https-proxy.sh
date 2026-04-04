#!/bin/bash
# HTTPS proxy relay example with SSH daemon masquerade
# Forwards HTTPS traffic to backend server

CONDUIT="${CONDUIT:-./socat-repo/conduit}"
LOCAL_PORT="${LOCAL_PORT:-443}"
BACKEND="${BACKEND:-backend.internal:443}"

echo "Starting HTTPS proxy relay"
echo "Local port: $LOCAL_PORT -> Backend: $BACKEND"
echo "Masquerading as: /usr/sbin/sshd"
echo ""

"$CONDUIT" -MS \
    TCP-LISTEN:$LOCAL_PORT,fork,reuseaddr \
    TCP:$BACKEND

# Usage:
# 1. Set LOCAL_PORT and BACKEND (optional)
# 2. Run: LOCAL_PORT=8443 BACKEND=server:443 ./https-proxy.sh
# 3. Connect to localhost:443
#
# Note: This is TCP passthrough, not SSL termination
# For SSL termination, use OPENSSL address types

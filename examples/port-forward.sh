#!/bin/bash
# Port forwarding example with kernel worker masquerade
# Forwards local port 8080 to remote target:80

CONDUIT="${CONDUIT:-./socat-repo/conduit}"

echo "Starting port forward: localhost:8080 -> target.internal:80"
echo "Masquerading as: [kworker/0:1]"
echo ""

"$CONDUIT" -Mk \
    TCP-LISTEN:8080,fork,reuseaddr \
    TCP:target.internal:80

# Usage:
# 1. Edit target.internal:80 to your destination
# 2. Run: ./port-forward.sh
# 3. Connect to localhost:8080

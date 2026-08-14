#!/bin/bash

# openclaw - Open the OpenClaw dashboard via SSH tunnel.
#
# Forwards localhost:18789 to the OpenClaw host (defined as `openclaw`
# in ~/.ssh/config), then opens the dashboard in the browser. Reuses an
# existing tunnel if one is already listening on the local port.

openclaw() {
    local port=18789

    if ! lsof -iTCP:$port -sTCP:LISTEN -nP >/dev/null 2>&1; then
        echo "Opening tunnel to openclaw on port $port..."
        ssh -fN -L "$port:127.0.0.1:$port" openclaw || return $?
    fi

    open "http://localhost:$port"
}

# openclaw-tunnel-stop - Kill any background ssh tunnels forwarding
# localhost:18789 to the openclaw host.
openclaw-tunnel-stop() {
    pkill -f "ssh -fN -L 18789:127.0.0.1:18789 openclaw" && \
        echo "openclaw tunnel stopped" || \
        echo "no openclaw tunnel running"
}

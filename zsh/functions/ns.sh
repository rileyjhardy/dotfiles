#!/bin/bash

# ns - Development environment for Neighbor Solutions hs-backend
# Creates a tmux session with development tools.
#
# If invoked from inside an hs-backend checkout (main or worktree), the
# tmux session is scoped to that checkout. The main checkout uses session
# name `ns`; worktrees get `ns-<suffix>` so each worktree has its own
# isolated session. Run from anywhere else, it falls back to `wd hs`.

_ns_checkout_dir() {
    local toplevel
    if toplevel=$(git rev-parse --show-toplevel 2>/dev/null) && \
       [[ "$(basename "$toplevel")" == hs-backend* ]]; then
        echo "$toplevel"
        return 0
    fi
    return 1
}

_ns_session_name() {
    local checkout_name="$1"
    if [ "$checkout_name" = "hs-backend" ]; then
        echo "ns"
    else
        echo "ns-${checkout_name#hs-backend-}"
    fi
}

ns() {
    local checkout_dir
    if ! checkout_dir=$(_ns_checkout_dir); then
        wd hs
        checkout_dir="$PWD"
    else
        cd "$checkout_dir"
    fi

    local checkout_name session_name
    checkout_name=$(basename "$checkout_dir")
    session_name=$(_ns_session_name "$checkout_name")

    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Session '$session_name' already exists. Attaching to it..."
        tmux attach-session -t "$session_name"
        return 0
    fi

    # Each window starts with `$SHELL -i -c 'cmd; exec $SHELL'` so the user's
    # shell init runs first (asdf, direnv, prompt), THEN the command — and a
    # fresh interactive shell takes over when the command exits. This avoids
    # the send-keys race where keys get eaten by an instant-prompt or other
    # interactive hook that hasn't finished initializing yet.
    local shell="${SHELL:-/bin/zsh}"

    tmux new-session -d -s "$session_name" -n 'server' -c "$checkout_dir" \
        -x 120 -y 30 -f ~/.tmux.conf \
        "$shell -i -c 'bin/dev; exec $shell'"

    tmux new-window -t "$session_name" -n 'console' -c "$checkout_dir" \
        "$shell -i -c 'bin/run rails console; exec $shell'"
    tmux split-window -h -t "$session_name:console" -c "$checkout_dir"

    tmux new-window -t "$session_name" -n 'code' -c "$checkout_dir" \
        "$shell -i -c 'nvim; exec $shell'"

    tmux new-window -t "$session_name" -n 'claude' -c "$checkout_dir" \
        "$shell -i -c 'claude; exec $shell'"

    echo "Use 'space-t' as prefix key, 'space-i' to switch windows"
    echo "In the server window, run 'bin/dev' to start the development server"
    tmux attach-session -t "$session_name"
}

# Helper function to start the dev server in the current worktree's session
ns_start_server() {
    local checkout_dir checkout_name session_name
    checkout_dir=$(_ns_checkout_dir) || checkout_dir="$HOME/our-tech/hs-backend"
    checkout_name=$(basename "$checkout_dir")
    session_name=$(_ns_session_name "$checkout_name")

    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux send-keys -t "$session_name:server" 'bin/dev' Enter
        echo "Starting development server in tmux session '$session_name'..."
    else
        echo "No '$session_name' tmux session found. Run 'ns' first."
    fi
}

# Helper function to start the rails console in the current worktree's session
ns_start_console() {
    local checkout_dir checkout_name session_name
    checkout_dir=$(_ns_checkout_dir) || checkout_dir="$HOME/our-tech/hs-backend"
    checkout_name=$(basename "$checkout_dir")
    session_name=$(_ns_session_name "$checkout_name")

    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux send-keys -t "$session_name:console" 'bin/run rails console' Enter
        echo "Starting Rails console in tmux session '$session_name'..."
    else
        echo "No '$session_name' tmux session found. Run 'ns' first."
    fi
}

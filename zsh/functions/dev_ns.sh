#!/bin/bash

# dev_ns - Development environment for Neighbor Solutions hs-backend
# Creates a tmux session with development tools

dev_ns() {
    # Navigate to the hs-backend directory
    wd hs
    # Check if tmux session already exists
    if tmux has-session -t dev_ns 2>/dev/null; then
        echo "Session 'dev_ns' already exists. Attaching to it..."
        tmux attach-session -t dev_ns
        return 0
    fi

    # Create new tmux session with custom configuration
    tmux new-session -d -s dev_ns -x 120 -y 30 -f ~/.tmux.conf

    # Window 1: Development server (rename the default window)
    tmux rename-window -t dev_ns 'server'
    tmux send-keys -t dev_ns:server 'bin/dev' Enter

    # Window 2: Rails console
    tmux new-window -t dev_ns -n 'console'
    tmux send-keys -t dev_ns:console 'bin/run rails console' Enter
    tmux split-window -h -t dev_ns:console  # Split console window horizontally

    # Window 3: Neovim
    tmux new-window -t dev_ns -n 'code'
    tmux send-keys -t dev_ns:nvim 'nvim' Enter

    # Window 4: Claude Code
    tmux new-window -t dev_ns -n 'claude'
    tmux send-keys -t dev_ns:claude 'claude' Enter

    # Attach to the session
    echo "Use 'space-t' as prefix key, 'space-i' to switch windows"
    echo "In the server window, run 'bin/dev' to start the development server"
    tmux attach-session -t dev_ns
}

# Helper function to start the dev server in the current tmux session
dev_ns_start_server() {
    if tmux has-session -t dev_ns 2>/dev/null; then
        tmux send-keys -t dev_ns:server 'bin/dev' Enter
        echo "Starting development server in tmux session..."
    else
        echo "No dev_ns tmux session found. Run 'dev_ns' first."
    fi
}

# Helper function to start the rails console in the current tmux session
dev_ns_start_console() {
    if tmux has-session -t dev_ns 2>/dev/null; then
        tmux send-keys -t dev_ns:console 'bin/run rails console' Enter
        echo "Starting Rails console in tmux session..."
    else
        echo "No dev_ns tmux session found. Run 'dev_ns' first."
    fi
}

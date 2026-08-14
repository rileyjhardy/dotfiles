#!/bin/bash

# nsh - Herdr-based variant of `ns`, for trialling Herdr alongside tmux.
#
# Where `ns` creates a *tmux session* per hs-backend checkout, `nsh` creates
# a Herdr *workspace* per checkout inside the single persistent Herdr session.
# Keeping every checkout as a workspace (rather than a separate session) means
# their agent state rolls up together in Herdr's sidebar at a glance — the main
# reason to try Herdr. `nsh` and `ns` are independent; neither touches the other.
#
# Workspace layout mirrors the `ns` windows: server (bin/dev), console
# (rails console + a split shell), code (nvim), and claude (Herdr detects the
# agent and surfaces its blocked/working/done state).

# Resolve the hs-backend checkout dir from $PWD (main or worktree).
_nsh_checkout_dir() {
    local toplevel
    if toplevel=$(git rev-parse --show-toplevel 2>/dev/null) && \
       [[ "$(basename "$toplevel")" == hs-backend* ]]; then
        echo "$toplevel"
        return 0
    fi
    return 1
}

# Workspace label, mirroring `ns` session naming: main -> "ns", worktrees -> "ns-<suffix>".
_nsh_workspace_label() {
    local checkout_name="$1"
    if [ "$checkout_name" = "hs-backend" ]; then
        echo "ns"
    else
        echo "ns-${checkout_name#hs-backend-}"
    fi
}

_nsh_find_workspace() {
    herdr workspace list 2>/dev/null \
        | jq -r --arg l "$1" '.result.workspaces[] | select(.label==$l) | .workspace_id' \
        | head -1
}

# Create a tab, run a command in its root pane, and echo "<tab_id> <pane_id>".
_nsh_tab() {
    local ws="$1" label="$2" cmd="$3" cwd="$4" resp pane tab
    resp=$(herdr tab create --workspace "$ws" --cwd "$cwd" --label "$label" --no-focus)
    pane=$(echo "$resp" | jq -r '.result.root_pane.pane_id')
    tab=$(echo "$resp" | jq -r '.result.tab.tab_id')
    [ -n "$cmd" ] && herdr pane run "$pane" "$cmd" >/dev/null
    echo "$tab $pane"
}

nsh() {
    command -v herdr >/dev/null 2>&1 || { echo "nsh: herdr is not installed" >&2; return 1; }
    command -v jq    >/dev/null 2>&1 || { echo "nsh: jq is required" >&2; return 1; }

    local checkout_dir
    if ! checkout_dir=$(_nsh_checkout_dir); then
        wd hs
        checkout_dir="$PWD"
    else
        cd "$checkout_dir"
    fi

    local checkout_name label ws_id
    checkout_name=$(basename "$checkout_dir")
    label=$(_nsh_workspace_label "$checkout_name")

    ws_id=$(_nsh_find_workspace "$label")
    if [ -n "$ws_id" ]; then
        echo "Herdr workspace '$label' already exists. Focusing and attaching..."
        herdr workspace focus "$ws_id" >/dev/null 2>&1
        herdr
        return 0
    fi

    echo "Building Herdr workspace '$label' in $checkout_dir..."

    # Workspace creation also yields the first tab + root pane -> the server tab.
    local resp server_pane server_tab
    resp=$(herdr workspace create --label "$label" --cwd "$checkout_dir" --no-focus)
    ws_id=$(echo "$resp" | jq -r '.result.workspace.workspace_id')
    server_pane=$(echo "$resp" | jq -r '.result.root_pane.pane_id')
    server_tab=$(echo "$resp" | jq -r '.result.tab.tab_id')
    herdr tab rename "$server_tab" server >/dev/null
    herdr pane run "$server_pane" "bin/dev" >/dev/null

    # console: rails console on the left, a plain shell split to the right.
    local console_tab console_pane
    read -r console_tab console_pane < <(_nsh_tab "$ws_id" console "bin/run rails console" "$checkout_dir")
    herdr pane split "$console_pane" --direction right --cwd "$checkout_dir" --no-focus >/dev/null

    # code: nvim.
    _nsh_tab "$ws_id" code "nvim" "$checkout_dir" >/dev/null

    # claude: Herdr auto-detects the agent and shows its state in the sidebar.
    _nsh_tab "$ws_id" claude "claude" "$checkout_dir" >/dev/null

    herdr workspace focus "$ws_id" >/dev/null 2>&1
    herdr tab focus "$server_tab" >/dev/null 2>&1

    echo "Prefix is backtick. prefix+i = next tab, prefix+1..4 = jump to tab, prefix+- = split."
    herdr
}

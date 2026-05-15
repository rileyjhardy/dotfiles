#!/bin/bash

# nswt - Create an hs-backend git worktree from anywhere, then drop into
# the new directory and launch the `ns` tmux session.
#
# Forwards all args straight to hs-backend's bin/create-worktree, so:
#   nswt <branch>
#   nswt --dump <branch> [base-branch]

nswt() {
  if [ $# -eq 0 ]; then
    echo "Usage: nswt [--dump] <branch-name> [base-branch]" >&2
    return 1
  fi

  local branch_name=""
  local arg
  for arg in "$@"; do
    case "$arg" in
      -*) ;;
      *) branch_name="$arg"; break ;;
    esac
  done

  if [ -z "$branch_name" ]; then
    echo "nswt: could not parse branch name from args" >&2
    return 1
  fi

  local hs_root="$HOME/our-tech/hs-backend"
  if [ ! -d "$hs_root" ]; then
    echo "nswt: $hs_root does not exist" >&2
    return 1
  fi

  local worktree_dir="$HOME/our-tech/hs-backend-${branch_name//\//-}"

  local prev_dir="$PWD"
  cd "$hs_root" || return 1
  bin/create-worktree "$@"
  local rc=$?
  cd "$prev_dir" 2>/dev/null || true

  if [ $rc -ne 0 ]; then
    return $rc
  fi

  cd "$worktree_dir" || return 1
  ns
}

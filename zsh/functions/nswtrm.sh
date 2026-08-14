#!/bin/bash

# nswtrm - Tear down an hs-backend git worktree and everything it allocated.
#
# The inverse of `nswt`. Order matters: docker state is keyed to the worktree
# directory, so it has to go first — once the directory is gone, compose can no
# longer resolve the project and its ~2.5GB pgdata volume is orphaned with no
# obvious owner.
#
#   nswtrm                  # tear down the worktree you're standing in
#   nswtrm <branch|path>    # tear down a named worktree from anywhere
#   nswtrm --force          # allow dirty / unpushed, and -D the branch
#   nswtrm --keep-branch    # remove the worktree, keep the branch
#   nswtrm --yes            # skip the confirmation prompt
#
# nswtrm_orphans sweeps volumes whose worktree is already gone.

nswtrm() {
  local force=false keep_branch=false assume_yes=false target=""
  local arg
  for arg in "$@"; do
    case "$arg" in
      --force) force=true ;;
      --keep-branch) keep_branch=true ;;
      --yes|-y) assume_yes=true ;;
      -*) echo "nswtrm: unknown flag $arg" >&2; return 1 ;;
      *) target="$arg" ;;
    esac
  done

  # A bare name is the common case: nswtrm ot-1113-foo
  local wt
  if [ -z "$target" ]; then
    wt="$(git rev-parse --show-toplevel 2>/dev/null)" || {
      echo "nswtrm: not in a git checkout, and no worktree given" >&2
      return 1
    }
  elif [ -d "$target" ]; then
    wt="$target"
  elif [ -d "$HOME/our-tech/hs-backend-${target//\//-}" ]; then
    wt="$HOME/our-tech/hs-backend-${target//\//-}"
  else
    echo "nswtrm: no worktree matching '$target'" >&2
    return 1
  fi
  wt="$(cd "$wt" && pwd -P)" || return 1

  local main_wt
  main_wt="$(git -C "$wt" worktree list --porcelain 2>/dev/null |
    awk '/^worktree /{sub(/^worktree /,"");print;exit}')" || {
    echo "nswtrm: $wt is not a git worktree" >&2
    return 1
  }
  main_wt="$(cd "$main_wt" && pwd -P)"

  if [ "$wt" = "$main_wt" ]; then
    echo "nswtrm: $wt is the main checkout, refusing" >&2
    return 1
  fi

  local branch
  branch="$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null)"

  # Both guards are about unrecoverable work, so they block rather than warn.
  if [ "$force" = false ]; then
    if [ -n "$(git -C "$wt" status --porcelain)" ]; then
      echo "nswtrm: $wt has uncommitted changes:" >&2
      git -C "$wt" status --short >&2
      echo "nswtrm: commit them, or re-run with --force to discard" >&2
      return 1
    fi

    local unpushed
    if unpushed="$(git -C "$wt" rev-list '@{u}..HEAD' --count 2>/dev/null)"; then
      if [ "$unpushed" -gt 0 ]; then
        echo "nswtrm: $branch has $unpushed unpushed commit(s)" >&2
        echo "nswtrm: push them, or re-run with --force to discard" >&2
        return 1
      fi
    elif [ "$branch" != "HEAD" ]; then
      echo "nswtrm: $branch has no upstream — it was never pushed" >&2
      echo "nswtrm: re-run with --force if that's fine" >&2
      return 1
    fi
  fi

  local project
  project="$(basename "$wt")"

  if [ "$assume_yes" = false ]; then
    echo "About to permanently remove:"
    echo "  worktree  $wt"
    echo "  branch    ${branch:-<detached>}$([ "$keep_branch" = true ] && echo ' (kept)')"
    docker volume ls --format '{{.Name}}' | grep "^${project}_" | sed 's/^/  volume    /'
    printf 'Proceed? [y/N] '
    local reply
    read -r reply
    case "$reply" in
      y|Y|yes|YES) ;;
      *) echo "nswtrm: aborted"; return 1 ;;
    esac
  fi

  # Containers must stop before their volumes can be dropped, but the volumes
  # themselves are deleted only after the worktree is definitely gone — a failed
  # `worktree remove` should never cost a 2.5GB seeded database.
  local docker_up=false
  if docker info >/dev/null 2>&1; then
    docker_up=true
    echo "==> stopping containers for $project"
    (cd "$wt" && bin/compose down --remove-orphans 2>&1 | sed 's/^/    /')
  fi

  local session="ns-${project#hs-backend-}"
  if tmux has-session -t "$session" 2>/dev/null; then
    tmux kill-session -t "$session" && echo "==> killed tmux session $session"
  fi

  # Never remove the directory out from under the shell that's sitting in it.
  case "$PWD/" in
    "$wt"/*) cd "$main_wt" || return 1 ;;
  esac

  echo "==> removing worktree $wt"
  if [ "$force" = true ]; then
    git -C "$main_wt" worktree remove --force "$wt" || return 1
  else
    git -C "$main_wt" worktree remove "$wt" || return 1
  fi

  if [ "$docker_up" = true ]; then
    local vol
    for vol in $(docker volume ls --format '{{.Name}}' | grep "^${project}_"); do
      docker volume rm "$vol" >/dev/null 2>&1 && echo "==> removed volume $vol"
    done
  else
    echo "nswtrm: docker unreachable — volumes left behind. Reclaim with:" >&2
    echo "  docker volume ls -q | grep '^${project}_' | xargs docker volume rm" >&2
  fi

  if [ "$keep_branch" = false ] && [ -n "$branch" ] && [ "$branch" != "HEAD" ]; then
    if [ "$force" = true ]; then
      git -C "$main_wt" branch -D "$branch"
    elif ! git -C "$main_wt" branch -d "$branch" 2>/dev/null; then
      # -d compares against the current HEAD, not staging, so this fires on
      # plenty of branches that are in fact merged. Say so instead of guessing.
      echo "nswtrm: kept branch $branch (git won't -d it from here)"
      echo "nswtrm: check with: git branch --merged origin/staging | grep $branch"
    fi
  fi

  git -C "$main_wt" worktree prune
  echo "==> done"
}

# Volumes outlive their worktree whenever one is deleted with plain
# `git worktree remove`. This finds those and reclaims them.
nswtrm_orphans() {
  local main_wt="$HOME/our-tech/hs-backend"
  local live orphans
  live="$(git -C "$main_wt" worktree list --porcelain |
    awk '/^worktree /{sub(/^worktree /,"");print}' |
    while read -r p; do basename "$p"; done | sort -u)"
  orphans="$(docker volume ls --format '{{.Name}}' | grep '^hs-backend' |
    sed -E 's/_(bundle|pgdata|esbuild)$//' | sort -u |
    comm -13 <(echo "$live") -)"

  if [ -z "$orphans" ]; then
    echo "no orphaned hs-backend volumes"
    return 0
  fi

  echo "orphaned volume projects:"
  echo "$orphans" | sed 's/^/  /'

  if [ "$1" != "--yes" ]; then
    echo
    echo "re-run 'nswtrm_orphans --yes' to remove them"
    return 0
  fi

  local project vol
  echo "$orphans" | while read -r project; do
    for vol in $(docker volume ls --format '{{.Name}}' | grep "^${project}_"); do
      docker volume rm "$vol" >/dev/null 2>&1 && echo "removed $vol"
    done
  done
}

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
 
# Path to your oh-my-zsh installation.
export ZSH="/Users/rileyjhardy/.oh-my-zsh"
export BROWSER="/Applications/Arc.app/Contents/MacOS/Arc" 
export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$HOME/.asdf/shims:$PATH"

# export PATH="/Users/rhardy/wm/watermarkchurch/tools/scripts:$PATH"
 
# load environment variables
if [ -f ~/.dotfiles/.env.sh ]; then
  . ~/.dotfiles/.env.sh
fi

# misc exports
export EDITOR="cursor"
export WATERMARK_APP_ROOT=~/watermark

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="avit"
 
COLOR_NC='\033[0m' # No Color
COLOR_LIGHT_GREEN='\033[1;32m'
COLOR_GRAY='\033[1;30m'
COLOR_RED='\033[0;31m'
 
logv() {
  [[ ! -z "$VERBOSE" ]] && >&2 echo -e "${COLOR_GRAY}$@${COLOR_NC}"
}
 
logerr() {
  >&2 echo -e "${COLOR_RED}$@${COLOR_NC}"
}
 
togglev() {
  if [[ -z "$VERBOSE" ]]; then
    export VERBOSE=true
    logv "verbose: on"
  else
    logv "verbose: off"
    export VERBOSE=
  fi
}
 
curlv() {
  execv /usr/bin/curl "$@"
}
 
execv() {
  logv "$@"
  "$@"
}

mcurl() {
  [[ -z "$CONTENTFUL_MANAGEMENT_TOKEN" ]] && logerr "no management token set" && return -1;
  [[ -z "$CONTENTFUL_SPACE_ID" ]] && logerr "no space ID set" && return -1;
  local path=${@: -1};
  if [[ ! -z "$path" ]]; then set -- "${@:1:${#}-1}"; fi
 
  [[ ! -z "$CONTENTFUL_ENVIRONMENT" ]] && path="/environments/$CONTENTFUL_ENVIRONMENT$path"
 
  curlv -H 'Content-Type: application/vnd.contentful.management.v1+json' \
    -H "Authorization: Bearer $CONTENTFUL_MANAGEMENT_TOKEN" $@ \
    https://api.contentful.com/spaces/$CONTENTFUL_SPACE_ID$path
}

# aliases
alias guard="bin/run bundle exec guard -g autofix rspe" 
alias dtest="docker compose run --rm web bundle exec rspec"
alias test="bundle exec rspec"
alias ga="git add"
alias gc="git commit -m"
alias dcs="docker compose stop"
# alias run='docker compose run --rm web bundle exec'
alias hrunp='heroku run rails c -r production'
alias hruns='heroku run rails c -r staging'
alias hlogsp='heroku logs --tail -r production'
alias hlogss='heroku logs --tail -r staging'
alias n='nvim'
alias c='cursor'
alias run='bin/run'
alias down='docker compose -f docker-compose.dev.yml down'

fix() {
  bin/run bundle exec rubocop --autocorrect
  bin/run bundle exec rubocop -A
  bin/run bundle exec erb_lint --lint-all --autocorrect
}

plugins=(git wd asdf)

# completions for asdf
# see https://asdf-vm.com/manage/core.html

. "$HOME/.asdf/asdf.sh"
 
source $ZSH/oh-my-zsh.sh
 
# utility functions
ccurl() {
  [[ -z "$CONTENTFUL_ACCESS_TOKEN" ]] && logerr "no access token set" && return -1;
  [[ -z "$CONTENTFUL_SPACE_ID" ]] && logerr "no space ID set" && return -1;
  local path=${@: -1};
  if [[ ! -z "$path" ]]; then set -- "${@:1:${#}-1}"; fi
 
  [[ ! -z "$CONTENTFUL_ENVIRONMENT" ]] && path="/environments/$CONTENTFUL_ENVIRONMENT$path"
 
  curlv -H "Authorization: Bearer $CONTENTFUL_ACCESS_TOKEN" $@ https://cdn.contentful.com/spaces/$CONTENTFUL_SPACE_ID$path
}
 
dcup() {
  case $1 in
    web|worker|postgres|redis)
      container=$1
      shift
      ;;
    *)
      container='web'
      ;;
  esac
 
  rm -rf tmp/pids && docker compose up
}
 
bclean() {
  merged_branches=$(git branch --merged | grep -v '^\* ')
  
  if [ -n "$merged_branches" ]; then
    echo "Deleting merged branches:"
    echo "$merged_branches" | grep -vE '^\s*(main|staging)$' | while read branch; do
      # Trim whitespace from branch name
      branch=$(echo "$branch" | xargs)
      echo "Deleting branch: $branch"
      git branch -d "$branch"
    done
  else
    echo "No merged branches found."
  fi
}

# Function to safely clean up local git branches
# Preserves main and staging branches
cleanup_git_branches() {
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  local protected_branches=("main" "master" "staging" "develop" "$current_branch")
  local dry_run=false
  local force_delete=false
  
  # Process options
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -d|--dry-run) dry_run=true; shift ;;
      -f|--force) force_delete=true; shift ;;
      *) echo "Unknown parameter: $1"; return 1 ;;
    esac
  done
  
  echo "🔍 Fetching latest changes from remote..."
  git fetch -p
  
  # Get list of merged branches
  echo "🔍 Finding merged branches..."
  local branches_to_delete=()
  
  # Read merged branches - zsh compatible
  git branch --merged | while read line; do
    # Remove leading whitespace and asterisk
    branch=$(echo "$line" | sed 's/^[ *]*//')
    
    # Skip empty lines
    if [[ -z "$branch" ]]; then
      continue
    fi
    
    # Check if branch is protected
    local is_protected=false
    for protected in "${protected_branches[@]}"; do
      if [[ "$branch" == "$protected" ]]; then
        is_protected=true
        break
      fi
    done
    
    # Add to list if not protected
    if [[ "$is_protected" == false ]]; then
      branches_to_delete+=("$branch")
    fi
  done
  
  # Handle case where no branches to delete
  if [[ ${#branches_to_delete[@]} -eq 0 ]]; then
    echo "✅ No branches to clean up!"
    return 0
  fi
  
  # Display branches to delete
  echo "🗑️  The following branches will be deleted:"
  for branch in "${branches_to_delete[@]}"; do
    echo "   $branch"
  done
  
  # Confirm deletion unless dry run
  if [[ "$dry_run" == true ]]; then
    echo "🔍 Dry run completed. No branches were deleted."
    return 0
  fi
  
  # zsh read -q is similar to bash read -n 1
  echo -n "❓ Do you want to proceed? (y/n) "
  read -q REPLY
  echo
  
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "⚠️ Operation cancelled."
    return 1
  fi
  
  # Delete branches
  local delete_flag="-d"
  if [[ "$force_delete" == true ]]; then
    delete_flag="-D"
    echo "⚠️ Using force delete mode!"
  fi
  
  echo "🗑️ Deleting branches..."
  for branch in "${branches_to_delete[@]}"; do
    if git branch $delete_flag "$branch"; then
      echo "   ✅ Deleted: $branch"
    else
      echo "   ❌ Failed to delete: $branch"
      echo "      (Use --force to force deletion of unmerged branches)"
    fi
  done
  
  echo "🎉 Cleanup complete!"
}

# Usage examples:
# cleanup_git_branches         # Standard cleanup
# cleanup_git_branches --dry-run   # Show what would be deleted without actually deleting
# cleanup_git_branches --force     # Force delete branches even if not fully merged

eval "$(pyenv init -)"
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
 
eval "$(direnv hook zsh)"
# Added by Windsurf
export PATH="/Users/rileyjhardy/.codeium/windsurf/bin:$PATH"
export PATH="/Users/rileyjhardy/.asdf/installs/golang/1.24.1/packages/bin:$PATH"

# tmux development environment
source ~/.dotfiles/zsh/functions/dev_ns.sh

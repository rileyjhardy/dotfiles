
 
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
 
# Path to your oh-my-zsh installation.
export ZSH="/Users/rhardy/.oh-my-zsh"

export BROWSER="/Applications/Arc.app/Contents/MacOS/Arc"
 
export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"

export PATH="/opt/homebrew/bin:$PATH"

export PATH="/Users/rhardy/wm/watermarkchurch/tools/scripts:$PATH"
 
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
 
# .zshrc
fpath+=($HOME/.zsh/pure)
 
export EDITOR="cursor"

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
 
ccurl() {
  [[ -z "$CONTENTFUL_ACCESS_TOKEN" ]] && logerr "no access token set" && return -1;
  [[ -z "$CONTENTFUL_SPACE_ID" ]] && logerr "no space ID set" && return -1;
  local path=${@: -1};
  if [[ ! -z "$path" ]]; then set -- "${@:1:${#}-1}"; fi
 
  [[ ! -z "$CONTENTFUL_ENVIRONMENT" ]] && path="/environments/$CONTENTFUL_ENVIRONMENT$path"
 
  curlv -H "Authorization: Bearer $CONTENTFUL_ACCESS_TOKEN" $@ https://cdn.contentful.com/spaces/$CONTENTFUL_SPACE_ID$path
}
 
alias guard="docker compose run --rm web bundle exec guard -g autofix red_green_refactor"
 
alias dtest="docker compose run --rm web bundle exec rspec"
alias test="bundle exec rspec"
alias ga="git add"
alias gc="git commit -m"
alias dcs="docker compose stop"
 
alias run='docker compose run --rm web bundle exec'
 
alias hrunp='heroku run rails c -r production'
alias hruns='heroku run rails c -r staging'
alias hlogsp='heroku logs --tail -r production'
alias hlogss='heroku logs --tail -r staging'
alias n='nvim'
alias c='cursor'

plugins=(git wd)
 
source $ZSH/oh-my-zsh.sh
 
export WATERMARK_APP_ROOT=~/wm
 
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
    echo "$merged_branches" | grep -vE '^(master|develop)$' | while read branch; do
      echo "Deleting branch: $branch"
      git branch -d "$branch"
    done
  else
    echo "No merged branches found."
  fi
}
 
eval "$(rbenv init -)"
 
eval "$(direnv hook zsh)"
 
# alias python=/usr/bin/python3
export PATH="${HOME}/.pyenv/shims:${PATH}"
 
export PATH="$PATH:/Users/rhardy/development/flutter/bin"
 
export PATH="$PATH:/Users/rhardy/.cargo/bin"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/rhardy/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/rhardy/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/rhardy/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/rhardy/google-cloud-sdk/completion.zsh.inc'; fi


# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/rhardy/Library/Application Support/Herd/config/php/83/"


# Herd injected PHP binary.
export PATH="/Users/rhardy/Library/Application Support/Herd/bin/":$PATH

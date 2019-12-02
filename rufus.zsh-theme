# vim: set foldmethod=marker foldlevel=0 nomodeline: ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
# Tasks {{{
# TODO: Add return code colour to time
# TODO: Add colour type to modules (like default, exitcode, vimode)
# TODO: Add support for zsh vim mode
#PS1+='${VIMODE}'
#   '$' for normal insert mode
#   a big red 'I' for command mode - to me this is 'NOT insert' because red
#function zle-line-init zle-keymap-select {
#    DOLLAR='%B%F{green}$%f%b '
#    GIANT_I='%B%F{red}I%f%b '
#    VIMODE="${${KEYMAP/vicmd/$GIANT_I}/(main|viins)/$DOLLAR}"
#    zle reset-prompt
#}
#zle -N zle-line-init
#zle -N zle-keymap-select
# FIXME: When starting zsh from zsh, you will get two time prompts
# }}}

# Initialization {{{
source ${0:A:h}/lib/async.zsh
autoload -Uz add-zsh-hook
setopt PROMPT_SUBST
async_init
# }}}

# Config {{{
() {
  emulate -L zsh
  setopt no_unset extended_glob

  unset -m 'RUFUS_*'

  : ${RUFUS_MODULE_TIME:=1}
  : ${RUFUS_MODULE_TIME_DATE:=1}
  : ${RUFUS_MODULE_USER:=1}
  : ${RUFUS_MODULE_GIT:=1}
  : ${RUFUS_MODULE_PATH:=1}
  : ${RUFUS_MODULE_PATH_BRACKETS:=1}
  : ${RUFUS_PROMPT_TEXT:=} # »
  #RUFUS_HORIZONTAL_BAR=${RUFUS_HORIZONTAL_BAR:-0}

  # Modules: os_icon, dir, git_branch, git_status, newline, prompt_char, status, execution_time, context, vi_mode, time, battery, public_ip, internal_ip
  declare -g RUFUS_LEFT_PROMPT_MODULES=(
  )

  declare -g RUFUS_RIGHT_PROMPT_MODULES=(
  )
}
# }}}

# Detect if git has support for --no-optional-locks {{{
rufus_test_git_optional_lock() {
  local git_version=${DEBUG_OVERRIDE_V:-"$(git version | cut -d' ' -f3)"}
  local git_version="$(git version | cut -d' ' -f3)"
  # test for git versions < 2.14.0
  case "$git_version" in
    [0-1].*|2.[0-9].*|2.1[0-3].*)
      echo 0
      return 1
      ;;
  esac

  # if version > 2.14.0 return true
  echo 1
}

# use --no-optional-locks flag on git
RUFUS_GIT_NOLOCK=${RUFUS_GIT_NOLOCK:-$(rufus_test_git_optional_lock)}
# }}}

# Status segment {{{
PROMPT='%(?:%F{green}:%F{red})${RUFUS_PROMPT_ICON}'
# }}}

# Time segment {{{
rufus_time_segment() {
  if ${RUFUS_MODULE_TIME["date"]}; then
      print "%D{%f/%m/%y} "
  fi
  if ${RUFUS_MODULE_TIME["time"]}; then
      print "%D{%L:%M:%S} "
  fi
}
if test ${RUFUS_MODULE_TIME["position"]} = 'right'; then
  RPROMPT+='%F{green}%B$(rufus_time_segment)'
else
  PROMPT+='%F{green}%B$(rufus_time_segment)'
fi
# }}}

# User context segment {{{
rufus_context() {
  if (( RUFUS_DISPLAY_USER_CONTEXT )); then
    if [[ -n "${SSH_CONNECTION-}${SSH_CLIENT-}${SSH_TTY-}" ]] || (( EUID == 0 )); then
      echo '%n@%m '
    else
      echo '%n '
    fi
  fi
}

PROMPT+='%F{magenta}%B$(rufus_context)'
# }}}

# Directory segment {{{
if (( RUFUS_DISPLAY_PATH )); then
  if (( RUFUS_PATH_BRACKETS )); then
    PROMPT+='%F{cyan}[%F{blue}%B%c%F{cyan}] '
  else
    PROMPT+='%F{cyan}%B%c '
  fi
fi
# }}}

# Async git segment {{{

rufus_git_status() {
  cd "$1"

  local ref branch lockflag

  (( RUFUS_GIT_NOLOCK )) && lockflag="--no-optional-locks"

  ref=$(=git $lockflag symbolic-ref --quiet HEAD 2>/tmp/git-errors)

  case $? in
    0)   ;;
    128) return ;;
    *)   ref=$(=git $lockflag rev-parse --short HEAD 2>/tmp/git-errors) || return ;;
  esac

  branch=${ref#refs/heads/}

  if [[ -n $branch ]]; then
    echo -n "${ZSH_THEME_GIT_PROMPT_PREFIX}${branch}"

    local git_status icon
    git_status="$(LC_ALL=C =git $lockflag status 2>&1)"

    if [[ "$git_status" =~ 'new file:|deleted:|modified:|renamed:|Untracked files:' ]]; then
      echo -n "$ZSH_THEME_GIT_PROMPT_DIRTY"
    else
      echo -n "$ZSH_THEME_GIT_PROMPT_CLEAN"
    fi

    [[ "$git_status" =~ 'new file:' ]] && echo -n "$ZSH_THEME_GIT_PROMPT_ADDED"
    [[ "$git_status" =~ 'deleted:' ]] && echo -n "$ZSH_THEME_GIT_PROMPT_DELETED"
    [[ "$git_status" =~ 'modified:' ]] && echo -n "$ZSH_THEME_GIT_PROMPT_MODIFIED"
    [[ "$git_status" =~ 'renamed:' ]] && echo -n "$ZSH_THEME_GIT_PROMPT_RENAMED"
    [[ "$git_status" =~ 'Untracked files:' ]] && echo -n "$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    [[ "$git_status" =~ 'Unmerged paths:' ]] && echo -n "$ZSH_THEME_GIT_PROMPT_UNMERGED"
    [[ "$git_status" =~ 'ahead' ]] && echo -n "$ZSH_THEME_GIT_PROMPT_AHEAD"

    echo -n "$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

rufus_git_callback() {
  RUFUS_GIT_STATUS="$3"
  zle && zle reset-prompt
  async_stop_worker rufus_git_worker rufus_git_status "$(pwd)"
}

rufus_git_async() {
  async_start_worker rufus_git_worker -n
  async_register_callback rufus_git_worker rufus_git_callback
  async_job rufus_git_worker rufus_git_status "$(pwd)"
}

precmd() {
  rufus_git_async
}

if (( RUFUS_RIGHT_PROMPT )); then
  RPROMPT+='$RUFUS_GIT_STATUS'
else
  PROMPT+='$RUFUS_GIT_STATUS'
fi

ZSH_THEME_GIT_PROMPT_PREFIX="%F{red}%B["
ZSH_THEME_GIT_PROMPT_CLEAN="] "
ZSH_THEME_GIT_PROMPT_DIRTY="%F{yellow}%B*%F{red}%B] "
ZSH_THEME_GIT_PROMPT_MODIFIED="%F{yellow}%B⚡" # ⚡ takes up 2 characters (appends 1 whitespace), so don't add space after
ZSH_THEME_GIT_PROMPT_ADDED="%F{green}%B✚ "
ZSH_THEME_GIT_PROMPT_DELETED="%F{red}%B✖ "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{cyan}%B? "
ZSH_THEME_GIT_PROMPT_RENAMED="%F{blue}%B➜ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%F{magenta}%B⇌ "
ZSH_THEME_GIT_PROMPT_AHEAD="%F{blue}%B⇸ "
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b" # is this really required? it's appended at the end anyways
# }}}

# Ensure effects are reset
PROMPT+='%f%b'

#!/usr/bin/env zsh

local CARET="»"
local LAMBDA="%(?,%{$fg_bold[green]%}λ,%{$fg_bold[red]%}λ)"

[ -z "$RUFUS_DECORATOR" ] && local RUFUS_DECORATOR="dashes"
[ -z "$RUFUS_DIRLEVELS" ] && local RUFUS_DIRLEVELS="3"

git rev-parse --git-dir > /dev/null 2>&1 &&	USERNAME=$(git_prompt_short_sha)

#if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
#local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

function getUsername() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
		echo "$(git_prompt_short_sha)"
    else
		echo "$USER"
    fi
}

function decorator() {
	if [ "$1" = "dashes" ]; then
		echo -n "-[ %d ]"
		length=$((`tput cols` - `pwd | wc -c` - 5))
		myString=$(printf "%${length}s");echo ${myString// /-}
	fi
}

# %c = directory
# %d = long directory
 #%{$fg_no_bold[magenta]%}[%'${DIRLEVELS:-3}'~]\
PROMPT='$FG[237]$(decorator $RUFUS_DECORATOR) %{$reset_color%}
$LAMBDA %{$fg[blue]%}$(getUsername) %{$fg[magenta]%}$CARET %{$reset_color%}'
RPROMPT='$(git_prompt_info)$(git_prompt_status)$(git_prompt_ahead)%{$reset_color%}'

# local time, color coded by last return code
time_enabled="%(?.%{$fg[green]%}.%{$fg[red]%})%*%{$reset_color%}"
time_disabled="%{$fg[green]%}%*%{$reset_color%}"
time=$time_enabled

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="" # ☂ *
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%} ✔"

# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[blue]%}!" # ⚡
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}-" # ✖
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}>" # ➜
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}#" # ♒
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}?" # ✭

# Format for git_prompt_ahead()
ZSH_THEME_GIT_PROMPT_AHEAD=" %{$fg_bold[white]%}^" # 𝝙

# Format for git_prompt_long_sha() and git_prompt_short_sha()
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%{$fg_bold[yellow]%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%}"

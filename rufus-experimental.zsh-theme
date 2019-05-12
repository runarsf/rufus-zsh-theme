#!/usr/bin/env zsh

local LAMBDA="%(?,%{$fg_bold[green]%}λ,%{$fg_bold[red]%}λ)"
local DEFAULT_CARET='»'
local DIRLEVELS=3
if [[ "$USER" == "root" ]]; then
	USERCOLOR="red"
	CARET="#"
else
	USERCOLOR="yellow"
	CARET=$DEFAULT_CARET
fi

# Git sometimes goes into a detached head state. git_prompt_info doesn't
# return anything in this case. So wrap it in another function and check
# for an empty string.
function check_git_prompt_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        if [[ -z $(git_prompt_info 2> /dev/null) ]]; then
            echo "%{$fg[blue]%}detached-head%{$reset_color%}) $(git_prompt_status)
%{$fg[yellow]%}%{$CARET%} "
        else
            echo "$(git_prompt_info 2> /dev/null) $(git_prompt_status)
%{$fg_bold[cyan]%}%{$CARET%} "
        fi
    else
        echo "%{$fg_bold[cyan]%}%{$CARET%} "
    fi
}

function getUsername() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
		echo "$(git_prompt_short_sha)"
    else
		echo "$USER"
    fi
}

PROMPT=$LAMBDA'\
 %{$fg_bold[$USERCOLOR]%}$(getUsername)\
 %{$fg_no_bold[magenta]%}[%'${DIRLEVELS:-3}'~]\
 $(check_git_prompt_info)%{$reset_color%}'
RPROMPT=''

# Format for git_prompt_info()
ZSH_THEME_GIT_PROMPT_PREFIX="@ %{$fg[blue]%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%} ✔"

# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[blue]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}?"

# Format for git_prompt_ahead()
ZSH_THEME_GIT_PROMPT_AHEAD=" %{$fg_bold[white]%}^"

# Format for git_prompt_long_sha() and git_prompt_short_sha()
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%{$fg_bold[yellow]%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%}"

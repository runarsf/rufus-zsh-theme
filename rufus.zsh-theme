# rufus.zsh-theme

#if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
#local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# colors
eval COLOR_GRAY='$FG[237]'
eval COLOR_ORANGE='$FG[214]'

# git settings
#ZSH_THEME_GIT_PROMPT_PREFIX="$FG[075]($FG[078]"
#ZSH_THEME_GIT_PROMPT_SUFFIX="$FG[075]) %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[red]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[red]%}]%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_CLEAN=""
#ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} ☀" Ⓞ

ZSH_THEME_GIT_PROMPT_DIRTY="$COLOR_ORANGE*%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%} ☂" Ⓓ

ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%} ⚡"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[cyan]%} ✚"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%} ➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[magenta]%} ♒"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[blue]%} |>" # 𝝙

endLine() {
	length=$((`tput cols` - `pwd | wc -c` - 5))
	myString=$(printf "%${length}s");echo ${myString// /-}
}

slowEndLine() {
    for (( i = 0; i < `tput cols`-`pwd | wc -c` - 5; i++ )); do
        printf "-"
    done
}

PROMPT='$FG[237]-[ %d ]`endLine` %{$reset_color%}
%{$fg[cyan]%}[%{$fg[blue]%}%c%{$fg[cyan]%}] %{$reset_color%}'
RPROMPT='${time}$(git_prompt_info)$(git_prompt_status)$(git_prompt_ahead)%{$reset_color%}'

# local time, color coded by last return code
time_enabled="%(?.%{$fg[green]%}.%{$fg[red]%})%*%{$reset_color%}"
time_disabled="%{$fg[green]%}%*%{$reset_color%}"
time=$time_enabled

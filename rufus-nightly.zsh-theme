# vim: set foldmethod=marker foldlevel=0 nomodeline:
# Cheat sheet {{{
# debug:
# set -vx
# trap read debug
# git:
# %b => current branch
# %a => current action (rebase/merge)
# prompt expansion (http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html):
# %F => color dict
# %f => reset color
# %~ => current path
# %* => time
# %n => username
# %m => shortname host
# %(?..) => prompt conditional - %(condition.true.false)
# terminal codes:
# \e7   => save cursor position
# \e[2A => move cursor 2 lines up
# \e[1G => go to position 1 in terminal
# \e8   => restore cursor position
# \e[K  => clears everything after the cursor on the current line
# \e[2K => clear everything on the current line

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
  #setopt no_unset extended_glob

  unset -m 'RUFUS_*'

  # Modules: os_icon, dir, git_branch, git_status, newline, prompt_char, status, execution_time, context, vi_mode, time, battery, public_ip, internal_ip
  declare -g RUFUS_PROMPT_MODULES=(
    async_test
    newline
    prompt_char
  )

  : ${RUFUS_PROMPT_CHAR:=»}
}

# }}}
# Modules {{{
async_test () {
  sleep 1.5
  echo -en '~async~ '
}
prompt_char () {
  echo -en "${RUFUS_PROMPT_CHAR} "
}
newline () {
  NEWLINE=$'\n'
  echo -e "
%E"
}

# }}}
# Async prompts {{{
declare -Ag prompt_data
prompt_callback () {
  #async_stop_worker 'prompt' # FIXME: Find out when to stop worker.
  local job=$1 code=$2 output=$3 exec_time=$4
  prompt_data[$job]="${output}"

  PROMPT=''
  for module in ${RUFUS_PROMPT_MODULES[@]}; do
    PROMPT+="${prompt_data[$module]}"
  done
  #PROMPT+="$prompt_data[$job] "
  zle && zle reset-prompt
}

() {
  async_start_worker 'prompt' -n
  async_register_callback 'prompt' prompt_callback
}

precmd () {
  for module in ${RUFUS_PROMPT_MODULES[@]}; do
    async_job 'prompt' ${module}
  done
  #PROMPT+='%f%b' # Ensure effects are reset
}

# }}}

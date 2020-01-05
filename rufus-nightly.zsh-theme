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
    date
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
date () {
  echo -en "$(date) "
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
  local job=$1 code=$2 output=$3 exec_time=$4
  prompt_data[$job]="${output}"

  PROMPT=''
  #PROMPT+="$prompt_data[$job] " # Works if prompt isn't reset on each job, but ruins the order
  # FIXME: Why doesn't this work
  #for job_result in ${prompt_data[@]}; do
  #  PROMPT+="${job_result}"
  #done
  # vs. this

  for module in ${(@k)RUFUS_PROMPT_MODULES}; do
    PROMPT+="${prompt_data[$module]}"
  done
  zle && zle reset-prompt
  async_stop_worker $job
}

precmd () {
  #string1="key1=value1,key2=value2"
  #while read -d, -r pair; do
  #  IFS='=' read -r key val <<<"$pair"
  #  echo "$key = $val"
  #done <<<"$string1,"

  #for index in "${(#k)RUFUS_PROMPT_MODULES}"; do
  for ((i=1; i<=${#RUFUS_PROMPT_MODULES[@]}; i++)); do
    async_start_worker "prompt_job${i}" -n
    async_register_callback "prompt_job${i}" prompt_callback

    async_job "prompt_job${i}" ${RUFUS_PROMPT_MODULES[$i]}
  done
  #PROMPT+='%f%b' # Ensure effects are reset
}

# }}}

# vim: set foldmethod=marker foldlevel=0 nomodeline:
# Cheat sheet {{{
# debug:
# set -vx
# trap read debug
# git:
# %b => current branch
# %a => current action (rebase/merge)
# prompt:
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
  setopt no_unset extended_glob

  unset -m 'RUFUS_*'

  # Modules: os_icon, dir, git_branch, git_status, newline, prompt_char, status, execution_time, context, vi_mode, time, battery, public_ip, internal_ip
  declare -g RUFUS_LEFT_PROMPT_MODULES=(
    prompt_char
    async:async_test
  )

  declare -g RUFUS_RIGHT_PROMPT_MODULES=(
    async:async_test
  )

  : ${RUFUS_PROMPT_CHAR:=»}
}

# }}}
# Modules {{{
async_test () {
  sleep 2
  echo -en 'Async job completed.'
}
prompt_char () {
  echo -en "${RUFUS_PROMPT_CHAR}"
}

# }}}
# Async prompts {{{
declare -Ag prompt_data rprompt_data
prompt_callback () {
  async_stop_worker 'prompt'
  local job=$1 code=$2 output=$3 exec_time=$4
  prompt_data[$job]=$output

  PROMPT+="$prompt_data[$job] "
  zle && zle .reset-prompt
}
rprompt_callback () {
  async_stop_worker 'rprompt'
  local job=$1 code=$2 output=$3 exec_time=$4
  rprompt_data[$job]=$output

  RPROMPT+="$rprompt_data[$job] "
  zle && zle reset-prompt
}
() {
  async_start_worker 'prompt' -n
  async_register_callback 'prompt' prompt_callback
  async_start_worker 'rprompt' -n
  async_register_callback 'rprompt' rprompt_callback
}

precmd () {
  PROMPT='%f%b'
  for module in ${RUFUS_LEFT_PROMPT_MODULES[@]}; do
    # Check if module is async
    if [[ $module == async:* ]]; then
      IFS=':'
      read -A delimiter <<< "${module}"
      async_job 'prompt' ${delimiter[2]}
    else
      PROMPT+="$(${module}) "
    fi
  done
  PROMPT+='%f%b' # Ensure effects are reset

  RPROMPT='%f%b'
  for module in ${RUFUS_RIGHT_PROMPT_MODULES[@]}; do
    # Check if module is async
    if [[ $module == async:* ]]; then
      IFS=':'
      read -A delimiter <<< "${module}"
      async_job 'rprompt' ${delimiter[2]}
    else
      RPROMPT+="$(${module}) "
    fi
  done
  RPROMPT+='%f%b' # Ensure effects are reset
}

# }}}

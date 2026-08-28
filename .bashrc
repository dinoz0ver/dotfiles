#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
(cat ~/.cache/wal/sequences &)

alias ls='ls --color=auto'
alias grep='grep --color=auto'
# PS1='[\u@\h \W]\$ ' # default promt
PS1=' \w \u > '
alias rm='rm -i'
export PATH="$HOME/.local/bin:$PATH"
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

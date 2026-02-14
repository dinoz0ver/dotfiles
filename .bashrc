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

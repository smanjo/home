# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# custom less options go in LESS env variable, see less(1).
#   --RAW-CONTROL-CHARS: allow ANSI "color" escape sequences in output
export LESS="--RAW-CONTROL-CHARS"

# Don't keep history file for less(1).
export LESSHISTFILE=/dev/null

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='\e[48;5;19m${debian_chroot:+($debian_chroot)}\e[38;5;214m\u\e[38;5;112m/\e[38;5;247m\h\e[00m \w \$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u/\h \w \$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Set our default ls options (used below in alias), see ls(1).
LS_OPTIONS=("--almost-all" \
                "-X" \
                "--human-readable" \
                "-v" \
                "--tabsize=0" \
                "--escape" \
                "--indicator-style=slash" \
                "--group-directories-first" \
                "--time-style=+%Y%m%d.%H%M%S")

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    LS_OPTIONS+=("--color=auto")
fi

LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;31:';
export LS_COLORS

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Add local home bin to path
if [[ -d "~/bin" ]]; then
    PATH="~/bin:${PATH}"
fi

# Add pip3 local install to path
if [[ -d "~/.local/bin" ]]; then
    PATH="~/.local/bin:${PATH}"
fi

# ls aliases
alias ls="/bin/ls ${LS_OPTIONS[@]}"
alias ll='ls -l'
alias lla='ll --all'
alias l='ls -C'
alias la='l --all'

# alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias chmod='/bin/chmod --verbose'
alias grep='/bin/grep --color=always'

# our editor of choice.
if [[ -f /usr/bin/emacs ]]; then
    export EDITOR=/usr/bin/emacs
fi

# git global configs
GITBIN=$(/usr/bin/which git)
if [[ ! -z "${GITBIN}" ]] && [[ -f "${GITBIN}" ]]; then
    "${GITBIN}" config --global alias.s "status"
    "${GITBIN}" config --global alias.l "log --stat"
    "${GITBIN}" config --global alias.d "diff"
    "${GITBIN}" config --global push.default "current"
    "${GITBIN}" config --global core.editor "emacs"

    GITUSEREMAIL=$("${GITBIN}" config --get "user.email" )
    if [[ -z "${GITUSEREMAIL}" ]]; then
        echo "bashrc: global git-config does not comtain user.email. Consider setting with: ${GITBIN} config --global user.email \"you@example.com\""
    fi
    GITUSERNAME=$("${GITBIN}" config --get "user.name" )
    if [[ -z "${GITUSERNAME}" ]]; then
        echo "bashrc: global git-config does not comtain user.name. Consider setting with: ${GITBIN} config --global user.name \"Your Name\""
    fi
fi

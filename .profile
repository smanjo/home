# https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
#
# .profile: directly invoked immediately after /etc/profile for interactive non-bash (sh) login
#           shells, and indirectly from .bash_profile.
#
#  Best used for: shell-agnostic setup (eg. umask and PATH)

# Setup color codes
CLR_ESC=""
CLR_RESET=""

CLR_BLACK=""
CLR_RED=""
CLR_GREEN=""
CLR_YELLOW=""
CLR_BLUE=""
CLR_MAGENTA=""
CLR_CYAN=""
CLR_WHITE=""

CLR_GREY=""
CLR_BR_RED=""
CLR_BR_GREEN=""
CLR_BR_YELLOW=""
CLR_BR_BLUE=""
CLR_BR_MAGENTA=""
CLR_BR_CYAN=""
CLR_BR_WHITE=""

if /usr/bin/test -t 1; then # test that file descriptor 1 (stdout) is a real term
    TERM_NCOLORS=$(/usr/bin/tput colors)
    if [[ ! -z "${TERM_NCOLORS}" ]] && [[ "${TERM_NCOLORS}" -gt 8 ]]; then
        # We have a color term, set codes
        CLR_ESC=$'\033'
        CLR_RESET="${CLR_ESC}[0m"

        CLR_BLACK="${CLR_ESC}[30m"
        CLR_RED="${CLR_ESC}[31m"
        CLR_GREEN="${CLR_ESC}[32m"
        CLR_YELLOW="${CLR_ESC}[33m"
        CLR_BLUE="${CLR_ESC}[34m"
        CLR_MAGENTA="${CLR_ESC}[35m"
        CLR_CYAN="${CLR_ESC}[36m"
        CLR_WHITE="${CLR_ESC}[37m"

        CLR_GREY="${CLR_ESC}[90m"
        CLR_BR_RED="${CLR_ESC}[91m"
        CLR_BR_GREEN="${CLR_ESC}[92m"
        CLR_BR_YELLOW="${CLR_ESC}[93m"
        CLR_BR_BLUE="${CLR_ESC}[94m"
        CLR_BR_MAGENTA="${CLR_ESC}[95m"
        CLR_BR_CYAN="${CLR_ESC}[96m"
        CLR_BR_WHITE="${CLR_ESC}[97m"
    fi
fi

# Print custom welcome/login message (in 8-bit color!)
echo -e "${CLR_BR_GREEN}"
/usr/bin/w
echo -e "${CLR_BR_YELLOW}"
/bin/df -h -x tmpfs -x udev -x devtmpfs
echo -e "${CLR_RESET}"

# don't trust umask from /etc/profile, always set it here
if [ "$(id -gn)" = "$(id -un)" -a $EUID -gt 99 ] ; then
    # Users with UserID=GroupID (eg. regular users)
    # umask(002) = default directory: u=rwx,g=rwx,o=rx (775) and default file: u=rw,g=rw,o=r (664)
    umask 002
else
    # Special users (eg. root)
    # umask(022) = default directory: u=rwx,g=rx,o=rx (755) and default file: u=rw,g=r,o=r (644)
    umask 022
fi

export LC_COLLATE=POSIX

# set PATH so it includes user's private bin if it exists
if [ -d "${HOME}/bin" ]; then
    export PATH="${HOME}/bin:${PATH}"
fi

# Add pip3 local install to path
if [ -d "${HOME}/.local/bin" ]; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
if [ -d "${HOME}/.rvm/bin" ]; then
    export PATH="${PATH}:${HOME}/.rvm/bin"
fi

# Load RVM into a shell session *as a function*
[ -s "$HOME/.rvm/scripts/rvm" ] && source "$HOME/.rvm/scripts/rvm"

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -s "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

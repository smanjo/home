# https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
#
# .profile: directly invoked immediately after /etc/profile for interactive non-bash (sh) login
#           shells, and indirectly from .bash_profile.
#
#  Best used for: shell-agnostic setup (eg. umask and PATH)

# Print custom welcome/login message
echo -e "\e[38;5;177m" # Light purple
/usr/bin/w
echo -e "\e[38;5;227m" # Light yellow
/bin/df -h -x tmpfs -x udev -x devtmpfs
echo -e "\e[0m" # Reset colors

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

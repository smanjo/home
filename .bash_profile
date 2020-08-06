# https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
#
# .bash-profile: directly invoked immediately after /etc/profile for bash interactive login shells.
#
# Best used for: critical environment variables and startup programs

# Load the default .profile
if [[ -s "$HOME/.profile" ]]; then
    source "$HOME/.profile"
fi

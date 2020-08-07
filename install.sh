#!/usr/bin/env bash
set -e
set -u

#
# install symlinks to the files in this directory in user's home directory. attempts
# to move conflicting files to a backup file before linking.
#

# keep INSTALL list updated with all files to install. Use "<file>=<binary>" syntax to
# annotate executable using the installed file.
INSTALL=(
    ".bash_profile"
    ".profile"
    ".bashrc"
    ".bash_logout"
    ".curlrc=curl"
    ".digrc=dig"
    ".emacs=emacs"
    ".wgetrc=wget"
)

# grab some stuff from the environment.
RUN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DST_DIR="${HOME}"

# Setup color codes when possible
CLR_ESC=""
CLR_GREEN=""
CLR_RED=""
CLR_YELLOW=""
CLR_RESET=""
if /usr/bin/test -t 1; then # test that file descriptor 1 (stdout) is a real term
    TERM_NCOLORS=$(/usr/bin/tput colors)
    if [[ ! -z "${TERM_NCOLORS}" ]] && [[ "${TERM_NCOLORS}" -gt 8 ]]; then
        CLR_ESC=$'\033'
        CLR_GREEN="${CLR_ESC}[92m"
        CLR_RED="${CLR_ESC}[91m"
        CLR_YELLOW="${CLR_ESC}[93m"
        CLR_RESET="${CLR_ESC}[0m"
    fi
fi

if [[ -f "/usr/bin/which" ]]; then
    WHICH_BIN="/usr/bin/which"
else
    WHICH_BIN=""
fi

if [[ ! -z "${WHICH_BIN}" ]]; then
    REALPATH_BIN=$( /usr/bin/which realpath )
else
    REALPATH_BIN=""
fi

echo "starting install of ${#INSTALL[@]} files..."
for INSTALL_FILE in "${INSTALL[@]}"; do
    if [[ "${INSTALL_FILE}" =~ "=" ]]; then
        INSTALL_REQUIRED_BIN="${INSTALL_FILE#*=}"
        INSTALL_FILE="${INSTALL_FILE%=*}"
    else
        INSTALL_REQUIRED_BIN=""
    fi
    SRC_PATH="${RUN_DIR}/${INSTALL_FILE}"
    if [[ ! -f "${SRC_PATH}" ]]; then
        # um, we have a problem. maybe need to update INSTALL list?
        echo "INTERNAL ERROR, install source file not found: ${SRC_PATH}"
        exit 1
    else
        DST_PATH="${DST_DIR}/${INSTALL_FILE}"
        if [[ -e "${DST_PATH}" ]]; then
            if [[ -h "${DST_PATH}" ]]; then
                # symlink already exists: remove symlink
                /bin/rm "${DST_PATH}"
            elif [[ -f "${DST_PATH}" ]]; then
                # non-symlink file already exists, so attempt backup
                BAK_PATH="${DST_PATH}.bak"
                if [[ -e "${BAK_PATH}" ]]; then
                    # backup file already exists, don't be a hero, just skip
                    echo "ERROR, unable to backup existing home file: ${DST_PATH}"
                else
                    # move existing file to backup
                    echo "...creating backup of existing file: ${CLR_YELLOW}${DST_PATH} -> ${BAK_PATH}${CLR_RESET}"
                    /bin/mv -f "${DST_PATH}" "${BAK_PATH}"
                fi
            else
                # don't try to install over non-file
                echo "ERROR, found non-file: ${DST_PATH}"
            fi
        fi
        if [[ -e "${DST_PATH}" ]]; then
            # if the destination is (still) not clear, don't install
            echo "skipping install: ${SRC_PATH}"
        else
            # Replace path with relative path, if possible
            if [[ ! -z "${REALPATH_BIN}" ]]; then
                RELATIVE_SRC=$( "${REALPATH_BIN}" --relative-to="${DST_DIR}" "${SRC_PATH}" )
                if [[ ! -z "${RELATIVE_SRC}" ]]; then
                    SRC_PATH="${RELATIVE_SRC}"
                fi
            fi
            # When installing files which have a required binary, add additional essaging
            if [[ ! -z "${INSTALL_REQUIRED_BIN}" ]] && [[ ! -z "${WHICH_BIN}" ]]; then
                INSTALL_RUNTIME=$("${WHICH_BIN}" "${INSTALL_REQUIRED_BIN}" || echo)
                if [[ -z "${INSTALL_RUNTIME}" ]] || [[ ! -f "${INSTALL_RUNTIME}" ]]; then
                    # Runtime for this install does not exist
                    INSTALL_MESSAGE="${CLR_RED}not found: ${INSTALL_REQUIRED_BIN}"
                else
                    # Runtime exists
                    INSTALL_MESSAGE="${CLR_GREEN}used by: ${INSTALL_RUNTIME}"
                fi
                INSTALL_MESSAGE="  [ ${INSTALL_MESSAGE}${CLR_RESET} ]"
            else
                INSTALL_MESSAGE=""
            fi

            # install time!
            echo "installing ${DST_PATH}${INSTALL_MESSAGE}"
            ln -s "${SRC_PATH}" "${DST_PATH}"
        fi
    fi
done
echo "done."

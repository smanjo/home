#!/usr/bin/env bash
set -e
set -u

# install.sh: setup user's home to my liking. has two main features:
#     [1] checks system for listed packages (see packages.lst). these packages are intended to
#         to be a baseline of packages wanted on all systems.
#     [2] creates symlinks to config files in this directory from the user's home directory.
#         will move conflicting files to .bak before linking. skips install if unable to
#         preserve existing file(s).

# keep INSTALL list updated with all files to install. Use "<file>=<binary>" syntax to
# annotate executable using the installed file.
INSTALL=(
    ".bash_profile"
    ".profile"
    ".bashrc"
    ".bash_logout"
    ".inputrc"
    ".curlrc=curl"
    ".digrc=dig"
    ".emacs=emacs"
    ".wgetrc=wget"
)

# grab some stuff from the environment.
RUN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DST_TOP="${HOME}"

# check if some commands exist (allows graceful feature loss)
if [[ -f "/usr/bin/which" ]]; then
    WHICH_BIN="/usr/bin/which"
    REALPATH_BIN=$(${WHICH_BIN} realpath)
    DPKG_BIN=$(${WHICH_BIN} dpkg)
else
    WHICH_BIN=""
    REALPATH_BIN=""
    DPKG_BIN=""
fi

# setup color codes when possible
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

# check our list of packages, if possible
if [[ ! -z "${DPKG_BIN}" ]]; then
    PKGS_FILE="${RUN_DIR}/packages.lst"
    PKGS_COUNT=$(wc -l < "${PKGS_FILE}")
    MISSING_COUNT=0
    MISSING_PKGS=""
    echo "checking ${PKGS_COUNT} packages..."
    # loop through the packages. this requires a newline at the end of the packages file.
    while IFS= read -r PKGNAME; do
        # check if package is installed. we're only trying to give bare minimal package
        # installed check, so we don't care about needed (version) uprgades.
        PKG_STATUS=$("${DPKG_BIN}" --get-selections "${PKGNAME}" 2>/dev/null \
                         | sed -E 's/^\S+\s+//')
        if [[ "${PKG_STATUS}" != "install" ]]; then
            echo "  ${CLR_RED}MISSING${CLR_RESET}   : ${PKGNAME}"
            MISSING_COUNT=$((MISSING_COUNT + 1))
            MISSING_PKGS="${MISSING_PKGS} ${PKGNAME}"
        fi
    done < "${PKGS_FILE}"
    MISSING_PKGS="${MISSING_PKGS## }"

    if [[ ${MISSING_COUNT} -eq 0 ]]; then
        echo "no missing packages."
    else
        # if missing packages, give message with install command. DO NOT INSTALL.
        # this script is intended to be lightweight and never require user input.
        echo "missing ${MISSING_COUNT} package(s), run this command to install:"
        echo
        echo "${CLR_YELLOW}sudo apt install ${MISSING_PKGS}${CLR_RESET}"
        echo
    fi
else
    echo "unable to check packages (dpkg not found)."
fi

echo "starting home setup (${#INSTALL[@]} files)..."
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
        DST_PATH="${DST_TOP}/${INSTALL_FILE}"
        # install file may contain subdirs, so get the destination dir
        DST_DIR=$(dirname "${DST_PATH}")

        if [[ -e "${DST_PATH}" ]]; then
            # when the destination exists, handle some situations
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
                    /bin/mv -f "${DST_PATH}" "${BAK_PATH}"
                    echo "...created backup of existing file:" \
                         "${CLR_YELLOW}${DST_PATH} -> ${BAK_PATH}${CLR_RESET}"
                fi
            else
                # don't try to install over non-file
                echo "ERROR, found non-file: ${DST_PATH}"
            fi
        else
            if [[ ! -e "${DST_DIR}" ]]; then
                /bin/mkdir -p "${DST_DIR}"
            fi
        fi

        if [[ ! -d "${DST_DIR}" ]]; then
            echo "ERROR: destination dir is invalid or unable to be created: ${DST_DIR}"
            echo "ERROR: skipping file: ${SRC_PATH}"
        elif [[ -e "${DST_PATH}" ]]; then
            # if the destination is (still) not clear, don't install
            echo "ERROR: destination is (still) not clear: ${DST_PATH}"
            echo "ERROR: skipping file: ${SRC_PATH}"
        else
            # Replace path with relative path, if possible
            if [[ ! -z "${REALPATH_BIN}" ]]; then
                RELATIVE_SRC=$("${REALPATH_BIN}" --relative-to="${DST_DIR}" "${SRC_PATH}")
                if [[ ! -z "${RELATIVE_SRC}" ]]; then
                    SRC_PATH="${RELATIVE_SRC}"
                fi
            fi
            # When installing files which have a required binary, add additional message
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

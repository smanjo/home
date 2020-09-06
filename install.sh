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
    echo "checking installed setup (${PKGS_COUNT} packages)..."
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

INSTALL_SUCCESS_COUNT=0
INSTALL_ERROR_COUNT=0
INSTALL_ALREADY_LINKED=0
echo "checking home setup (${#INSTALL[@]} files)..."
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

        MSG_STATUS=""
        MSG_DETAIL=""
        EXISTING_SYMLINK=""
        # if destination exists, try to move/remove (if needed)
        if [[ -e "${DST_PATH}" ]]; then
            if [[ -h "${DST_PATH}" ]]; then
                EXISTING_SYMLINK=$(readlink --canonicalize-missing \
                                            --no-newline \
                                            --silent "${DST_PATH}")
                if [[ "${EXISTING_SYMLINK}" != "${SRC_PATH}" ]]; then
                    # symlink already exists, but points somewhere unexpected: remove symlink
                    /bin/rm -f "${DST_PATH}"
                fi
            elif [[ -f "${DST_PATH}" ]]; then
                # non-symlink file already exists, so attempt backup
                BAK_PATH="${DST_PATH}.bak"
                if [[ ! -e "${BAK_PATH}" ]]; then
                    # move existing file to backup
                    /bin/mv -f "${DST_PATH}" "${BAK_PATH}"
                    MSG_DETAIL="${CLR_YELLOW}backup created: ${BAK_PATH}${CLR_RESET}"
                fi
            fi
        elif [[ ! -e "${DST_DIR}" ]]; then
            # create destination dirs if needed
            /bin/mkdir -p "${DST_DIR}"
        fi

        if [[ -h "${DST_PATH}" ]]; then
            if [[ "${EXISTING_SYMLINK}" == "${SRC_PATH}" ]]; then
                INSTALL_ALREADY_LINKED=$((INSTALL_ALREADY_LINKED + 1))
            else
                INSTALL_ERROR_COUNT=$((INSTALL_ERROR_COUNT + 1))
                MSG_STATUS="${CLR_RED}FAILED   "
                MSG_DETAIL="unable to remove destination symlink"
            fi
        elif [[ ! -d "${DST_DIR}" ]]; then
            INSTALL_ERROR_COUNT=$((INSTALL_ERROR_COUNT + 1))
            MSG_STATUS="${CLR_RED}FAILED   "
            MSG_DETAIL="unable to create destination dir"
        elif [[ -e "${DST_PATH}" ]]; then
            INSTALL_ERROR_COUNT=$((INSTALL_ERROR_COUNT + 1))
            MSG_STATUS="${CLR_RED}FAILED   "
            MSG_DETAIL="unable to move/backup destination file"
        else
            # ready to attempt install
            if [[ ! -z "${REALPATH_BIN}" ]]; then
                # replace path with relative path, if possible
                RELATIVE_SRC=$("${REALPATH_BIN}" --relative-to="${DST_DIR}" "${SRC_PATH}")
                if [[ ! -z "${RELATIVE_SRC}" ]]; then
                    SRC_PATH="${RELATIVE_SRC}"
                fi
            fi
            # when installing files which have a required binary, add additional message
            if [[ ! -z "${INSTALL_REQUIRED_BIN}" ]] && [[ ! -z "${WHICH_BIN}" ]]; then
                INSTALL_RUNTIME=$("${WHICH_BIN}" "${INSTALL_REQUIRED_BIN}" || echo)
                if [[ -z "${INSTALL_RUNTIME}" ]] || [[ ! -f "${INSTALL_RUNTIME}" ]]; then
                    # runtime for this install does not exist
                    MSG_DETAIL="${CLR_RED}not found: ${INSTALL_REQUIRED_BIN}${CLR_RESET}"
                fi
            fi

            # install time!
            ln -s "${SRC_PATH}" "${DST_PATH}"
            INSTALL_SUCCESS_COUNT=$((INSTALL_SUCCESS_COUNT + 1))
            MSG_STATUS="${CLR_GREEN}INSTALLED"
        fi

        if [[ ! -z "${MSG_STATUS}" ]]; then
            if [[ -z "${MSG_DETAIL}" ]]; then
                echo "  ${MSG_STATUS}${CLR_RESET}: ${DST_PATH}"
            else
                echo "  ${MSG_STATUS}${CLR_RESET}: ${DST_PATH} [ ${MSG_DETAIL} ]"
            fi
        fi
    fi
done

if [[ ${INSTALL_SUCCESS_COUNT} -eq 0 ]] && [[ ${INSTALL_ERROR_COUNT} -eq 0 ]]; then
    echo "home setup complete:" \
         "${INSTALL_ALREADY_LINKED} skipped (already setup)."
elif [[ ${INSTALL_ERROR_COUNT} -eq 0 ]]; then
    echo "home setup complete:" \
         "${INSTALL_SUCCESS_COUNT} newly installed," \
         "${INSTALL_ALREADY_LINKED} skipped (already setup)."
else
    echo "home setup not complete:" \
         "${INSTALL_ERROR_COUNT} failed install," \
         "${INSTALL_SUCCESS_COUNT} newly installed," \
         "${INSTALL_ALREADY_LINKED} skipped (already setup)."
fi

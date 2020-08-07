#!/usr/bin/env bash
set -e
set -u

# installs symlinks to the files in this directory which need to be installed
# in user's home directory.

# keep this list updated with all files to install
INSTALL=(
    ".bash_logout"
    ".bash_profile"
    ".bashrc"
    ".curlrc"
    ".digrc"
    ".emacs"
    ".profile"
    ".wgetrc"
)

# grab some stuff from the environment.
RUN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DST_DIR="${HOME}"

echo "starting install of ${#INSTALL[@]} files..."
for INSTALL_FILE in "${INSTALL[@]}"; do
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
                    echo "creating backup of existing file: ${DST_PATH} -> ${BAK_PATH}"
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
            # install time!
            if [[ -f "/usr/bin/which" ]]; then
                REALPATH_BIN=$( /usr/bin/which realpath )
                if [[ ! -z "${REALPATH_BIN}" ]]; then
                    RELATIVE_SRC=$( "${REALPATH_BIN}" --relative-to="${DST_DIR}" "${SRC_PATH}" )
                    if [[ ! -z "${RELATIVE_SRC}" ]]; then
                        # Replace path with relative path
                        SRC_PATH="${RELATIVE_SRC}"
                    fi
                fi
            fi
            echo "installing ${DST_PATH}"
            ln -s "${SRC_PATH}" "${DST_PATH}"
        fi
    fi
done
echo "done."

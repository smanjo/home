#!/bin/bash
set -e
set -u

RUNDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DSTDIR="${HOME}"

INSTALL=(".bashrc" ".bash_profile" ".curlrc" ".emacs" ".gitconfig" ".profile" ".wgetrc")

for f in "${INSTALL[@]}"; do
    DST_PATH="${DSTDIR}/${f}"
    SRC_PATH="${RUNDIR}/${f}"
    if [[ -e "${DST_PATH}" ]]; then
        if [[ -h "${DST_PATH}" ]]; then
            # Symlink already exists: remove symlink
            /bin/rm "${DST_PATH}"
        elif [[ -f "${DST_PATH}" ]]; then
            # Non-symlink file already exists, so attempt backup
            BAK_PATH="${DST_PATH}.bak"
            if [[ -e "${BAK_PATH}" ]]; then
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
        echo "skipping install: ${SRC_PATH}"
    else
        echo "installing ${DST_PATH}"
        ln -s "${SRC_PATH}" "${DST_PATH}"
    fi
done

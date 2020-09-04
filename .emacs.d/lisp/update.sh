#!/bin/bash
set -e
set -u

# We manually update these emacs packages so we don't have any external dependencies.
curl -OL https://raw.githubusercontent.com/fxbois/web-mode/master/web-mode.el

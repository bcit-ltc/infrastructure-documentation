#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "=== post-create start ===" | tee -a "$HOME/status"

# update the repos
# git -C /workspaces/imdb-app pull
# git -C /workspaces/webvalidate pull

echo "=== post-create complete ===" | tee -a "$HOME/status"

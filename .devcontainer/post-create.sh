#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "=== $(date +'%Y-%m-%d %H:%M:%S') post-create start ===" | tee -a "$HOME/status"

# # Enable shell completion for k3d
# source <(k3d completion bash)
# k3d completion bash > /etc/bash_completion.d/k3d

# update the repos
# git -C /workspaces/imdb-app pull
# git -C /workspaces/webvalidate pull

echo "=== $(date +'%Y-%m-%d %H:%M:%S') post-create complete ===" | tee -a "$HOME/status"

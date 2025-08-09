#!/bin/bash

echo "=== on-create start ===" | tee -a "$HOME/status"

# Set container hostname and environment variable to first 20 chars of branch name
echo "=== set container hostname ===" | tee -a "$HOME/status"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main) && SHORT_BRANCH=${BRANCH:0:20}
echo "Setting hostname and environment variable to: $SHORT_BRANCH" | tee -a "$HOME/status"
sudo hostnamectl set-hostname "$SHORT_BRANCH"
echo "export BRANCH_SHORT=\"$SHORT_BRANCH\"" | sudo tee /etc/profile.d/branch.sh > /dev/null

# Add k3d host entry
echo "127.0.0.1     registry.local" | sudo tee -a /etc/hosts > /dev/null

# only run apt upgrade on pre-build
if [ "$CODESPACE_NAME" = "null" ]
then
    apk update
    apk upgrade
    apk cache purge
fi

echo "=== on-create complete ===" | tee -a "$HOME/status"

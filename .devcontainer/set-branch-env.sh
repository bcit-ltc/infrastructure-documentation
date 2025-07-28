#!/bin/bash
# .devcontainer/set-branch-env.sh
# Set container hostname and environment variable to first 20 chars of branch name

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)
SHORT_BRANCH=${BRANCH:0:20}
echo "Setting hostname and environment variable to: $SHORT_BRANCH"
sudo hostnamectl set-hostname "$SHORT_BRANCH"
echo "export BRANCH_SHORT=\"$SHORT_BRANCH\"" | sudo tee /etc/profile.d/branch.sh > /dev/null

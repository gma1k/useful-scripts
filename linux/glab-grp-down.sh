#!/bin/bash
set -eu

GROUP_NAME="grp"
GITLAB_HOST="gitlab.host.com"
CLONE_DIR="./$GROUP_NAME"

mkdir -p "$CLONE_DIR"
cd "$CLONE_DIR" || exit

glab api "groups/$GROUP_NAME/projects?per_page=100" \
  --hostname "$GITLAB_HOST" \
  --paginate \
  | jq -r '.[].http_url_to_repo' \
  | while read -r repo; do
    echo "Cloning $repo"
    git clone "$repo"
  done

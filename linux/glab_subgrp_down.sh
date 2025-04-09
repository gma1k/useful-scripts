#!/bin/bash

clone_group_repos() {
  read -rp "Enter the full GitLab group path (e.g. grp/subgrp): " RAW_GROUP
  read -rp "Enter your GitLab hostname (e.g. gitlab.host.com): " GITLAB_HOST

  ENCODED_GROUP=$(echo "$RAW_GROUP" | sed 's|/|%2F|g')
  CLONE_DIR="./$(basename "$RAW_GROUP")"

  mkdir -p "$CLONE_DIR"
  cd "$CLONE_DIR" || exit

  echo "Fetching repositories under group: $RAW_GROUP from $GITLAB_HOST..."
  glab api "groups/$ENCODED_GROUP/projects?per_page=100" \
    --hostname "$GITLAB_HOST" \
    --paginate \
    | jq -r '.[].http_url_to_repo' \
    | while read -r repo; do
        echo "Cloning $repo"
        git clone "$repo"
      done
}

clone_group_repos

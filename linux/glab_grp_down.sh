#!/bin/bash
set -eu

clone_top_level_group_repos() {
  read -rp "Enter the GitLab group name: " GROUP_NAME
  read -rp "Enter your GitLab hostname: " GITLAB_HOST

  CLONE_DIR="./$GROUP_NAME"
  mkdir -p "$CLONE_DIR"
  cd "$CLONE_DIR" || exit

  echo "Fetching repositories under group: $GROUP_NAME from $GITLAB_HOST..."

  glab api "groups/$GROUP_NAME/projects?per_page=100" \
    --hostname "$GITLAB_HOST" \
    --paginate \
    | jq -r '.[].http_url_to_repo' \
    | while read -r repo; do
        echo "Cloning $repo"
        git clone "$repo"
      done
}

clone_top_level_group_repos

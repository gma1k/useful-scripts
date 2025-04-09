#!/bin/bash
set -eu

RAW_GROUP="grp/subgrp"
ENCODED_GROUP=$(echo "$RAW_GROUP" | sed 's/\//%2F/g')

glab api "groups/$ENCODED_GROUP/projects?per_page=100" \
  --hostname gitlab.host.com \
  --paginate \
  | jq -r '.[].http_url_to_repo' \
  | while read -r repo; do
    echo "Cloning $repo"
    git clone "$repo"
  done

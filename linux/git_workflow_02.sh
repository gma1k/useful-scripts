#!/bin/bash

#   Prompt for input if not provided
prompt_for_input() {
    if [ -z "$1" ]; then
        read -p "Enter the branch name: " branch_name
    else
        branch_name=$1
    fi

    if [ -z "$2" ]; then
        read -p "Enter the commit message: " commit_message
    else
        commit_message=$2
    fi
}

# Switch to the specified branch
switch_branch() {
    git checkout "$branch_name"
}

# Function to check for changes
check_changes() {
    if [[ -n $(git status --porcelain) ]]; then
        echo "There are changes to commit."
        return 0
    else
        echo "No changes to commit."
        return 1
    fi
}

# Commit changes
commit_changes() {
    git add .
    git commit -m "$commit_message"
}

# Push changes
push_changes() {
    git push origin "$branch_name"
}

# Main script
prompt_for_input "$1" "$2"
switch_branch
if check_changes; then
    commit_changes
    push_changes
else
    echo "No changes to commit and push."
fi

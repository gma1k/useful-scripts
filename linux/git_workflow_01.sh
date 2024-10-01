#!/bin/bash

# Switch to the specified branch
switch_branch() {
    read -p "Enter the branch you want to switch to: " branch
    git checkout "$branch"
}

# Check for changes
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
    read -p "Enter your commit message: " commit_message
    git add .
    git commit -m "$commit_message"
}

# Push changes
push_changes() {
    read -p "Enter the branch you want to push to: " branch
    git push origin "$branch"
}

# Main script
switch_branch
if check_changes; then
    commit_changes
    push_changes
else
    echo "No changes to commit and push."
fi

#!/bin/bash
set -eu

# Add files to git
git_add() {
    echo "Adding all changes to git..."
    git add . 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add files."
        exit 1
    else
        echo "Files successfully added."
    fi
}

# Commit changes
git_commit() {
    read -p "Enter a commit message: " commit_message
    if [ -z "$commit_message" ]; then
        echo "Error: Commit message cannot be empty."
        exit 1
    fi

    git commit -m "$commit_message" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Commit failed."
        exit 1
    else
        echo "Commit successful."
    fi
}

# Push changes to the repository
git_push() {
    echo "Pushing changes to the remote repository..."
    git push 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Push failed."
        exit 1
    else
        echo "Push successful."
    fi
}

# Main script
echo "Start pushing to the git repository..."

git_add
git_commit
git_push

echo "All operations completed successfully."

#!/bin/bash

clone_repo() {
  read -p "Enter the git repository URL: " repo
  echo "Cloning the repository $repo"
  git clone $repo
}

create_branch() {
  read -p "Enter the branch name: " branch
  echo "Creating a new branch $branch from main"
  git checkout main
  git pull
  git checkout -b $branch origin/main
}

rename_dir() {
  read -p "Enter the old directory name: " old_dir
  read -p "Enter the new directory name: " new_dir
  echo "Renaming the directory $old_dir to $new_dir"
  mv -r $old_dir $new_dir
}

rename_file() {
  read -p "Enter the old file name: " old_file
  read -p "Enter the new file name: " new_file
  echo "Renaming the file $old_file to $new_file using git mv"
  git mv $old_file $new_file
}

add_changes() {
  # Check if there are any changes to be staged
  if [ -n "$(git status --porcelain)" ]; then
    echo "Staging the changes with git add"
    git add .
  else
    echo "No changes to be staged"
  fi  
}

push_changes() {
  read -p "Enter the commit message: " message
  echo "Committing and pushing the changes with message '$message'"
  git commit -m "$message"
  git push origin $branch
}

main() {
  # Ask the user if cloning the repo is needed
  read -p "Do you need to clone the repo? (y/n): " answer
  # If yes, call clone_repo function
  if [ "$answer" == "y" ]; then
    clone_repo
  fi
  create_branch
  rename_dir
  rename_file 
  add_changes 
  push_changes
}

main

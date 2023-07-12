#!/bin/bash

# This script assigns a userrole in an organization and space in Cloud Foundry.

# Get username.
echo "Enter the username:"
read USERNAME

# Change $ORG to your org
ORG_NAME="$ORG"

# Display a list of roles.
echo "Choose the role you want to assign:"
echo "1. SpaceDeveloper - Can manage spaces and applications."
echo "2. SpaceManager - Can manage spaces, applications, and services."
echo "3. SpaceAuditor - Can view spaces, applications, and services."
read ROLE

# Assign the chosen role.
if [ $ROLE -eq 1 ]
then
  ROLE_NAME="SpaceDeveloper"
elif [ $ROLE -eq 2 ]
then
  ROLE_NAME="SpaceManager"
elif [ $ROLE -eq 3 ]
then
  ROLE_NAME="SpaceAuditor"
else
  echo "Invalid choice."
  exit 1
fi

# Ask user to assign permissions.
echo "Choose the space for which you want to assign the permission or choose All:"
echo "1. All spaces"
echo "2. Choose a space"
read SPACE_CHOICE

# If user choice all spaces
if [ $SPACE_CHOICE -eq 1 ]
then
  cf set-org-role $USERNAME $ORG_NAME OrgManager

  for SPACE_NAME in $(cf spaces | awk '{print $1}')
  do
    cf set-space-role $USERNAME $SPACE_NAME $ORG_NAME $ROLE_NAME
    echo "Assigning $ROLE_NAME role to $USERNAME in space $SPACE_NAME of organization $ORG_NAME..."
  done

elif [ $SPACE_CHOICE -eq 2 ]
then
  echo "Choose the space for which you want to assign the permissions:"
  cf spaces

  read SPACE_NAME

  cf set-space-role $USERNAME $SPACE_NAME $ORG_NAME $ROLE_NAME
  echo "Assigning $ROLE_NAME role to $USERNAME in space $SPACE_NAME of organization $ORG_NAME..."

else
  echo "Invalid choice."
  exit 1
fi

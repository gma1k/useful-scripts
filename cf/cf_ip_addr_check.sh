#!/bin/bash

# Ask for the username and password
read -p "Enter your username: " user_name
read -s -p "Enter your password: " password

# Login to Cloud Foundry
cf login -a <URL> -u $user_name -p $password --skip-ssl-validation

# Get a list of orgs
orgs=$(cf orgs | tail -n +4)

# Loop over each org
for org in $orgs; do
  # Target the org
  cf target -o $org

  # Get a list of all spaces in the org
  spaces=$(cf spaces | tail -n +4)

  # Loop over each space
  for space in $spaces; do
    # Target the space
    cf target -s $space

    # Get a list of all apps in the space
    apps=$(cf apps | tail -n +4 | awk '{print $1}')

    # Loop over each app
    for app in $apps; do
      # Set the app name variable
      APP_NAME=$app

      # Get the url of the app
      APP_URL=$(cf curl /v2/apps?q=name:$APP_NAME | grep \"url\" | awk '{ print $2 }' | cut -c2-46)

      # Get the host of the app
      export APP_HOST=$(cf curl $APP_URL/stats | grep host | awk '{ print $2}' | cut -c 2-)

      # Print the org, space, app name and IP address
      echo "$org $space $app $APP_HOST"
      echo "$org $space $app $APP_HOST" | tee -a output.txt
    done
  done
done

# Logout from Cloud Foundry
cf logout

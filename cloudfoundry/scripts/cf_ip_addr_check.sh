#!/bin/bash

read -p "Enter your username: " user_name
read -s -p "Enter your password: " password

cf login -a <URL> -u $user_name -p $password --skip-ssl-validation

orgs=$(cf orgs | tail -n +4)

for org in $orgs; do
  cf target -o $org

  spaces=$(cf spaces | tail -n +4)

  for space in $spaces; do
    cf target -s $space

    apps=$(cf apps | tail -n +4 | awk '{print $1}')

    for app in $apps; do
      APP_NAME=$app

      APP_URL=$(cf curl /v2/apps?q=name:$APP_NAME | grep \"url\" | awk '{ print $2 }' | cut -c2-46)

      export APP_HOST=$(cf curl $APP_URL/stats | grep host | awk '{ print $2}' | cut -c 2-)

      echo "$org $space $app $APP_HOST"
      echo "$org $space $app $APP_HOST" | tee -a output.txt
    done
  done
done

cf logout

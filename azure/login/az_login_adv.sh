#!/bin/bash

login_user() {
  az login
  az account show > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Login failed. Please check your credentials and try again."
    exit 1
  fi
}

login_sp() {
  read -p "Enter the service principal name: " sp_name
  read -sp "Enter the service principal password: " sp_password
  echo

  az ad sp create-for-rbac --name $sp_name --password $sp_password

  sp_id=$(az ad sp show --id http://$sp_name --query appId --output tsv)
  tenant_id=$(az account show --query tenantId --output tsv)

  read -p "Do you need to provide the service principal credentials (y/n)? " choice

  if [ "$choice" = "y" ]; then
    read -p "How do you want to provide the service principal credentials? (i) Input (f) File: " choice

    if [ "$choice" = "i" ]; then
      read -p "Enter the resource group: " rg
      read -p "Enter the username: " un
      read -sp "Enter the password: " pw
      echo
      read -p "Enter the tenant: " tn

      az configure --defaults group=$rg
      az configure --defaults username=$un
      az configure --defaults password=$pw
      az configure --defaults tenant=$tn

    elif [ "$choice" = "f" ]; then
      read -p "Enter the file name and path: " file

      source $file

    else
      echo "Invalid choice. Please enter i or f."
      exit 1
    fi

  elif [ "$choice" = "n" ]; then
    echo "OK, no need to provide the service principal credentials."

  else
    echo "Invalid choice. Please enter y or n."
    exit 1
  fi

  az account show > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Login failed. Please check your credentials and try again."
    exit 1
  fi

}

while true; do
   read -p "How do you want to login? (ua) User account (sp) Service principal (q) Quit: " choice

   if [ "$choice" = "ua" ]; then
     login_user

   elif [ "$choice" = "sp" ]; then
     login_sp

   elif [ "$choice" = "q" ]; then
     echo "Bye, Bye!"
     break

   else
     echo "Invalid choice. Please enter ua, sp or q."
   fi

done

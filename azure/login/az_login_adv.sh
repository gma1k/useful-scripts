# A function to login user account
login_user() {
  az login
  az account show > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Login failed. Please check your credentials and try again."
    exit 1
  fi
}

# A function to login service principal
login_sp() {
  read -p "Enter the service principal name: " sp_name
  read -sp "Enter the service principal password: " sp_password
  echo

  # Create a service principal
  az ad sp create-for-rbac --name $sp_name --password $sp_password

  # Get the service principal ID and tenant ID
  sp_id=$(az ad sp show --id http://$sp_name --query appId --output tsv)
  tenant_id=$(az account show --query tenantId --output tsv)

  # Ask the user to provide the service principal credentials if needed
  read -p "Do you need to provide the service principal credentials (y/n)? " choice

  # Ask how to provide: input or a file
  if [ "$choice" = "y" ]; then
    read -p "How do you want to provide the service principal credentials? (i) Input (f) File: " choice

    if [ "$choice" = "i" ]; then
      read -p "Enter the resource group: " rg
      read -p "Enter the username: " un
      read -sp "Enter the password: " pw
      echo
      read -p "Enter the tenant: " tn

      # Configure the service principal credentials
      az configure --defaults group=$rg
      az configure --defaults username=$un
      az configure --defaults password=$pw
      az configure --defaults tenant=$tn

    elif [ "$choice" = "f" ]; then
      read -p "Enter the file name and path: " file

      # Configure the service principal credentials
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

# A loop how to login
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

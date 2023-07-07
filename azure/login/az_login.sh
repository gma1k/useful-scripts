# A function to login with a user account
login_user() {
  az login
}

# A function to login with a service principal
login_sp() {
  read -p "Enter the service principal name: " sp_name
  read -sp "Enter the service principal password: " sp_password
  echo

  # Create a service principal
  az ad sp create-for-rbac --name $sp_name --password $sp_password

  # Get the service principal ID and tenant ID
  sp_id=$(az ad sp show --id http://$sp_name --query appId --output tsv)
  tenant_id=$(az account show --query tenantId --output tsv)

  # Configure the service principal credentials
  az configure --defaults group=MyResourceGroup
  az configure --defaults username=$sp_id
  az configure --defaults password=$sp_password
  az configure --defaults tenant=$tenant_id
}

# Start a loop
while true; do
  read -p "How do you want to login? (ua) User account (sp) Service principal (q) Quit: " choice

  if [ "$choice" = "ua" ]; then
    login_user

  elif [ "$choice" = "sp" ]; then
    login_sp

  elif [ "$choice" = "q" ]; then
    break

  else
    echo "Invalid choice. Please enter ua, sp or q."
  fi

done

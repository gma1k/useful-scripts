#!/bin/bash

echo "Enter the organization name:"
read org_name

echo "Enter the space name:"
read space_name

echo "Enter the username:"
read username

echo "Enter the password:"
read -s password

echo "Enter the vault name:"
read vault_name

wget https://releases.hashicorp.com/vault-plugin-auth-cf/0.3.0/vault-plugin-auth-cf_0.3.0_linux_amd64.zip
unzip vault-plugin-auth-cf_0.3.0_linux_amd64.zip
vault write sys/plugins/catalog/auth/cf \
    sha_256=$(sha256sum vault-plugin-auth-cf | cut -d' ' -f1) \
    command="vault-plugin-auth-cf"
vault auth enable -path=cf -plugin-name=cf auth/cf
vault write auth/cf/config \
    cf_api_addr=https://api.example.com \
    cf_ca_cert=@/path/to/ca/cert.pem

cf create-user $vault_name some-password
cf set-org-role $vault_name $org_name OrgAuditor
cf set-space-role $vault_name $org_name $space_name SpaceAuditor

cat <<EOF > my-policy.hcl
path "cf/$org_name/$space_name/*" {
  capabilities = ["read"]
}
EOF
vault policy write my-policy my-policy.hcl
vault write auth/cf/role/my-role \
    bound_app_id=<your app id> \
    bound_space_id=<your space id> \
    bound_organization_id=<your org id> \
    policies=my-policy \
    ttl=1h

# Create a secret engine in Vault to store your username and password credentials
vault secrets enable -path=cf -version=2 kv
vault kv put cf/$org_name/$space_name username=$username password=$password

# Set up a credential manager in Concourse to connect to Vault
vault token create -policy=my-policy -ttl=24h > token.txt
export VAULT_ADDR=https://vault.example.com
export VAULT_AUTH_BACKEND=token
export CONCOURSE_VAULT_CLIENT_TOKEN=$(cat token.txt | grep token | cut -d' ' -f2)
export CONCOURSE_VAULT_PATH_PREFIX=/cf

# Rewrite your pipeline YAML file to use HashiCorp Vault for your username and password credentials
cat <<EOF > pipeline.yml
# Define the resources
resources:
- name: cf
  type: cf
  source:
    api: << change this to your Cloud Foundry API endpoint >>
    username: ((vault:secrets/$org_name/$space_name/username)) # Replace with your Cloud Foundry username from Vault
    password: ((vault:secrets/$org_name/$space_name/password)) # Replace with your Cloud Foundry password from Vault
    organization: $org_name # Replace with your Cloud Foundry organization name from user input
    space: $space_name # Replace with your Cloud Foundry space name from user input

# Define the jobs
jobs:
- name: check-all-apps
  plan:
  - get: cf # Get the cf resource

  - task: check-java-version-in-apps # Run a custom task to check the Java version in each app
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: governmentpaas/cf-cli # Use an image with cf CLI installed
      run:
        path: bash # Use bash to run the commands
        args:
        - -c # Use the -c option to pass a command string
        - | # Use the | character to start a multi-line command string
          cf api ((cf-api)) --skip-ssl-validation # Connect to the Cloud Foundry API endpoint and skip SSL validation (use --ca-cert instead for production)
          cf auth ((vault:secrets/$org_name/$space_name/username)) ((vault:secrets/$org_name/$space_name/password)) # Authenticate with the Cloud Foundry username and password from Vault (use a credential manager for production)
          cf target -o $org_name -s $space_name # Target the Cloud Foundry organization and space from user input

          # Get the apps in the space and their buildpacks as JSON
          apps=$(cf curl "/v3/apps?space_guids=$(cf space $space_name --guid)&fields[buildpacks]=name")

          # Loop through each app in the JSON output
          for app in $(echo "$apps" | jq -r '.resources[] | @base64'); do
            _jq() {
              echo ${app} | base64 --decode | jq -r ${1}
            }

            app_name=$(_jq '.name') # Get the app name
            app_buildpack=$(_jq '.lifecycle.data.buildpacks[0]') # Get the app buildpack name

            echo "App name: $app_name" # Print the app name
            echo "App buildpack: $app_buildpack" # Print the app buildpack name

            if [[ $app_buildpack == *java* ]]; then # Check if the app buildpack contains "java"
              echo "App is using Java" # Print that the app is using Java

              # Run a cf ssh command to get into the app container and run java -version
              java_version=$(cf ssh $app_name -c "JAVA_HOME=.java-buildpack/open_jdk_jre java -version 2>&1")

              echo "Java version:" # Print Java version
              echo "$java_version" # Print the output of java -version

            else
              echo "App is not using Java" # Print that the app is not using Java
            fi

            echo "" # Add a blank line for readability
          done

EOF

# Upload your pipeline YAML file to Concourse with fly set-pipeline command
fly -t $space_name set-pipeline -p check-all-apps -c pipeline.yml

#!/bin/bash

create_cluster() {
  # Ask for user input
  echo "Please enter the following values separated by commas:"
  echo "Cluster name, region, node type"
  read -p "-> " input

  # Split the input by commas
  IFS=',' read -r cluster region node <<< "$input"

  # Check if the input is valid
  if [ -z "$cluster" ] || [ -z "$region" ] || [ -z "$node" ]; then
    echo "Invalid input format"
    exit 1
  fi

  # Create a cluster with the given parameters
  echo "Creating cluster..."
  aws eks create-cluster --name "$cluster" --region "$region" --nodegroup-name "$cluster-nodes" --node-type "$node" --nodes 2

  # Print the result
  echo "Cluster created: $cluster"
}

delete_cluster() {
  # Ask for user input
  echo "Please enter the following values separated by commas:"
  echo "Cluster name, region"
  read -p "-> " input

  # Split the input by commas
  IFS=',' read -r cluster region <<< "$input"

  # Check if the input is valid
  if [ -z "$cluster" ] || [ -z "$region" ]; then
    echo "Invalid input format"
    exit 1
  fi

  # Delete a cluster with the given parameters
  echo "Deleting cluster..."
  aws eks delete-cluster --name "$cluster" --region "$region"

  # Print the result
  echo "Cluster deleted: $cluster"
}

# Ask for user option
echo "Please choose an option:"
echo "1) Create a cluster"
echo "2) Delete a cluster"
read -p "-> " option

# Call the corresponding function based on the option
case $option in
  1) create_cluster ;;
  2) delete_cluster ;;
  *) echo "Invalid option" ;;
esac

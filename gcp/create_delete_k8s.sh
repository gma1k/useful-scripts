#!/bin/bash

create_cluster() {
  # Ask for user input
  echo "Please enter the following values separated by commas:"
  echo "Project ID, cluster name, zone, number of nodes"
  read -p "-> " input

  # Split the input by commas
  IFS=',' read -r project cluster zone nodes <<< "$input"

  # Check if the input is valid
  if [ -z "$project" ] || [ -z "$cluster" ] || [ -z "$zone" ] || [ -z "$nodes" ]; then
    echo "Invalid input format"
    exit 1
  fi

  # Create a cluster with the given parameters
  echo "Creating cluster..."
  gcloud container clusters create "$cluster" --project "$project" --zone "$zone" --num-nodes "$nodes" --quiet

  # Print the result
  echo "Cluster created: $cluster"
}

delete_cluster() {
  # Ask for user input
  echo "Please enter the following values separated by commas:"
  echo "Project ID, cluster name, zone"
  read -p "-> " input

  # Split the input by commas
  IFS=',' read -r project cluster zone <<< "$input"

  # Check if the input is valid
  if [ -z "$project" ] || [ -z "$cluster" ] || [ -z "$zone" ]; then
    echo "Invalid input format"
    exit 1
  fi

  # Delete a cluster with the given parameters
  echo "Deleting cluster..."
  gcloud container clusters delete "$cluster" --project "$project" --zone "$zone" --quiet

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

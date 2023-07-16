#!/bin/bash

set -e

options=("List recent builds" "Stream logs of a job" "Connect to a container" "Check for new versions of a resource" "Validate pipeline configuration" "Run a local task file")

echo "Please choose one of the following options:"
for i in "${!options[@]}"; do
  echo "$((i+1))) ${options[$i]}"
done

read -p "Enter your choice: " choice

if [[ $choice -lt 1 || $choice -gt ${#options[@]} ]]; then
  echo "Invalid choice. Please enter a number between 1 and ${#options[@]}."
  exit 1
fi

case $choice in
  1)
    fly builds -t <target-name> || { echo "Failed to list recent builds. Please check your target name and connection."; exit 1; }
    ;;
  2)
    read -p "Enter the pipeline name: " pipeline_name
    read -p "Enter the job name: " job_name
    fly watch -t <target-name> -j $pipeline_name/$job_name || { echo "Failed to stream logs of $job_name. Please check your pipeline name, job name and connection."; exit 1; }
    ;;
  3)
    read -p "Enter the pipeline name: " pipeline_name
    read -p "Enter the job name: " job_name
    fly intercept -t <target-name> -j $pipeline_name/$job_name || { echo "Failed to connect to a container. Please check your pipeline name, job name and connection."; exit 1; }
    ;;
  4)
    read -p "Enter the pipeline name: " pipeline_name
    read -p "Enter the resource name: " resource_name
    fly check-resource -t <target-name> -r $pipeline_name/$resource_name || { echo "Failed to check for new versions of $resource_name. Please check your pipeline name, resource name and connection."; exit 1; }
    ;;
  5)
    read -p "Enter the pipeline file: " pipeline_file
    fly validate-pipeline -t <target-name> -c $pipeline_file || { echo "Failed to validate pipeline configuration. Please check your target name, pipeline file and connection."; exit 1; }
    ;;
  6)
    read -p "Enter the task file: " task_file
    fly execute -t <target-name> -c $task_file || { echo "Failed to run local task file. Please check your target name, task file and connection."; exit 1; }
    ;;
esac

echo "Command executed successfully."

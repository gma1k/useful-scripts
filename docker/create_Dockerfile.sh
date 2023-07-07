#!/bin/bash

# Valid dockerfile check
check_input() {
  # Use a case statement to match the user input with the possible dockerfile instructions
  case $1 in
    FROM|COPY|RUN|CMD)
      # If the user input is valid, return 0 (success)
      return 0
      ;;
    *)
      # If the user input is invalid, return 1 (failure)
      return 1
      ;;
  esac
}

# A function to build a docker image from the dockerfile
build_image() {
  read -p "Enter the image name: " image_name
  docker build -t $image_name -f Dockerfile .
  if [ $? -eq 0 ]; then
    echo "Docker image $image_name built successfully."
    exit 0
  else
    echo "Docker build failed."
    read -p "Do you want to try again? (y/n): " answer
    if [ $answer = "y" ]; then
      build_image
    else
      exit 1
    fi
  fi
}

# Create empty dockerfile
echo "" > Dockerfile

# Ask for HTTP_PROXY value
read -p "Enter the HTTP_PROXY value or leave empty to skip: " http_proxy

case $http_proxy in
  "")
    echo "Skipping HTTP_PROXY."
    ;;
  *)
    echo "ENV HTTP_PROXY $http_proxy" > Dockerfile
    ;;
esac

# HTTPS_PROXY value
read -p "Enter the HTTPS_PROXY value or leave empty to skip: " https_proxy

case $https_proxy in
  "")
    echo "Skipping HTTPS_PROXY."
    ;;
  *)
    echo "ENV HTTPS_PROXY $https_proxy" >> Dockerfile
    ;;
esac

# Dockerfile instructions
while true; do
  read -p "Enter a dockerfile instruction or 'done' to finish: " instruction
  if [ $instruction = "done" ]; then
    echo "Dockerfile completed."
    read -p "Do you want to build the image? (y/n): " choice
    case $choice in
      y)
        build_image
        ;;
      n)
        echo "You can build the image later with 'docker build -t <image_name> -f Dockerfile .'"
        exit 0
        ;;
      *)
        echo "Invalid choice. Please enter y or n."
        exit 1
        ;;
    esac
  else
    check_input $instruction
    if [ $? -eq 0 ]; then
      read -p "Enter the arguments for $instruction: " arguments
      echo "$instruction $arguments" >> Dockerfile
    else
      echo "Invalid instruction. Please enter one of FROM, COPY, RUN, or CMD."
      continue
    fi
  fi
done

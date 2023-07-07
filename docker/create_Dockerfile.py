#!/usr/bin/env python3
# chmod +x create_Dockerfile.py
# Usage: ./create_Dockerfile.py
# Optional arguments for HTTP_PROXY and HTTPS_PROXY values
# Usage: ./create_dockerfile.py --http-proxy http://proxy.example.com:8080 --https-proxy https://proxy.example.com:8080

# Import subprocess and argparse modules
import subprocess
import argparse

# A function to check the user input
def check_input(instruction):
    valid_instructions = ["FROM", "COPY", "RUN", "CMD"]
    return instruction in valid_instructions

# A function to build a docker image from the dockerfile
def build_image(image_name):
    result = subprocess.run(["docker", "build", "-t", image_name, "-f", "Dockerfile", "."])
    if result.returncode == 0:
        print(f"Docker image {image_name} built successfully.")
        exit(0)
    else:
        print("Docker build failed.")
        answer = input("Do you want to try again? (y/n): ")
        if answer == "y":
            build_image(image_name)
        else:
            exit(1)

# Create an empty dockerfile
with open("Dockerfile", "w") as f:
    f.write("")

# Create an argument parser object
parser = argparse.ArgumentParser(description="Create a dockerfile and build a docker image")

# Add arguments for HTTP_PROXY and HTTPS_PROXY values
parser.add_argument("--http-proxy", help="set HTTP_PROXY value")
parser.add_argument("--https-proxy", help="set HTTPS_PROXY value")

# Parse the arguments
args = parser.parse_args()

# Check if HTTP_PROXY argument is defined
if args.http_proxy:
    with open("Dockerfile", "a") as f:
        f.write(f"ENV HTTP_PROXY {args.http_proxy}\n")

# Check if HTTPS_PROXY argument is defined
if args.https_proxy:
    with open("Dockerfile", "a") as f:
        f.write(f"ENV HTTPS_PROXY {args.https_proxy}\n")

# Dockerfile instructions
while True:
    instruction = input("Enter a dockerfile instruction or 'done' to finish: ")
    if instruction == "done":
        print("Dockerfile completed.")
        choice = input("Do you want to build the image? (y/n): ")
        if choice == "y":
            image_name = input("Enter the image name: ")
            build_image(image_name)
        elif choice == "n":
            print("You can build the image later with 'docker build -t <image_name> -f Dockerfile .'")
            exit(0)
        else:
            print("Invalid choice. Please enter y or n.")
            exit(1)
    else:
        if check_input(instruction):
            arguments = input(f"Enter the arguments for {instruction}: ")
            with open("Dockerfile", "a") as f:
                f.write(f"{instruction} {arguments}\n")
        else:
            print("Invalid instruction. Please enter one of FROM, COPY, RUN, or CMD.")
            continue

import os
import subprocess

def create_cluster():
  # Ask for user input
  print("Please enter the following values separated by commas:")
  print("Project ID, cluster name, zone, number of nodes")
  input = input("-> ")

  # Split the input by commas
  values = input.split(",")
  if len(values) != 4:
    print("Invalid input format")
    exit(1)

  # Assign the values to variables
  project = values[0]
  cluster = values[1]
  zone = values[2]
  nodes = values[3]

  # Create a cluster with the given parameters
  print("Creating cluster...")
  subprocess.run(["gcloud", "container", "clusters", "create", cluster, "--project", project, "--zone", zone, "--num-nodes", nodes, "--quiet"])

  # Print the result
  print(f"Cluster created: {cluster}")

def delete_cluster():
  # Ask for user input
  print("Please enter the following values separated by commas:")
  print("Project ID, cluster name, zone")
  input = input("-> ")

  # Split the input by commas
  values = input.split(",")
  if len(values) != 3:
    print("Invalid input format")
    exit(1)

  # Assign the values to variables
  project = values[0]
  cluster = values[1]
  zone = values[2]

  # Delete a cluster with the given parameters
  print("Deleting cluster...")
  subprocess.run(["gcloud", "container", "clusters", "delete", cluster, "--project", project, "--zone", zone, "--quiet"])

  # Print the result
  print(f"Cluster deleted: {cluster}")

# Ask for user option
print("Please choose an option:")
print("1) Create a cluster")
print("2) Delete a cluster")
option = input("-> ")

# Call the corresponding function based on the option
if option == "1":
  create_cluster()
elif option == "2":
  delete_cluster()
else:
  print("Invalid option")

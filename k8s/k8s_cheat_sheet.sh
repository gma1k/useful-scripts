# A bash script to generate a kubernetes cheat sheet

#!/bin/bash

# Define some variables
KUBECTL="kubectl"
CHEAT_SHEET="k8s-cheat-sheet.txt"
RESOURCES=("pod" "deployment" "service" "configmap" "secret" "ingress" "node" "namespace")
OPERATIONS=("get" "describe" "create" "delete" "edit" "apply" "logs" "exec")

# Create a cheat sheet file
echo "# Kubernetes Cheat Sheet" > $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

# Ask the user for the cluster name and context
read -p "Enter the cluster name: " CLUSTER_NAME
read -p "Enter the context name: " CONTEXT_NAME

# Set the cluster and context in the cheat sheet
echo "## Cluster and Context" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET
echo "\`\`\`bash" >> $CHEAT_SHEET
echo "# Set the cluster entry in the kubeconfig" >> $CHEAT_SHEET
echo "$KUBECTL config set-cluster $CLUSTER_NAME --server=<server-url> --certificate-authority=<ca-file>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET
echo "# Set the user entry in the kubeconfig" >> $CHEAT_SHEET
echo "$KUBECTL config set-credentials <user-name> --client-certificate=<cert-file> --client-key=<key-file>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET
echo "# Set the context entry in the kubeconfig" >> $CHEAT_SHEET
echo "$KUBECTL config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=<user-name> --namespace=<namespace>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET
echo "# Use the context" >> $CHEAT_SHEET
echo "$KUBECTL config use-context $CONTEXT_NAME" >> $CHEAT_SHEET
echo "\`\`\`" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

# Loop through the resources and operations and generate commands for each combination
for RESOURCE in "${RESOURCES[@]}"; do
  echo "## Resource: $RESOURCE" >> $CHEAT_SHEET
  echo "" >> $CHEAT_SHEET
  for OPERATION in "${OPERATIONS[@]}"; do
    echo "### Operation: $OPERATION" >> $CHEAT_SHEET
    echo "" >> $CHEAT_SHEET
    echo "\`\`\`bash" >> $CHEAT_SHEET

    # Generate different commands based on the operation type
    case "$OPERATION" in

      # Get commands
      get)
        echo "# Get all ${RESOURCE}s in the current namespace" >> $CHEAT_SHEET
        echo "$KUBECTL get $RESOURCE" >> $CHEAT_SHEET
        echo "" >> $CHEAT_SHEET

        echo "# Get all ${RESOURCE}s in all namespaces" >> $CHEAT_SHEET
        echo "$KUBECTL get $RESOURCE --all-namespaces" >> $CHEAT_SHEET
        echo "" >> $CHEAT_SHEET

        echo "# Get a specific ${RESOURCE} by name in the current namespace" >> $CHEAT_SHEET
        echo "$KUBECTL get $RESOURCE <name>" >> $CHEAT_SHEET
        echo "" >> $CHEAT_SHEET

        echo "# Get a specific ${RESOURCE} by name in a specific namespace" >> $CHEAT_SHEET
        echo "$KUBECTL get -n <namespace> <name>" >> $CHEAT_SHEET
        ;;

      # Describe commands  
      describe)
        echo "# Describe all ${RESOURCE}s in the current namespace" >> $CHEAT_SHEET
        echo "$KUBECTL describe $RESOURCE" >> $CHEAT_SHEET
        echo "" >> $CHEAT_SHEET

        echo "# Describe all ${RESOURCE}s in all namespaces" >> $CHEAT_SHEET
        echo "$KUBECTL describe -A <name>" >> $CHEAT_SHEET 
        echo "" >>$ CHEATSHEETS

        echo "# Describe a specific ${RESOURCE} by name in the current namespace" >>$ CHEATSHEETS 
        echo "$KUBECTL describe <name>"  >$ CHEATSHEETS 
        echo "" >$ CHEATSHEETS 

        echo "# Describe a specific ${RESOURCE} by name in a specific namespace" >$ CHEATSHEETS 
        echo "$KUBECTL describe -n <namespace> <name>" >$ CHEATSHEETS 
        ;;

      # Create commands
      create)
        echo "# Create a ${RESOURCE} from a YAML file in the current namespace" >> $CHEAT_SHEET
        echo "$KUBECTL create -f <file.yaml>" >> $CHEAT_SHEET
        echo "" >> $CHEAT_SHEET

        echo "# Create a ${RESOURCE} from a YAML file in a specific namespace" >> $CHEAT_SHEET
        echo "$KUBECTL create -n <namespace> -f <file.yaml>" >> $CHEAT_SHEET
        echo "" >> $CHEAT_SHEET

        echo "# Create a ${RESOURCE} from a JSON file in the current namespace" >> $CHEAT_SHEET
        echo "$KUBECTL create -f <file.json>" >> $CHEAT_SHEET
        echo "" >> $CHEAT_SHEET

        echo "# Create a ${RESOURCE} from a JSON file in a specific namespace" >> $CHEAT_SHEET
        echo "$KUBECTL create -n <namespace> -f <file.json>" >> $CHEAT_SHEET
        ;;

      # Delete commands
      delete)
        echo "# Delete all ${RESOURCE}s in the current namespace" >> $CHEAT_SHEET
        echo "$KUBECTL delete $RESOURCE --all" >> $CHEAT_SHEET
        echo "" >> $CHEAT_SHEET

        echo "# Delete all ${RESOURCE}s in all namespaces" >> $CHEAT_SHEET
        echo "$KUBECTL delete -A <name>" >> $CHEAT_SHEET 
        echo "" >$ CHEATSHEETS 

        echo "# Delete a specific ${RESOURCE} by name in the current namespace" >$ CHEATSHEETS 
        echo "$KUBECTL delete <name>"  >$ CHEATSHEETS 
        echo "" >$ CHEATSHEETS 

        echo "# Delete a specific ${RESOURCE} by name in a specific namespace" >$ CHEATSHEETS 
        echo "$KUBECTL delete -n <namespace> <name>" >$ CHEATSHEETS 
        ;;

      # Edit commands
      edit)
        echo "# Edit a ${RESOURCE} by name in the current namespace using the default editor" >> $CHEAT_SHEET
        echo "$KUBECTL edit $RESOURCE <name>" >> $CHEAT_SHEET
        echo "" >> $CHEAT_SHEET

        echo "# Edit a ${RESOURCE} by name in the current namespace using a specific editor" >> $CHEAT_SHEET
        echo "EDITOR=<editor> kubectl edit $RESOURCE <name>" >> $CHEAT_SHEET
        echo "" >> $CHEAT_SHEET

        echo "# Edit a ${RESOURCE} by name in a specific namespace using the default editor" >> $CHEAT_SHEET
        echo "$KUBECTL edit -n <namespace> <name>" >> $CHEAT_SHEET
        ;;

      # Apply commands
      apply)
        echo "# Apply changes to a ${RESOURCE} from a YAML file in the current namespace" >> $CHEAT_SHEET
        echo "$KUBECTL apply -f <file.yaml>" >> $CHEAT_SHEET
        echo "" >> $CHEAT_SHEET

        echo "# Apply changes to a ${RESOURCE} from a YAML file in a specific namespace" >> $CHEAT_SHEET
        echo "$KUBECTL apply -n <namespace> -f <file.yaml>" >> $CHEAT_SHEET
        ;;

      # Logs commands
      logs)
        if [ "$RESOURCE" == "pod" ]; then # Logs only work for pods and containers

          # Ask the user if they want to follow the logs or not
          read -p "Do you want to follow the logs? (y/n): " FOLLOW

          if [ "$FOLLOW" == "y" ]; then # Follow the logs

            # Ask the user if they want to specify a container or not
            read -p "Do you want to specify a container? (y/n): " CONTAINER

            if [ "$CONTAINER" == "y" ]; then # Specify a container

              # Ask the user for the container name
              read -p "Enter the container name: " CONTAINER_NAME

              # Generate commands for following logs of a specific container in a pod
              echo "# Follow the logs of a specific container in a pod by name in the current namespace" >> $CHEAT_SHEET
              echo "$KUBECTL logs -f <pod-name> -c $CONTAINER_NAME" >> $CHEAT_SHEET
              echo "" >> $CHEAT_SHEET

              echo "# Follow the logs of a specific container in a pod by name in a specific namespace" >> $CHEAT_SHEET
              echo "$KUBECTL logs -n <namespace> -f <pod-name> -c $CONTAINER_NAME" >> $CHEAT_SHEET
              echo "" >> $CHEAT_SHEET
              
              # Follow the logs of a specific container in a pod by name in a specific namespace" >> $CHEAT_SHEET
              echo "$KUBECTL logs -n <namespace> -f <pod-name> -c $CONTAINER_NAME" >> $CHEAT_SHEET
              echo "" >> $CHEAT_SHEET

              else

             # Generate commands for following logs of a pod by name
             echo "# Follow the logs of a pod by name in the current namespace" >> $CHEAT_SHEET
             echo "$KUBECTL logs -f <pod-name>" >> $CHEAT_SHEET
             echo "" >> $CHEAT_SHEET

             echo "# Follow the logs of a pod by name in a specific namespace" >> $CHEAT_SHEET
             echo "$KUBECTL logs -n <namespace> -f <pod-name>" >> $CHEAT_SHEET
             echo "" >> $CHEAT_SHEET

             fi

            else

            # Follow the logs of a specific container in a pod by name in a specific namespace" >> $CHEAT_SHEET
            echo "$KUBECTL logs -n <namespace> -f <pod-name> -c $CONTAINER_NAME" >> $CHEAT_SHEET
            echo "" >> $CHEAT_SHEET

            else

            # Generate commands for following logs of a pod by name
            echo "# Follow the logs of a pod by name in the current namespace" >> $CHEAT_SHEET
            echo "$KUBECTL logs -f <pod-name>" >> $CHEAT_SHEET
            echo "" >> $CHEAT_SHEET

            echo "# Follow the logs of a pod by name in a specific namespace" >> $CHEAT_SHEET
            echo "$KUBECTL logs -n <namespace> -f <pod-name>" >> $CHEAT_SHEET
            echo "" >> $CHEAT_SHEET

            fi

            else 

            # Ask the user if they want to specify a container or not
            read -p "Do you want to specify a container? (y/n): " CONTAINER

            if [ "$CONTAINER" == "y" ]; then # Specify a container

            # Ask the user for the container name
            read -p "Enter the container name: " CONTAINER_NAME

# Generate commands for printing logs of a specific container in a pod
echo "# Print the logs of a specific container in a pod by name in the current namespace" >> $CHEAT_SHEET
echo "$KUBECTL logs <pod-name> -c $CONTAINER_NAME" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

echo "# Print the logs of a specific container in a pod by name in a specific namespace" >> $CHEAT_SHEET
echo "$KUBECTL logs -n <namespace> <pod-name> -c $CONTAINER_NAME" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

else # Don't specify a container

# Generate commands for printing logs of a pod by name
echo "# Print the logs of a pod by name in the current namespace" >> $CHEAT_SHEET
echo "$KUBECTL logs <pod-name>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

echo "# Print the logs of a pod by name in a specific namespace" >> $CHEAT_SHEET
echo "$KUBECTL logs -n <namespace> <pod-name>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

fi

fi

fi # End of logs commands
;;

# Exec commands
exec)
if [ "$RESOURCE" == "pod" ]; then # Exec only works for pods and containers

# Ask the user if they want to specify a container or not
read -p "Do you want to specify a container? (y/n): " CONTAINER

if [ "$CONTAINER" == "y" ]; then # Specify a container

# Ask the user for the container name
read -p "Enter the container name: " CONTAINER_NAME

# Generate commands for executing commands in a specific container in a pod
echo "# Execute commands in a specific container in a pod by name in the current namespace" >> $CHEAT_SHEET
echo "$KUBECTL exec <pod-name> -c $CONTAINER_NAME -- <command>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

echo "# Execute commands in a specific container in a pod by name in a specific namespace" >> $CHEAT_SHEET
echo "$KUBECTL exec -n <namespace> <pod-name> -c $CONTAINER_NAME -- <command>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

else # Don't specify a container

# Generate commands for executing commands in a pod by name
echo "# Execute commands in a pod by name in the current namespace" >> $CHEAT_SHEET
echo "$KUBECTL exec <pod-name> -- <command>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

echo "# Execute commands in a pod by name in a specific namespace" >> $CHEAT_SHEET
echo "$KUBECTL exec -n <namespace> <pod-name> -- <command>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

fi

fi # End of exec commands
;;

esac # End of case statement

    echo "\`\`\`" >>$ CHEATSHEETS 
    echo "" >$ CHEATSHEETS 
  done # End of operations loop 
done # End of resources loop 

# Display the cheat sheet file
cat $CHEAT_SHEET
# Ask the user if they want to specify a container or not
read -p "Do you want to specify a container? (y/n): " CONTAINER

if [ "$CONTAINER" == "y" ]; then # Specify a container

# Ask the user for the container name
read -p "Enter the container name: " CONTAINER_NAME

# Generate commands for printing logs of a specific container in a pod
echo "# Print the logs of a specific container in a pod by name in the current namespace" >> $CHEAT_SHEET
echo "$KUBECTL logs <pod-name> -c $CONTAINER_NAME" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

echo "# Print the logs of a specific container in a pod by name in a specific namespace" >> $CHEAT_SHEET
echo "$KUBECTL logs -n <namespace> <pod-name> -c $CONTAINER_NAME" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

else # Don't specify a container

# Generate commands for printing logs of a pod by name
echo "# Print the logs of a pod by name in the current namespace" >> $CHEAT_SHEET
echo "$KUBECTL logs <pod-name>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

echo "# Print the logs of a pod by name in a specific namespace" >> $CHEAT_SHEET
echo "$KUBECTL logs -n <namespace> <pod-name>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

fi

fi

fi # End of logs commands
;;

# Exec commands
exec)
if [ "$RESOURCE" == "pod" ]; then # Exec only works for pods and containers

# Ask the user if they want to specify a container or not
read -p "Do you want to specify a container? (y/n): " CONTAINER

if [ "$CONTAINER" == "y" ]; then # Specify a container

# Ask the user for the container name
read -p "Enter the container name: " CONTAINER_NAME

# Generate commands for executing commands in a specific container in a pod
echo "# Execute commands in a specific container in a pod by name in the current namespace" >> $CHEAT_SHEET
echo "$KUBECTL exec <pod-name> -c $CONTAINER_NAME -- <command>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

echo "# Execute commands in a specific container in a pod by name in a specific namespace" >> $CHEAT_SHEET
echo "$KUBECTL exec -n <namespace> <pod-name> -c $CONTAINER_NAME -- <command>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

else # Don't specify a container

# Generate commands for executing commands in a pod by name
echo "# Execute commands in a pod by name in the current namespace" >> $CHEAT_SHEET
echo "$KUBECTL exec <pod-name> -- <command>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

echo "# Execute commands in a pod by name in a specific namespace" >> $CHEAT_SHEET
echo "$KUBECTL exec -n <namespace> <pod-name> -- <command>" >> $CHEAT_SHEET
echo "" >> $CHEAT_SHEET

fi

fi # End of exec commands
;;

esac # End of case statement

    echo "\`\`\`" >>$ CHEATSHEETS 
    echo "" >$ CHEATSHEETS 
  done # End of operations loop 
done # End of resources loop 

# Display the cheat sheet file
cat $CHEAT_SHEET

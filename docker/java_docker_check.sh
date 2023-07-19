#!/bin/bash

CONTAINERS=$(docker ps -q)

for container in $CONTAINERS; do
  echo "Container ID: $container"
  env=$(docker inspect $container | grep JAVA_HOME)
  if [[ -z "$env" ]]; then
    echo "Java is not defined in the environment of this container."
  else
    echo "$env"
  fi
done

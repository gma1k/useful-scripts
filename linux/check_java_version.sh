#!/bin/bash

check_java_version() {
  if type -p java; then
    echo "Found java executable in PATH"
    _java=java
  elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]; then
    echo "Found java executable in JAVA_HOME"
    _java="$JAVA_HOME/bin/java"
  else
    echo "Java is not installed"
    return 1
  fi

  version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
  echo "Java version is $version"

  major=$(echo $version | cut -d. -f1)
  minor=$(echo $version | cut -d. -f2)

  if [[ $major -eq 1 && $minor -ge 8 ]] || [[ $major -gt 1 ]]; then
    echo "Java version is 1.8 or higher"

    java -jar myJar-0.0.1-SNAPSHOT.jar

    return 0
  else
    echo "Java version is lower than 1.8"
    return 3
  fi
}

while true; do

  echo "Please choose one of the following options:"
  echo "1) Check all Java versions"
  echo "2) Check if an environment is using Java 11 or higher"
  echo "3) Exit"

  read -p "Enter your choice: " choice

  case $choice in

    1)
      check_java_version;;

    2)
      check_java_version

      result=$?

      if [[ $result -eq 0 ]]; then

        if [[ $major -ge 11 ]]; then
          echo "The environment is using Java 11 or higher"
        else
          echo "The environment is not using Java 11 or higher"
        fi

      else

        echo "The environment is not using Java 11 or higher"

      fi;;

    3)
      echo "Exiting..."
      break;;

    *)
      echo "Invalid choice, please try again";;

   esac

   echo ""

done

#!/bin/bash

# Variables:
FOLDER=$1
OUT=$2
user=$(logname)
USER_ID=$(id -u $user)
GROUP_ID=$(id -g $user)

# Enable debugging mode
set -x

# Check if the user uses sudo
check_sudo() {
  if [[ $(id -u) != 0 ]]
  then
    echo "Please run as a user with sudo permissions"
    exit
  fi
}

# Ask the user for the database name, or skip if already defined in the .sql scripts
ask_db() {
  echo "Enter the database name, or press enter to skip:"
  read DB
}

# Loop through the files in the folder with the .sql extension
loop_files() {
  for FILE in $FOLDER/*.sql
  do
    echo $FILE
    # Get the name of the .sql file without the extension
    NAME=$(basename $FILE .sql)
    # Check if the database name is empty or not
    check_db
    # Execute the sql file with mysql using the database name or an empty string
    execute_sql
    # Check if there was an error or not
    check_error
    # Check if there was any output from the .tsv file
    check_output
  done
}

# Check if the database name is empty or not
check_db() {
  if [ -z "$DB" ]
  then
    # If empty, use an empty string as the database name
    DBNAME=""
  else
    # If not empty, use the database name as it is
    DBNAME=$DB
  fi

  # Test if DBNAME is empty or not and print the result
  if [ -z "$DBNAME" ]
  then
    echo "DBNAME is empty"
  else
    echo "DBNAME is $DBNAME"
  fi
}

# Execute the sql file with mysql using the database name or an empty string
execute_sql() {
  cat $FILE | mysql --batch --raw $DBNAME > $NAME.tsv 2> >(tee -a error.log >&2)
}

# Check if there was an error or not
check_error() {
  if [ $? -ne 0 ]
  then
    echo "$FILE" >> error.log
    echo "Error executing $FILE"
    echo "See error.log for details"
    echo "--------------------------------------------------------------------" >> error.log

    # Test if error.log exists and print the result
    if [ -f error.log ]
    then
      echo "error.log exists"
      cat error.log
    else
      echo "error.log does not exist"
    fi
  fi
}

# Check if there was any output from the .tsv file
check_output() {
  if [ $(grep -v '^$' $NAME.tsv | wc -l) -eq 0 ]
  then
    rm $NAME.tsv
    echo "No output found, deleting $NAME.tsv"

    # Test if NAME.tsv exists and print the result
    if [ -f $NAME.tsv ]
    then
      echo "$NAME.tsv exists"
      cat $NAME.tsv
    else
      echo "$NAME.tsv does not exist"
    fi
  else
    tar czvf $NAME.tar.gz $NAME.tsv
    echo "Output found, zipping $NAME.tsv to $NAME.tar.gz"

     # Test if NAME.tar.gz exists and print the result
     if [ -f $NAME.tar.gz ]
     then
       echo "$NAME.tar.gz exists"
       tar tvf $NAME.tar.gz
     else
       echo "$NAME.tar.gz does not exist"
     fi
  fi
}

# Check if there are any .tsv or .tar.gz files in the folder and change ownership
check_files() {
  if [ -z "$(find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz')" ]
  then
    echo "No .tsv reports are created and there is nothing to zip"

     # Test if there are any .tsv or .tar.gz files and print the result
     if [ -z "$(find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz')" ]
     then
       echo "No .tsv or .tar.gz files found"
     else
       echo ".tsv or .tar.gz files found"
       find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz'
     fi

  else
    chown $USER_ID:$GROUP_ID *.tsv *.tar.gz

     # Test if there are any .tsv or .tar.gz files and print the result
     if [ -z "$(find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz')" ]
     then
       echo "No .tsv or .tar.gz files found"
     else
       echo ".tsv or .tar.gz files found"
       find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz'
     fi
  fi
}

# Main function that calls other functions in order
main() {
  check_sudo
  ask_db
  loop_files
  check_files
  chown $USER_ID:$GROUP_ID error.log

   # Test if error.log exists and print the result
   if [ -f error.log ]
   then
     echo "error.log exists"
     cat error.log
   else
     echo "error.log does not exist"
   fi
}

# Run the main function
main

# Disable debugging mode
set +x

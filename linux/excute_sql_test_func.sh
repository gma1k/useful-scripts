#!/bin/bash

# Variables:
FOLDER=$1
OUT=$2
user=$(logname)
USER_ID=$(id -u $user)
GROUP_ID=$(id -g $user)

set -x

check_sudo() {
  if [[ $(id -u) != 0 ]]
  then
    echo "Please run as a user with sudo permissions"
    exit
  fi
}

ask_db() {
  echo "Enter the database name, or press enter to skip:"
  read DB
}

loop_files() {
  for FILE in $FOLDER/*.sql
  do
    echo $FILE
    NAME=$(basename $FILE .sql)
    check_db
    execute_sql
    check_error
    check_output
  done
}

check_db() {
  if [ -z "$DB" ]
  then
    DBNAME=""
  else
    DBNAME=$DB
  fi

  if [ -z "$DBNAME" ]
  then
    echo "DBNAME is empty"
  else
    echo "DBNAME is $DBNAME"
  fi
}

execute_sql() {
  cat $FILE | mysql --batch --raw $DBNAME > $NAME.tsv 2> >(tee -a error.log >&2)
}

check_error() {
  if [ $? -ne 0 ]
  then
    echo "$FILE" >> error.log
    echo "Error executing $FILE"
    echo "See error.log for details"
    echo "--------------------------------------------------------------------" >> error.log

    if [ -f error.log ]
    then
      echo "error.log exists"
      cat error.log
    else
      echo "error.log does not exist"
    fi
  fi
}

check_output() {
  if [ $(grep -v '^$' $NAME.tsv | wc -l) -eq 0 ]
  then
    rm $NAME.tsv
    echo "No output found, deleting $NAME.tsv"

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

     if [ -f $NAME.tar.gz ]
     then
       echo "$NAME.tar.gz exists"
       tar tvf $NAME.tar.gz
     else
       echo "$NAME.tar.gz does not exist"
     fi
  fi
}

check_files() {
  if [ -z "$(find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz')" ]
  then
    echo "No .tsv reports are created and there is nothing to zip"

     if [ -z "$(find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz')" ]
     then
       echo "No .tsv or .tar.gz files found"
     else
       echo ".tsv or .tar.gz files found"
       find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz'
     fi

  else
    chown $USER_ID:$GROUP_ID *.tsv *.tar.gz

     if [ -z "$(find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz')" ]
     then
       echo "No .tsv or .tar.gz files found"
     else
       echo ".tsv or .tar.gz files found"
       find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz'
     fi
  fi
}

main() {
  check_sudo
  ask_db
  loop_files
  check_files
  chown $USER_ID:$GROUP_ID error.log

   if [ -f error.log ]
   then
     echo "error.log exists"
     cat error.log
   else
     echo "error.log does not exist"
   fi
}

main

set +x

#!/bin/bash
# This script executes SQL files and saves the output

# Variables:
FOLDER=$1
OUT=$2
USER_NAME=$(logname)
USER_ID=$(id -u $USER_NAME)
GROUP_ID=$(id -g $USER_NAME)

# Sudo check
if [[ $(id -u) != 0 ]]
  then echo "Please run as a user with sudo permissions"
  exit
fi

# If db-name not defined, option for input
echo "Enter the database name, or press enter to skip:"
read DB

# Loop into sql folder
for FILE in $FOLDER/*.sql
do
  echo $FILE
  NAME=$(basename $FILE .sql)
  if [ -z "$DB" ]
  then
    DBNAME=""
  else
    DBNAME=$DB
  fi

  cat $FILE | mysql --batch --raw $DBNAME > $NAME.tsv 2> >(tee -a error.log >&2)

  if [ $? -ne 0 ]
  then
    echo "$FILE" >> error.log
    echo "Error executing $FILE"
    echo "See error.log for details"
    echo "--------------------------------------------------------------------" >> error.log
  fi

  if [ $(grep -v '^$' $NAME.tsv | wc -l) -eq 0 ]
  then
    rm $NAME.tsv
    echo "No output found, deleting $NAME.tsv"
  else
    tar czvf $NAME.tar.gz $NAME.tsv
    echo "Output found, zipping $NAME.tsv to $NAME.tar.gz"
  fi
    if [ -z "$(find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz')" ]
    then
      echo "No .tsv reports are created and there is nothing to zip"
    else
      chown $USER_ID:$GROUP_ID  *.tsv *.tar.gz
    fi
done
# Change owner files
chown $USER_ID:$GROUP_ID error.log

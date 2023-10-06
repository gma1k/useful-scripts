#!/bin/bash
# Usage: chmod +x excute_sql.sh
# Usage #1: sudo ./excute_sql.sh . reports_folder
# Usage #2: sudo ./excute_sql.sh . db reports_folder

# Check if the user uses sudo
if [[ $(id -u) != 0 ]]
  then echo "Please run as a user with sudo permissions"
  exit
fi

# Variables:
FOLDER=$1
OUT=$2
USER_NAME=$(logname)
USER_ID=$(id -u $USER_NAME)
GROUP_ID=$(id -g $USER_NAME)

# Ask the user for the database name, or skip if already defined in the .sql scripts
echo "Enter the database name, or press enter to skip:"
read DB

# Loop through the files in the folder with the .sql extension
for FILE in $FOLDER/*.sql
do
  echo $FILE
  # Get the name of the .sql file without the extension
  NAME=$(basename $FILE .sql)
  # Check if the database name is empty or not
  if [ -z "$DB" ]
  then
    # If empty, use an empty string as the database name
    DBNAME=""
  else
    # If not empty, use the database name as it is
    DBNAME=$DB
  fi

  # Execute the sql file with mysql using the database name or an empty string
  cat $FILE | mysql --batch --raw $DBNAME > $NAME.tsv 2> >(tee -a error.log >&2)

  # Check if there was an error or not
  if [ $? -ne 0 ]
  then
    echo "$FILE" >> error.log
    echo "Error executing $FILE"
    echo "See error.log for details"
    echo "--------------------------------------------------------------------" >> error.log
  fi

  # Check if there was any output from the .tsv file
  if [ $(grep -v '^$' $NAME.tsv | wc -l) -eq 0 ]
  then
    rm $NAME.tsv
    echo "No output found, deleting $NAME.tsv"
  else
    tar czvf $NAME.tar.gz $NAME.tsv
    echo "Output found, zipping $NAME.tsv to $NAME.tar.gz"
  fi
    # Check if there are any .tsv or .tar.gz files in the folder
    if [ -z "$(find . -maxdepth 1 -name '*.tsv' -o -name '*.tar.gz')" ]
    then
      echo "No .tsv reports are created and there is nothing to zip"
    else
      chown $USER_ID:$GROUP_ID  *.tsv *.tar.gz
    fi
done
chown $USER_ID:$GROUP_ID error.log

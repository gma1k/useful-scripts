#!/bin/bash

get_user_inputs() {
  echo "Enter the start date in DD-MM-YYYY format (e.g. 01-01-2021):"
  read start_date
  echo "Enter the start time in HH:MM:SS format (e.g. 12:00:00):"
  read start_time
  echo "Enter the end date in DD-MM-YYYY format (e.g. 31-12-2021):"
  read end_date
  echo "Enter the end time in HH:MM:SS format (e.g. 23:59:59):"
  read end_time
  echo "Enter the username (leave blank for all users):"
  read username
  echo "Enter the ip address (leave blank for all ip addresses):"
  read ip_address
}

check_ssh_logs() {
  awk -v start_date="$start_date" -v end_date="$end_date" -v start_time="$start_time" -v end_time="$end_time" -v username="$username" -v ip_address="$ip_address" '
    BEGIN {
      split(start_date, sd, "-")
      start_epoch = mktime(sd[3] " " sd[2] " " sd[1] " 0 0 0")
      split(end_date, ed, "-")
      end_epoch = mktime(ed[3] " " ed[2] " " ed[1] " 0 0 0")
      split(start_time, st, ":")
      start_sec = st[1] * 3600 + st[2] * 60 + st[3]
      split(end_time, et, ":")
      end_sec = et[1] * 3600 + et[2] * 60 + et[3]
    }
    $1 ~ /-/ && $2 ~ /:/ {
      split($1, ld, "-")
      log_epoch = mktime(ld[3] " " ld[2] " " ld[1] " 0 0 0")
      split($2, lt, ":")
      log_sec = lt[1] * 3600 + lt[2] * 60 + lt[3]
      if (log_epoch >= start_epoch && log_epoch <= end_epoch && log_sec >= start_sec && log_sec <= end_sec) {
        # Check if the username is specified and matches the log user
        if (username == "" || $9 == username) {
          # Check if the ip address is specified and matches the log ip address
          if (ip_address == "" || $11 == ip_address) {
            print
          }
        }
      }
    }
  ' /var/log/auth.log
}

check_sftp_logs() {
  awk -v start_date="$start_date" -v end_date="$end_date" -v start_time="$start_time" -v end_time="$end_time" -v username="$username" -v ip_address="$ip_address" '
    BEGIN {
      split(start_date, sd, "-")
      start_epoch = mktime(sd[3] " " sd[2] " " sd[1] " 0 0 0")
      split(end_date, ed, "-")
      end_epoch = mktime(ed[3] " " ed[2] " " ed[1] " 0 0 0")
      split(start_time, st, ":")
      start_sec = st[1] * 3600 + st[2] * 60 + st[3]
      split(end_time, et, ":")
      end_sec = et[1] * 3600 + et[2] * 60 + et[3]
    }
    $1 ~ /-/ && $2 ~ /:/ {
      split($1, ld, "-")
      log_epoch = mktime(ld[3] " " ld[2] " " ld[1] " 0 0 0")
      split($2, lt, ":")
      log_sec = lt[1] * 3600 + lt[2] * 60 + lt[3]
      if (log_epoch >= start_epoch && log_epoch <= end_epoch && log_sec >= start_sec && log_sec <= end_sec && $0 ~ /sftp-server/) {
        if (username == "" || $9 == username) {
          if (ip_address == "" || $11 == ip_address) {
            # Print the log line
            print
          }
        }
      }
    }
  ' /var/log/auth.log
}

check_ftp_logs() {
  awk -v start_date="$start_date" -v end_date="$end_date" -v start_time="$start_time" -v end_time="$end_time" -v username="$username" -v ip_address="$ip_address" '
    BEGIN {
      split(start_date, sd, "-")
      start_epoch = mktime(sd[3] " " sd[2] " " sd[1] " 0 0 0")
      split(end_date, ed, "-")
      end_epoch = mktime(ed[3] " " ed[2] " " ed[1] " 0 0 0")
      split(start_time, st, ":")
      start_sec = st[1] * 3600 + st[2] * 60 + st[3]
      split(end_time, et, ":")
      end_sec = et[1] * 3600 + et[2] * 60 + et[3]
    }
    $1 ~ /-/ && $2 ~ /:/ {
      split($1, ld, "-")
      log_epoch = mktime(ld[3] " " ld[2] " " ld[1] " 0 0 0")
      split($2, lt, ":")
      log_sec = lt[1] * 3600 + lt[2] * 60 + lt[3]
      if (log_epoch >= start_epoch && log_epoch <= end_epoch && log_sec >= start_sec && log_sec <= end_sec && $0 ~ /ftpd/) {
        if (username == "" || $8 == username) {
          if (ip_address == "" || $7 == ip_address) {
            print
          }
        }
      }
    }
  ' /var/log/vsftpd.log
}

save_output() {
  echo "Enter the operation name:"
  read operation_name
  datetime=$(date +"%Y%m%d%H%M%S")
  cat output.txt > "${operation_name}_${datetime}.txt"
}

echo "What do you need to check?"
echo "1) SSH logs"
echo "2) SFTP logs"
echo "3) FTP logs"
echo "4) All logs"
read choice

get_user_inputs

case $choice in
  1)
    check_ssh_logs > output.txt
    ;;
  2)
    check_sftp_logs > output.txt
    ;;
  3)
    check_ftp_logs > output.txt
    ;;
  4)
    check_ssh_logs > output.txt
    check_sftp_logs >> output.txt
    check_ftp_logs >> output.txt
    ;;
esac

echo "Do you need to save to output file? (y/n)"
read answer
if [ "$answer" == "y" ]; then
  save_output
fi

rm output.txt

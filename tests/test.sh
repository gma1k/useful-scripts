#!/bin/bash

# Var:
URL="https://$APP_NAME.$AUTO_DEVOPS_DOMAIN"

check_status() {
  local status=$(curl -s -o /dev/null -w "%{http_code}" $1)
  if [ $status -eq $2 ]; then
    echo "OK: $1 ($status)"
  else
    echo "FAIL: $1 ($status)"
    exit 1
  fi
}

# Test homepage
check_status $URL 200

# Test some other pages or endpoints
check_status $URL/about 200
check_status $URL/contact 200
check_status $URL/api/users 200

# Test some invalid pages or endpoints
check_status $URL/invalid 404
check_status $URL/api/invalid 404

# If all tests passed, exit with success
exit 0

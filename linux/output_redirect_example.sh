#!/bin/bash

greet() {
  echo "Hello, $1!"
}

factorial() {
  local n=$1
  local result=1
  while [ $n -gt 0 ]; do
    result=$((result * n))
    n=$((n - 1))
  done
  echo $result
}

redirect() {
  local func=$1
  local arg=$2
  local file=$3
  $func $arg > $file
}

read -p "What is your name? " name
greet $name
read -p "Enter a number: " num
redirect factorial $num output.txt
echo "The factorial of $num has been saved to output.txt"

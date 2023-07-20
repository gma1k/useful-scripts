#!/bin/bash

# This is a comment. Comments start with a # symbol and are ignored by the shell.

# This is a variable. Variables store values that can be used later in the script.
name="John"

# This is a function. Functions are reusable blocks of code that can be called by name.
# Functions can take arguments and return values.
greet() {
  # This is a local variable. Local variables are only visible inside the function.
  local message="Hello, $1!" # $1 is the first argument passed to the function
  echo "$message" # echo is a command that prints a message to the standard output
  return 0 # return is a command that exits the function with a status code
}

# This is an if statement. If statements execute different commands based on conditions.
if [ "$name" == "John" ]; then # [ ] is a command that evaluates a condition
  # This is a command substitution. Command substitutions run commands and capture their output.
  output=$(greet "$name") # $( ) is a syntax for command substitution
  echo "$output"
else
  echo "Unknown name"
fi

# This is a for loop. For loops iterate over a list of values and execute commands for each value.
for file in *.txt; do # *.txt is a pattern that matches all files with .txt extension
  # This is a parameter expansion. Parameter expansions modify the value of a parameter.
  base=${file%.txt} # ${ } is a syntax for parameter expansion
  echo "The base name of $file is $base"
done

# This is a while loop. While loops execute commands as long as a condition is true.
count=1
while [ $count -le 5 ]; do # -le is an operator that means less than or equal to
  echo "Count: $count"
  # This is an arithmetic expansion. Arithmetic expansions perform arithmetic operations.
  count=$((count + 1)) # $(( )) is a syntax for arithmetic expansion
done

# This is a case statement. Case statements match a value against different patterns and execute commands accordingly.
read -p "Enter your choice (a/b/c): " choice # read is a command that reads input from the user
case $choice in # case is a keyword that starts the case statement
  a) echo "You chose option A";; # ;; is a symbol that ends each pattern
  b) echo "You chose option B";;
  c) echo "You chose option C";;
  *) echo "Invalid choice";; # * is a pattern that matches anything else
esac # esac is a keyword that ends the case statement

# This is an error handling block. Error handling blocks catch and handle errors that occur during the execution of the script.
set -e # set is a command that sets shell options. -e means exit on error.
trap 'echo "An error occurred!"' ERR # trap is a command that specifies actions to take on signals or events. ERR is an event that occurs when an error happens.
false # false is a command that always returns an error status code

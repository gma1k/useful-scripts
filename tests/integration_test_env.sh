#!/bin/bash

# Set up the environment
setup_environment() {
  echo "Setting up the environment..."
  # Add your environment setup commands here
  source setup_environment.sh
}

# Run a single test file
run_test_file() {
  local test_file=$1
  echo "Running integration test file: $test_file" | tee -a $log_file
  if ! bash "$test_file" >> $log_file 2>&1 ; then
    echo "Test failed: $test_file" | tee -a $log_file
    exit_code=1
  fi
}

# Run all test files in parallel
run_tests_in_parallel() {
  for test_file in $test_files
  do
    run_test_file "$test_file" &
  done

  wait
  for job in $(jobs -p)
  do
    wait $job || exit_code=1
  done
}

# Validate input
validate_input() {
  if [ -z "$1" ]; then
    echo "Error: No input provided. Please provide the directory containing the test files."
    exit 1
  fi

  if [ ! -d "$1" ]; then
    echo "Error: Directory '$1' does not exist."
    exit 1
  fi
}

# Main script
main() {
  read -p "Enter the directory containing the test files: " test_dir
  validate_input "$test_dir"

  # Initialize variables
  exit_code=0
  log_file="test_log.txt"
  test_files=$(find "$test_dir" -name '*_integration.sh' -type f)

  setup_environment
  run_tests_in_parallel

  exit $exit_code
}

# Run the main function
main

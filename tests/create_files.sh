#!/bin/bash
for i in {1..10}; do
  echo "Test file $i" > "testfile_$i.txt"
  cat "testfile_$i.txt"
done

#!/bin/bash

print_exif_data() {
  local file="$1"
  if [[ $(file -b --mime-type "$file") == image/jpeg ]]; then
    exiv2 print "$file"
  else
    echo "Not a JPEG image: $file"
  fi
}

read -p "Enter a picture file name: " file

print_exif_data "$file"

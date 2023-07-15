#!/bin/bash

print_exif_data() {
  # get the file name
  local file="$1"
  # check if the file is a JPEG image
  if [[ $(file -b --mime-type "$file") == image/jpeg ]]; then
    # print all the EXIF data using exiv2
    exiv2 print "$file"
  else
    # print an error message if not a JPEG image
    echo "Not a JPEG image: $file"
  fi
}

# ask the user for a picture file name
read -p "Enter a picture file name: " file

# call the function on the file name
print_exif_data "$file"

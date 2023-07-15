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

modify_exif_data() {
  # get the file name as an argument
  local file="$1"
  # check if the file is a JPEG image
  if [[ $(file -b --mime-type "$file") == image/jpeg ]]; then
    # ask the user for the EXIF key to modify
    read -p "Enter the EXIF key to modify (e.g. Exif.Photo.DateTimeOriginal): " key
    # check if the key is valid
    if exiv2 -g "$key" -Pv "$file" >/dev/null 2>&1; then
      # ask the user for the new value for the key
      read -p "Enter the new value for $key: " value
      # modify the EXIF data using exiv2
      exiv2 -M"set $key $value" "$file"
      echo "EXIF data modified successfully."
    else
      # print an error message if the key is invalid
      echo "Invalid EXIF key: $key"
    fi
  else
    # print an error message if not a JPEG image
    echo "Not a JPEG image: $file"
  fi
}

delete_exif_data() {
  # get the file name as an argument
  local file="$1"
  # check if the file is a JPEG image
  if [[ $(file -b --mime-type "$file") == image/jpeg ]]; then
    # delete all the EXIF data using exiv2
    exiv2 rm "$file"
    echo "EXIF data deleted successfully."
  else
    # print an error message if not a JPEG image
    echo "Not a JPEG image: $file"
  fi
}

# ask the user for a picture file name
read -p "Enter a picture file name: " file

# print all the EXIF data from the picture
print_exif_data "$file"

# ask the user if they want to modify or delete the EXIF data
read -p "Do you want to modify or delete the EXIF data? (m/d/n): " choice

# call the appropriate function based on the user's choice
case $choice in
  m|M)
    modify_exif_data "$file"
    ;;
  d|D)
    delete_exif_data "$file"
    ;;
  n|N)
    echo "No changes made."
    ;;
  *)
    echo "Invalid choice."
    ;;
esac

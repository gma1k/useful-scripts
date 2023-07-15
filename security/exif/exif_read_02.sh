#!/bin/bash

print_exif_data() {
  # get the file name
  local file="$1"
  # get the MIME type of the file
  local mime=$(file -b --mime-type "$file")
  # check if the MIME type is one of the supported formats
  case $mime in
    image/jpeg|image/tiff|image/png|image/webp)
      # print all the EXIF data using exiv2
      exiv2 print "$file"
      ;;
    *)
      # print an error message if not a supported format
      echo "Unsupported image format: $mime"
      ;;
  esac
}

# ask the user for a picture file name
read -p "Enter a picture file name: " file

# call the function on the file name
print_exif_data "$file"

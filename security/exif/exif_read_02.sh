#!/bin/bash

print_exif_data() {
  local file="$1"
  local mime=$(file -b --mime-type "$file")
  case $mime in
    image/jpeg|image/tiff|image/png|image/webp)
      exiv2 print "$file"
      ;;
    *)
      echo "Unsupported image format: $mime"
      ;;
  esac
}

read -p "Enter a picture file name: " file

print_exif_data "$file"

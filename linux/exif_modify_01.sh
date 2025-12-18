#!/bin/bash

print_exif_data() {
  local file="$1"
  if [[ $(file -b --mime-type "$file") == image/jpeg ]]; then
    exiv2 print "$file"
  else
    echo "Not a JPEG image: $file"
  fi
}

modify_exif_data() {
  local file="$1"
  if [[ $(file -b --mime-type "$file") == image/jpeg ]]; then
    read -p "Enter the EXIF key to modify (e.g. Exif.Photo.DateTimeOriginal): " key
    if exiv2 -g "$key" -Pv "$file" >/dev/null 2>&1; then
      read -p "Enter the new value for $key: " value
      exiv2 -M"set $key $value" "$file"
      echo "EXIF data modified successfully."
    else
      echo "Invalid EXIF key: $key"
    fi
  else
    echo "Not a JPEG image: $file"
  fi
}

delete_exif_data() {
  local file="$1"
  if [[ $(file -b --mime-type "$file") == image/jpeg ]]; then
    exiv2 rm "$file"
    echo "EXIF data deleted successfully."
  else
    echo "Not a JPEG image: $file"
  fi
}

read -p "Enter a picture file name: " file

print_exif_data "$file"

read -p "Do you want to modify or delete the EXIF data? (m/d/n): " choice

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

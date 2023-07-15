# This is a bash script that can read, modify or delete EXIF data from a picture file
# It uses the exiv2 command line utility to manipulate the EXIF data
# To use this script, you need to install exiv2 on your system
# You also need to know the parameters of the EXIF tags that you want to modify
# You can find a list of EXIF tags online at https://www.exiv2.org/tags.html
# or use the taglist sample program provided by Exiv2
# To run this script, make it executable with chmod +x exif_modify.sh
# Then run it with ./exif_modify.sh
# It will prompt you to enter a picture file name, and then print all the EXIF data from it
# It will also ask you if you want to modify or delete the EXIF data, and perform the corresponding action based on your input

# Here are some examples of EXIF tags that can be used and modified:

# Exif.Photo.DateTimeOriginal: The date and time when the original image data was generated.
# Example: Exif.Photo.DateTimeOriginal 2021:11:01 12:34:56

# Exif.Image.Make: The manufacturer of the recording equipment.
# Example: Exif.Image.Make Nikon

# Exif.Image.Model: The model name or model number of the equipment.
# Example: Exif.Image.Model D850

# Exif.Photo.FocalLength: The actual focal length of the lens, in mm.
# Example: Exif.Photo.FocalLength 50.0

# Exif.Photo.ExposureTime: The exposure time, given in seconds.
# Example: Exif.Photo.ExposureTime 1/250

# Exif.Photo.FNumber: The F number.
# Example: Exif.Photo.FNumber 5.6

# Exif.Photo.ISOSpeedRatings: The ISO speed and ISO latitude of the camera or input device as specified in ISO 12232.
# Example: Exif.Photo.ISOSpeedRatings 320

# Exif.GPSInfo.GPSLatitude: The latitude of the image location.
# Example: Exif.GPSInfo.GPSLatitude 47/1 36/1 3528/100

# Exif.GPSInfo.GPSLongitude: The longitude of the image location.
# Example: Exif.GPSInfo.GPSLongitude 122/1 19/1 5904/100

# Exif.GPSInfo.GPSAltitude: The altitude of the image location.
# Example: Exif.GPSInfo.GPSAltitude 15/1

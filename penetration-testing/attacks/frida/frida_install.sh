#!/bin/bash

get_parch() {
  adb shell getprop ro.product.cpu.abi
}

download_frida() {
  local parch="$1"
  local url="$2"
  wget -q --show-progress "$url"
  unxz frida-server*
}

run_frida() {
  adb root
  adb push frida-server* /data/local/tmp/frida-server
  adb shell "chmod 755 /data/local/tmp/frida-server"
  adb shell "/data/local/tmp/frida-server &"
}

parch=$(get_parch)

[[ "$parch" == "armeabi-v7a" ]] && parch="arm"

url=$(wget -q -O - https://api.github.com/repos/frida/frida/releases \
| jq '.[0] | .assets[] | select(.browser_download_url | match("server(.*?)android-'$parch'*\\.xz")).browser_download_url')

read -p "Do you want to download and run frida-server on your device? (y/n) " answer

if [[ "$answer" == "y" ]]; then
  download_frida "$parch" "$url"
  run_frida
  echo "Frida-server is running on your device."
else
  echo "Frida-server is not downloaded or running on your device."
fi

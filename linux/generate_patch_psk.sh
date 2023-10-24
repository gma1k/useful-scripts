#!/bin/bash

NEW_PSK=($(dd if=/dev/urandom count=20 bs=1 2> /dev/null | xxd -p -c 64))
echo $NEW_PSK
patch='{"stringData":{"keys":"'$((($KEYID+1)))' rfc4106(gcm(aes)) '$NEW_PSK' 128"}}'

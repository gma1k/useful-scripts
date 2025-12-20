#!/bin/bash

echo "Enter the target URL:"
read url

echo "Enter the API token:"
read token

echo "Enter the enumeration options (separated by commas):"
read enum

echo "Enter the detection mode (passive, aggressive, or mixed):"
read mode

echo "Do you want to perform a stealthy scan? (y/n)"
read stealth

echo "Do you want to throttle the scan? (y/n)"
read throttle

echo "Do you want to use a random user agent? (y/n)"
read agent

echo "Do you want to force the scan? (y/n)"
read force

wpscan --url $url --api-token $token --enumerate $enum --plugins-detection $mode \
$( [ "$stealth" = "y" ] && echo "--stealthy" ) \
$( [ "$throttle" = "y" ] && echo "--throttle 1000" ) \
$( [ "$agent" = "y" ] && echo "--random-user-agent" ) \
$( [ "$force" = "y" ] && echo "--force" )

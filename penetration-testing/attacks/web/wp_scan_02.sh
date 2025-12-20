#!/bin/bash

echo "Enter the target URL:"
read url

echo "Enter the API token:"
read token

wpscan --url $url --api-token $token --enumerate u,vp,vt,tt,cb,dbe --force
